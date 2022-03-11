//
//  TopupTransferViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 07/03/2022.
//

import Foundation

import YAPComponents
import RxSwift
import RxCocoa

public enum errorMessage: String, Codable {
    case removeMaxLimit
    case removeCurrentBalance
    case addMaxLimit
    case addCurrentBalance
}

public extension errorMessage {
    var localized: String {
        switch self {
        case .removeMaxLimit:
            return  "screen_remove_funds_display_text_max_limit_error".localized
        case .removeCurrentBalance:
            return   "screen_remove_funds_display_text_available_balance_error".localized
        case .addMaxLimit:
            return  "screen_add_funds_display_text_max_limit_error".localized
        case .addCurrentBalance:
            return  "screen_add_funds_display_text_available_balance_error".localized
        }
    }
}

protocol TopupTransferViewModelInput {
    var actionButtonObserver: AnyObserver<Void> { get }
    var enteredAmountObserver: AnyObserver<Double?> { get }
    var pollACSResultObserver: AnyObserver<Void> { get }
    var requestDenominationAmountObserver: AnyObserver<Void> { get }
    var transactionRequestObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
}

protocol TopupTransferViewModelOutput {
    var html: Observable<String> { get }
    var pollACSResult: Observable<Void> { get }
    var result: Observable<(orderId: String, threeDSecureId: String, amount: String, currency: String, card: ExternalPaymentCard)> { get }
    var becomeResponder: Observable<Bool> { get }
    var amountError: Observable<String?> { get }
    var availableBalance: Observable<NSAttributedString?> { get}
    var screenTitle: Observable<String?> { get }
    var amountTitle: Observable<String?> { get }
    var accountBalance: Observable<String?> { get }
    var panNumber: Observable<String?> { get }
    var cardImage: Observable<UIImage?> { get }
    var cardTitle: Observable<String?> { get }
    var transactionFee: Observable<NSAttributedString?> { get }
    var fee: Observable<Double?> { get }
    var requestTopupTransactionFee: Observable<Void> { get }
    var loading: Observable<Bool> { get }
    var error: Observable<String> { get }
    var showAmountError: Observable<String?> { get }
    var minimumAmountLimit: Observable<Double?> { get }
    var maximumAmountLimit: Observable<Double?> { get }
    var requestDenominationAmount: Observable<Void> { get }
    var activateAction: Observable<Bool> { get }
    var actionButton: Observable<Void> { get }
    var isValidMaxLimit: Observable<(Bool?, String?)> { get }
    var isValidLowerLimit: Observable<Bool?> { get }
    var isValidAmount: Observable<(Bool?, String?)> { get }
    var quickAmounts: Observable<[String]> { get }
    var denominationAmountViewModels: Observable<[DenominationAmountCollectionViewCellViewModel]> { get }
    var back: Observable<Void> { get }
}


protocol TopupTransferViewModelType {
    var inputs: TopupTransferViewModelInput { get }
    var outputs: TopupTransferViewModelOutput { get }
}

class TopupTransferViewModel: TopupTransferViewModelType, TopupTransferViewModelOutput, TopupTransferViewModelInput {
    
    var inputs: TopupTransferViewModelInput { return self }
    var outputs: TopupTransferViewModelOutput { return self }
    
    // MARK: Properties
    private let repository: TransactionsRepositoryType
    private let paymentGatewayM: PaymentGatewayLocalModel!
    private var paymentCard = ExternalPaymentCard()
    private var checkoutSessionObject: PaymentGatewayCheckoutSession?
    private let disposeBag = DisposeBag()
    
    public var constantMinAmount: Double {  0.0 }
    
    // MARK: - Subjects
    private let loadingSubject = PublishSubject<Bool>()
    private var requestDenominationAmountSubject = PublishSubject<Void>()
    private let transactionFeeSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    private let cardImageSubject = BehaviorSubject<UIImage?>(value: nil)
    private let cardTitleSubject = BehaviorSubject<String?>(value: nil)
    private let accountBalanceSubject = BehaviorSubject<String?>(value: nil)
    private let requestTopupTransactionFeeSubject = PublishSubject<Void>()
    private let feeSubject = BehaviorSubject<Double?>(value: nil)
    private let pollACSResultSubject = PublishSubject<Void>()
    private let resultSubject = PublishSubject<(orderId: String, threeDSecureId: String, amount: String, currency: String, card: ExternalPaymentCard)>()
    private let transferSubject = PublishSubject<Void>()
    private let dailyRemainingLimitSubject = BehaviorSubject<Double?>(value: nil)
    private let screeTitleSubject = BehaviorSubject<String?>(value: nil)
    private let amountViewTitleSubject = BehaviorSubject<String?>(value: nil)
    private let htmlSubject = PublishSubject<String>()
    private let becomeResponderSubject = PublishSubject<Bool>()
    private let amountErrorSubject = PublishSubject<String?>()
    private let availableBalanceSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    private var denominationAmountViewModelsSubject = BehaviorSubject<[DenominationAmountCollectionViewCellViewModel]>(value: [])
    private let cardPANNumberSubject = BehaviorSubject<String?>(value: nil)
    private let amountSubject = PublishSubject<String?>()
    private let thresholdSubject = BehaviorSubject<TransactionThreshold?>(value: nil)
    private let errorSubject = PublishSubject<String>()
    private let showAmountErrorSubject = BehaviorSubject<String?>(value: nil)
    private let minimumAmountLimitSubject = BehaviorSubject<Double?>(value: nil)
    private let maximumAmountLimitSubject = BehaviorSubject<Double?>(value: nil)
    private let enteredAmountSubject = BehaviorSubject<Double?>(value: nil)
    private let activateActionSubject = PublishSubject<Bool>()
    private let actionButtonSubject = PublishSubject<Void>()
    private let isValidMaxLimitSubject = BehaviorSubject<(Bool?, String?)>(value: (nil, nil))
    private let isValidLowerLimitSubject = BehaviorSubject<Bool?>(value: nil)
    private let isValidAmountSubject = PublishSubject<(Bool?, String?)>()
    private var transactionRequestSubject = PublishSubject<Void>()
    private let quickAmountsSubject =  BehaviorSubject<[String]>(value: [])
    private var backSubject = PublishSubject<Void>()
    
    // MARK: - Input
    var actionButtonObserver: AnyObserver<Void> { return actionButtonSubject.asObserver() }
    var enteredAmountObserver: AnyObserver<Double?> { return enteredAmountSubject.asObserver() }
    var pollACSResultObserver: AnyObserver<Void> { return pollACSResultSubject.asObserver() }
    var requestDenominationAmountObserver: AnyObserver<Void> { return requestDenominationAmountSubject.asObserver() }
    var transactionRequestObserver: AnyObserver<Void> { return transactionRequestSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    
    // MARK: - Outputs
    var html: Observable<String> { return htmlSubject.asObservable() }
    var pollACSResult: Observable<Void> { return pollACSResultSubject.asObservable() }
    var result: Observable<(orderId: String, threeDSecureId: String, amount: String, currency: String, card: ExternalPaymentCard)> { return resultSubject.asObservable() }
    var amountError: Observable<String?> { amountErrorSubject.asObservable() }
    var availableBalance: Observable<NSAttributedString?> { return availableBalanceSubject.asObservable() }
    var screenTitle: Observable<String?> { return screeTitleSubject.asObservable() }
    var amountTitle: Observable<String?> { return amountViewTitleSubject.asObservable() }
    var accountBalance: Observable<String?> { return accountBalanceSubject.asObservable() }
    var panNumber: Observable<String?> { return cardPANNumberSubject.asObservable() }
    var transactionFee: Observable<NSAttributedString?> { return transactionFeeSubject.asObservable() }
    var cardImage: Observable<UIImage?> { return cardImageSubject.asObservable() }
    var cardTitle: Observable<String?> { return cardTitleSubject.asObservable() }
    var fee: Observable<Double?> { return feeSubject.asObservable() }
    var requestTopupTransactionFee: Observable<Void> { return requestTopupTransactionFeeSubject.asObservable() }
    var becomeResponder: Observable<Bool> { becomeResponderSubject.asObservable() }
    var loading: Observable<Bool> { return loadingSubject.asObservable() }
    var error: Observable<String> { return errorSubject.asObservable() }
    var showAmountError: Observable<String?> { showAmountErrorSubject.asObservable() }
    var minimumAmountLimit: Observable<Double?> { return minimumAmountLimitSubject.asObservable() }
    var maximumAmountLimit: Observable<Double?> { return maximumAmountLimitSubject.asObservable() }
    var requestDenominationAmount: Observable<Void> { return requestDenominationAmountSubject.asObservable() }
    var activateAction: Observable<Bool> { return activateActionSubject.asObservable() }
    var actionButton: Observable<Void> { return actionButtonSubject.asObservable() }
    var denominationAmountViewModels: Observable<[DenominationAmountCollectionViewCellViewModel]> { return denominationAmountViewModelsSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var isValidMaxLimit: Observable<(Bool?, String?)> { return isValidMaxLimitSubject.asObservable() }
    var isValidLowerLimit: Observable<Bool?> { return isValidLowerLimitSubject.asObservable() }
    var isValidAmount: Observable<(Bool?, String?)> { return isValidAmountSubject.asObservable() }
    var quickAmounts: Observable<[String]> { return quickAmountsSubject.asObservable() }
    
    init(repository: TransactionsRepositoryType, paymentGatewayModel: PaymentGatewayLocalModel) {
        self.repository = repository
        self.paymentGatewayM = paymentGatewayModel
        
        guard let paymentGatewayM = paymentGatewayModel.beneficiary else { return }
        self.paymentCard = paymentGatewayM
//        if let paymentCard = self.paymentCard {
            cardPANNumberSubject.onNext("*\(paymentCard.last4Digits)")
            cardTitleSubject.onNext(paymentCard.nickName)
            cardImageSubject.onNext(paymentCard.cardImage())
//        }
        
        self.fetchAndProcessInitialData()
        cardTopup()
        
        let limitAndAmount = Observable.combineLatest(minimumAmountLimitSubject.unwrap(), maximumAmountLimitSubject.unwrap(), enteredAmountSubject.unwrap(), dailyRemainingLimitSubject.unwrap())

        limitAndAmount.map {
            ($0.2 > $0.1 || $0.2 < $0.0) ? String.init(format: "common_display_text_transaction_limit_error".localized, CurrencyFormatter.formatAmountInLocalCurrency($0.0), CurrencyFormatter.formatAmountInLocalCurrency($0.1)) : $0.3 <= 0 ? "screen_topup_daily_limit_error".localized : $0.2 > $0.3 ? "screen_topup_remaining_daily_limit_error".localized : nil

        }.bind(to: amountErrorSubject).disposed(by: disposeBag)

        Observable.combineLatest(minimumAmountLimitSubject.unwrap(), enteredAmountSubject.unwrap(), amountErrorSubject, maximumAmountLimitSubject.unwrap(), dailyRemainingLimitSubject.unwrap())
            .map { [unowned self] in
                ($0.1 >= $0.0 && $0.1 <= $0.3 && $0.1 <= $0.4 && $0.1 != self.constantMinAmount) && $0.2 == nil
            }
            .bind(to: activateActionSubject)
            .disposed(by: disposeBag)

        actionButtonSubject.withLatestFrom(Observable.combineLatest(accountBalance.unwrap(), enteredAmountSubject.unwrap(), maximumAmountLimitSubject.unwrap()))
            .subscribe(onNext: { [unowned self] arg in
                print("button tapped")
                if arg.1 <= arg.2 {
                    self.isValidMaxLimitSubject.onNext((true, nil))
                    self.isValidAmountSubject.onNext((true, nil))
                    self.transactionRequestSubject.onNext(())
                } else {
                    self.isValidMaxLimitSubject.onNext((false, String(format: errorMessage.addMaxLimit.localized, CurrencyFormatter.formatAmountInLocalCurrency(arg.2))))
                }
                
            }).disposed(by: disposeBag)
        
    }
    
    func fetchAndProcessInitialData() {
        YAPProgressHud.showProgressHud()
        
        let getThreshold = getThresholdLimit()
        let getCustomerBalance = getCustomerAccountBalance()
        let getTransactionLimit = getProductLimit()
        let getFee = getTopupTransactionFee()
        let denominations = getDenominationAmount()
        
        Observable.zip(getThreshold, getCustomerBalance, getTransactionLimit, getFee, denominations).materialize()
            .do(onNext: { _ in
                YAPProgressHud.hideProgressHud()
            })
            .subscribe(onNext: { [unowned self] materializeEvent in
                
                switch materializeEvent {
                case let .next((thresholdRes, customerBalanceRes, transactionLimtRes, feeRes, denominationsResult)):
                    if let threshold = thresholdRes.element, let customerBalance = customerBalanceRes.element, let transactionLimit = transactionLimtRes.element, let fee = feeRes.element, let denominations = denominationsResult.element {
                        self.topupCardLocalizations(accountBalance: customerBalance.formattedBalance())
                    }
                    
                case let .error(error):
                    print("error \(error)")
                case .completed: break
                }
            }).disposed(by: disposeBag)
    }
    
}

// MARK: - Apis calling
extension TopupTransferViewModel {
    
    fileprivate func getCustomerAccountBalance() -> Observable<Event<CustomerBalanceResponse>> {
        let accountBalanceRequest = repository.fetchCustomerAccountBalance().share(replay: 1, scope: .whileConnected)
        accountBalanceRequest.map { _ in true }.bind(to: loadingSubject).disposed(by: disposeBag)

        accountBalanceRequest.elements()
            .map { $0.formattedBalance() }
            .bind(to: accountBalanceSubject)
            .disposed(by: disposeBag)

        accountBalanceRequest
            .errors()
            .do(onNext: { [unowned self] _ in
                self.loadingSubject.onNext(false) })
            .map { $0.localizedDescription }
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
        
        return accountBalanceRequest
    }
    
    fileprivate func getThresholdLimit() -> Observable<Event<TransactionThreshold>> {
        let thresholdLimitRequest = repository.getThresholdLimits().share(replay: 1, scope: .whileConnected)
        thresholdLimitRequest.map { _ in true }.bind(to: loadingSubject).disposed(by: disposeBag)

        thresholdLimitRequest.elements()
            .map { $0.dailyLimit }
            .bind(to: dailyRemainingLimitSubject)
            .disposed(by: disposeBag)

        thresholdLimitRequest
            .errors()
            .do(onNext: { [unowned self] _ in
                self.loadingSubject.onNext(false) })
            .map { $0.localizedDescription }
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
        
        return thresholdLimitRequest
    }
    
    fileprivate func getProductLimit() -> Observable<Event<TransactionLimit>> {
        let productLimitRequest = repository.getTransactionProductLimit(transactionProductCode: TransactionProductCode.topUpByExternalCard.rawValue).share(replay: 1, scope: .whileConnected)
        productLimitRequest.map { _ in true }.bind(to: loadingSubject).disposed(by: disposeBag)

        productLimitRequest
            .elements()
            .map { Double($0.minLimit) }
            .bind(to: minimumAmountLimitSubject)
            .disposed(by: disposeBag)

        productLimitRequest
            .elements()
            .do(onNext: { [unowned self] _ in
                self.requestDenominationAmountObserver.onNext(()) })
            .map { Double($0.maxLimit) }
            .bind(to: maximumAmountLimitSubject)
            .disposed(by: disposeBag)

        productLimitRequest
            .errors()
            .do(onNext: { [unowned self] _ in
                self.loadingSubject.onNext(false) })
            .map { $0.localizedDescription }
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
        
        return productLimitRequest
    }
    
    fileprivate func getTopupTransactionFee() -> Observable<Event<TransactionProductCodeFeeResponse>> {
        let topupTransactionFeeResult = repository.getFee(productCode: TransactionProductCode.topUpByExternalCard.rawValue).share(replay: 1, scope: .whileConnected)

        topupTransactionFeeResult
            .map { _ in false }
            .bind(to: loadingSubject)
            .disposed(by: disposeBag)

        Observable.combineLatest(topupTransactionFeeResult.elements(), enteredAmountSubject.map{ $0 ?? 0 }.startWith(0)) { transferFee, amount in
            transferFee.fixedAmount
        }
        .bind(to: feeSubject)
        .disposed(by: disposeBag)

        topupTransactionFeeResult
            .errors()
            .map { $0.localizedDescription }
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
        
        return topupTransactionFeeResult
    }
    
    fileprivate func getDenominationAmount() -> Observable<Event<[DenominationResponse]>> {
        
        let denominationAmountResult = self.repository.getDenominationAmount(productCode: TransactionProductCode.topUpByExternalCard.rawValue).share(replay: 1, scope: .whileConnected)
        
        denominationAmountResult
            .elements()
            .do(onNext: { [unowned self] _ in
                self.becomeResponderSubject.onNext(true)
                self.requestTopupTransactionFeeSubject.onNext(()) })
            .map { $0.map { Double($0.amount) ?? 0 } }.map { $0.sorted(by: { $1 > $0 }) }
            .map { $0.map { "+" + $0.toString() }}
            .bind(to: quickAmountsSubject)
            .disposed(by: disposeBag)

        quickAmounts
            .map { $0.map { DenominationAmountCollectionViewCellViewModel(amount: $0 ) } }
            .bind(to: denominationAmountViewModelsSubject)
            .disposed(by: disposeBag)

        denominationAmountResult
            .errors()
            .map { $0.localizedDescription }
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
        
        return denominationAmountResult
    }
    
    private func cardTopup() {
        
        let beneficiaryID = String(self.paymentGatewayM.beneficiary?.id ?? 0)
        
        let checkoutSessionRequest = transactionRequestSubject
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .flatMap { [weak self] _ -> Observable<Event<PaymentGatewayCheckoutSession>> in
                guard let `self` = self else { return .never() }
                guard let amount = try? self.enteredAmountSubject.value() else { return .never() }
            return self.repository.fetchCheckoutSession(beneficiaryId: beneficiaryID, amount: String(amount), currency: "PKR", sessionId: "")
        }.share()

        checkoutSessionRequest.errors()
            .do(onNext: { _ in
                YAPProgressHud.hideProgressHud()
            })
                .map {
                    $0.localizedDescription
                }
                .bind(to: errorSubject)
                .disposed(by: disposeBag)
        
        let  fetch3DSEnrollmentRequest = checkoutSessionRequest.elements().withUnretained(self)
            .flatMapLatest { `self`,  paymentGatewayCheckoutSession -> Observable<Event<PaymentGateway3DSEnrollmentResult>> in
                self.checkoutSessionObject = paymentGatewayCheckoutSession
                guard let amount = try? self.enteredAmountSubject.value() else { return .never() }
                return self.repository.fetch3DSEnrollment(orderId: paymentGatewayCheckoutSession.order?.id ?? "", beneficiaryID: beneficiaryID.intValue, amount: paymentGatewayCheckoutSession.order?.amount ?? "", currency: paymentGatewayCheckoutSession.order?.currency ?? "", sessionID: paymentGatewayCheckoutSession.session?.id ?? "")
            }
            .share()

        fetch3DSEnrollmentRequest.errors()
            .do(onNext: { _ in
                YAPProgressHud.hideProgressHud()
            })
            .map {
                $0.localizedDescription
            }
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
        
        let threeDEnrollmentResult = fetch3DSEnrollmentRequest.elements()
        threeDEnrollmentResult
            .map {
                $0.formattedHTML
            }
            .bind(to: htmlSubject)
            .disposed(by: disposeBag)

        var count = 0

        let acsResultRequest = pollACSResultSubject
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .delay(RxTimeInterval.seconds(3), scheduler: MainScheduler.instance).withLatestFrom(threeDEnrollmentResult).flatMap { [unowned self] result in
                self.repository.retrieveACSResults(threeDSecureID: result.threeDSecureId)
        }.share()

        acsResultRequest.elements().subscribe(onNext: { [weak self] result in
            guard let `self` = self else { return }

            if let result = result {
                YAPProgressHud.hideProgressHud()
                if result == "Y" {
                    self.transferSubject.onNext(())
                } else {
                    self.errorSubject.onNext("Unable to verify")
                }
            } else {
                count += 1
                guard count < 5 else {
                    YAPProgressHud.hideProgressHud()
                    self.errorSubject.onNext("Unable to verify")
                    return
                }
                self.pollACSResultObserver.onNext(())
            }
        }).disposed(by: disposeBag)

        acsResultRequest.errors()
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
                .map { $0.localizedDescription }
                .bind(to: errorSubject)
                .disposed(by: disposeBag)

        transferSubject.withLatestFrom(Observable.combineLatest(checkoutSessionRequest.elements(), threeDEnrollmentResult)).subscribe(onNext: { [weak self] checkoutSession, threeDSecureResult in
            guard let `self` = self else { return }
            guard let amount = try? self.enteredAmountSubject.value() else { return }
            guard let orderID = checkoutSession.order?.id else { return }
            self.resultSubject.onNext((orderId: orderID, threeDSecureId: threeDSecureResult.threeDSecureId, amount: "\(amount)", currency: "AED", card: self.paymentCard))
        }).disposed(by: disposeBag)
    }
}

extension TopupTransferViewModel {
    
    // MARK: - Attributes strings
    private func getAttributedBalance(balance: String) -> NSMutableAttributedString {
        let balanceAttributedString = NSMutableAttributedString(string: String(format: "screen_topup_transfer_display_text_available_balance".localized, balance ), attributes: [
            .font: UIFont.systemFont(ofSize: 12.0, weight: .regular),
            .foregroundColor: UIColor.gray//UIColor.greyDark
        ])

        balanceAttributedString.addAttribute(.foregroundColor, value: UIColor.purple/*UIColor.primaryDark*/, range: NSRange(location: 26, length: balance.count))

        return balanceAttributedString
    }

    private func getAttributedFee(fee: String) -> NSMutableAttributedString {

        let text = String(format: "screen_topup_transfer_display_text_transaction_fee".localized, fee)

        let feeAttributedString = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 12.0, weight: .regular),
            .foregroundColor: UIColor.gray//UIColor.greyDark
        ])

        feeAttributedString.addAttribute(.foregroundColor, value: UIColor.purple/*UIColor.primaryDark*/, range: (text as NSString).range(of: fee))

        return feeAttributedString
    }

    // MARK: - Localizations
    func topupCardLocalizations(accountBalance: String) {
        availableBalanceSubject.onNext(getAttributedBalance(balance: accountBalance))
        
        screeTitleSubject.onNext("screen_topup_transfer_display_text_screen_title".localized)
        amountViewTitleSubject.onNext("screen_topup_transfer_display_text_amount_title".localized)

        feeSubject.subscribe(onNext: { [unowned self] fee in
            self.transactionFeeSubject.onNext(self.getAttributedFee(fee: CurrencyFormatter.formatAmountInLocalCurrency(fee ?? 0)))
        }).disposed(by: disposeBag)
    }
}
