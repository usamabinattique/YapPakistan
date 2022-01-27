//
//  Y2YFundsTransferViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 24/01/2022.
//

import Foundation
import YAPComponents
import YAPCore
import RxSwift


typealias Y2YFundsTransferResult = (contact: YAPContact, amount: Double)

protocol Y2YFundsTransferViewModelInput {
    var amountObserver: AnyObserver<String?> { get }
    var noteObserver: AnyObserver<String?> { get }
    var confirmObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
    var otpVerfified: AnyObserver<Void> { get }
    var closeObserver: AnyObserver<Void> { get }
}

protocol Y2YFundsTransferViewModelOutput {
    var userImage: Observable<(String?, UIImage?)> { get }
    var userName: Observable<String?> { get }
    var balance: Observable<NSAttributedString?> { get }
    var currency: Observable<String?> { get }
    var flag: Observable<UIImage?> { get }
    
    var showError: Observable<String> { get }
    var amountError: Observable<String?> { get }
    var confirmEnabled: Observable<Bool> { get }
    var isInputValid: Observable<Bool> { get }
    var fee: Observable<NSAttributedString?> { get }
    
    var result: Observable<(YAPContact, Double)> { get }
    
    var otpRequired: Observable<Y2YFundsTransferResult> { get }
    
    var allowedDecimalPlaces: Observable<Int> { get }
    var coolingTransactionReminderAlert: Observable<String?>{ get }
    var back: Observable<Void> { get }
    var noteError: Observable<String?> { get }
    var showsFlag: Observable<Bool> { get }
    var phoneNumber: Observable<String?> { get }
    var title: Observable<String?> { get }
    var close: Observable<Void> { get }
    var isPresented: Bool { get}
}

protocol Y2YFundsTransferViewModelType {
    var inputs: Y2YFundsTransferViewModelInput { get }
    var outputs: Y2YFundsTransferViewModelOutput { get }
}

class Y2YFundsTransferViewModel: Y2YFundsTransferViewModelType, Y2YFundsTransferViewModelInput, Y2YFundsTransferViewModelOutput {
    
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: Y2YFundsTransferViewModelInput { return self }
    var outputs: Y2YFundsTransferViewModelOutput { return self }
    let contact: YAPContact
    private let repository: Y2YRepositoryType
    
    
    private let amountSubject = PublishSubject<String?>()
    private let noteSubject = PublishSubject<String?>()
    private let confirmSubject = PublishSubject<Void>()
    private var transactionThreshold: TransactionThreshold = .mock
    private let otpVerfifiedSubject = PublishSubject<Void>()
    
    private let userImageSubject = BehaviorSubject<(String?, UIImage?)>(value: (nil, nil))
    private let userNameSubject = BehaviorSubject<String?>(value: nil)
    private let balanceSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    private let currencySubject = BehaviorSubject<String?>(value: "PKR")
    private let flagSubject = BehaviorSubject<UIImage?>(value: UIImage(named: "PK", in: .yapPakistan))
    private let feeSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    private let showErrorSubject = PublishSubject<String>()
    private let confirmEnabledSubject = BehaviorSubject<Bool>(value: false)
    private let resultSubject = PublishSubject<(YAPContact, Double)>()
    private let backSubject = PublishSubject<Void>()
    private let otpRequiredSubject = PublishSubject<Y2YFundsTransferResult>()
    private let amountErrorSubject = PublishSubject<String?>()
    private let allowedDecimalSucject: BehaviorSubject<Int>
    private let coolingTransactionReminderAlertSubject = PublishSubject<String?>()
    private let noteErrorSubject = BehaviorSubject<String?>(value: nil)
    private let showsFlagSubject: BehaviorSubject<Bool>
    private let phoneNumberSubject: BehaviorSubject<String?>
    private let titleSubject: BehaviorSubject<String?>
    private let closeSubject = PublishSubject<Void>()
    
    private let thresholdRes = ReplaySubject<TransactionThresholdResponse>.create(bufferSize: 1)
    private let feeRes = ReplaySubject<TransactionProductCodeFeeResponse>.create(bufferSize: 1)
    private let limitRes = ReplaySubject<TransactionLimit>.create(bufferSize: 1)
    private let customerBalanceRes = ReplaySubject<CustomerBalanceResponse>.create(bufferSize: 1)
    
    
    // MARK: - Inputs
    var amountObserver: AnyObserver<String?> { return amountSubject.asObserver() }
    var noteObserver: AnyObserver<String?> { return noteSubject.asObserver() }
    var confirmObserver: AnyObserver<Void> { return confirmSubject.asObserver() }
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    var otpVerfified: AnyObserver<Void> { otpVerfifiedSubject.asObserver() }
    var closeObserver: AnyObserver<Void> { return closeSubject.asObserver() }
    
    // MARK: - Outputs
    var userImage: Observable<(String?, UIImage?)> { return userImageSubject.asObservable() }
    var userName: Observable<String?> { return userNameSubject.asObservable() }
    var balance: Observable<NSAttributedString?> { return balanceSubject.asObservable() }
    var currency: Observable<String?> { return currencySubject.asObservable() }
    var flag: Observable<UIImage?> { return flagSubject.asObservable() }
    var showError: Observable<String> { return showErrorSubject.asObservable() }
    var confirmEnabled: Observable<Bool> { return confirmEnabledSubject.asObservable() }
    var result: Observable<(YAPContact, Double)> { return resultSubject.asObservable() }
    var isInputValid: Observable<Bool> { return Observable.merge(amountSubject.map { _ in true }, showError.map { _ in false })}
    var fee: Observable<NSAttributedString?> { feeSubject.asObservable() }
    var otpRequired: Observable<Y2YFundsTransferResult> { otpRequiredSubject.asObservable() }
    var amountError: Observable<String?> { amountErrorSubject.asObservable() }
    var allowedDecimalPlaces: Observable<Int> { allowedDecimalSucject.asObservable() }
    var coolingTransactionReminderAlert: Observable<String?>{ return coolingTransactionReminderAlertSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var noteError: Observable<String?> { noteErrorSubject.asObservable() }
    var showsFlag: Observable<Bool> { showsFlagSubject.asObservable() }
    var phoneNumber: Observable<String?> { phoneNumberSubject.asObservable() }
    var title: Observable<String?> { titleSubject.asObservable() }
    var close: Observable<Void> { return closeSubject.asObservable() }
    
    private var transferFee = TransferFee.mock
    private var transactionRange = 0.1...100.0
    private var coolingPeriod = BeneficiaryCoolingPeriod.mock
    private let transferType: TransferType
    private var container: UserSessionContainer!
    private let isPresentedSubject: Bool
    var isPresented: Bool { isPresentedSubject }
    
    // MARK: - Init
    init(_ contact: YAPContact,
         repository: Y2YRepositoryType,
         transferType: TransferType, container: UserSessionContainer, presented: Bool) {
        self.contact = contact
        self.repository = repository
        self.transferType = transferType
        self.container = container
        self.isPresentedSubject = presented
        
        showsFlagSubject = BehaviorSubject(value: transferType == .yapContact)
        phoneNumberSubject = BehaviorSubject(value: contact.formattedPhoneNumber)
        allowedDecimalSucject = BehaviorSubject(value: CurrencyFormatter.decimalPlaces(for: "PKR"))
        titleSubject = BehaviorSubject(value: transferType.title)

      /*
        SessionManager.current.currentBalance
            .map { balance -> NSAttributedString in
                let balance = balance.formattedBalance()
                let text = String.init(format: "screen_y2y_funds_transfer_display_text_balance".localized, balance)
                let attributed = NSMutableAttributedString(string: text)
                attributed.addAttributes([.foregroundColor: UIColor.primaryDark], range: NSRange(location: text.count - balance.count, length: balance.count))
                return attributed as NSAttributedString }
            .bind(to: balanceSubject).disposed(by: disposeBag) */
        
        customerBalanceRes.map { balance -> NSAttributedString in
            let blnceFormatted = String(format: "%.2f", balance.currentBalance)
            let balance = "PKR \(blnceFormatted)"
            let text = String.init(format: "screen_y2y_funds_transfer_display_text_balance".localized, balance)
           
            print("balance is \(balance)")
            let attributed = NSMutableAttributedString(string: text)
            attributed.addAttributes([.foregroundColor: UIColor.darkText], range: NSRange(location: text.count - balance.count, length: balance.count))
            return attributed as NSAttributedString }
        .bind(to: balanceSubject).disposed(by: disposeBag)
        
        
        userImageSubject.onNext((contact.photoUrl, contact.thumbnailImage ?? contact.name.initialsImage(color: .green)))//.secondaryGreen)))
        userNameSubject.onNext(contact.name)
        
        verifications()
        confirm(transferType: transferType)
        handleErrors()
        fetchData()
        
        confirmSubject
            .withLatestFrom(currencySubject).unwrap().subscribe(onNext: { currency in
                switch transferType {
                case .qrCode:
                    print(".qrCode")
             //       AppAnalytics.shared.logEvent(QRCodeEvent.paymentViaQrCode())
                case .yapContact:
                    print(".yapContact")
               //     AppAnalytics.shared.logEvent(Y2YEvent.confirmYtY(["yty_currency":currency]))
                }
            }).disposed(by: disposeBag)
    }
}

private extension Y2YFundsTransferViewModel {
    func verifications() {
        let validNote = noteSubject.map{ ValidationService.shared.validateTransactionRemarks($0) }
        Observable.combineLatest(amountSubject.map { Double($0 ?? "") ?? 0 }, amountErrorSubject, validNote)
            .map{ $0.0 > 0.0 && $0.1 == nil && $0.2 }
            .bind(to: confirmEnabledSubject)
            .disposed(by: disposeBag)
        
        validNote
            .map{ $0 ? nil : "Please remove special characters to continue" }
            .bind(to: noteErrorSubject)
            .disposed(by: disposeBag)
    }
    
    func confirm(transferType: TransferType) {
        
        let coolingPeriodOver = confirmSubject.withLatestFrom(amountSubject).map{ Double($0 ?? "") ?? 0.0 }.map{ [unowned self] in self.coolingPeriod.isCoolingPeriodOver || $0 <= self.coolingPeriod.remainingLimit }
        
        coolingPeriodOver.filter{ !$0 }.withLatestFrom(amountSubject).unwrap().subscribe(onNext: {[weak self] enteredAmount in
            self?.coolingPeriodTransactionReminder(amount: enteredAmount)
        }).disposed(by: disposeBag)
        
        
        let result = coolingPeriodOver.filter{ $0 }.map{ _ in self.amountSubject.map{ Double($0 ?? "") ?? 0.0 }.map{ $0 <= self.coolingPeriod.remainingLimit }.map{ $0 || self.coolingPeriod.isCoolingPeriodOver }}
        
        
        let doneError = result.withLatestFrom(Observable.combineLatest(customerBalanceRes.map{$0.currentBalance}, amountSubject.map { Double($0 ?? "") ?? 0 }, noteSubject))
        
        
        let confiremdAmount = confirmSubject.withLatestFrom(doneError)
        
        let verifiedAmount = confiremdAmount.filter{ [unowned self] _, amount, _ in amount >= self.transactionRange.lowerBound }
        
//        confiremdAmount.filter{ [unowned self] _, amount, _ in amount < self.transactionRange.lowerBound }.map{ [unowned self] _ in String.init(format: "common_display_text_transaction_limit_error".localized, "AED \(self.transactionRange.lowerBound.formattedAmount)", "AED \(self.transactionRange.upperBound.formattedAmount)") }.bind(to: amountErrorSubject).disposed(by: disposeBag)
        
        verifiedAmount
         .filter{ [unowned self] _, amount, _ in amount > self.transactionThreshold.y2yOTPRemainingLimit }
            .map{ [unowned self] _, amount, _ -> Y2YFundsTransferResult in (contact: self.contact, amount: amount)}
            .bind(to: otpRequiredSubject)
            .disposed(by: disposeBag)
        
//        let fundsTransferRequest = Observable.merge(verifiedAmount.filter{ [unowned self] _, amount, _ in amount <= self.transactionThreshold.y2yOTPRemainingLimit }, otpVerfifiedSubject.withLatestFrom(verifiedAmount))
//            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
//            .flatMap { [unowned self] in
//                self.repository.tranferFunds(uuid: self.contact.yapAccountDetails?.first?.uuid ?? "", name: self.contact.name, amount: String($0.1), note: $0.2) }
//            .share()
//            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
        
//        fundsTransferRequest.errors().subscribe(onNext: { [weak self] in self?.amountErrorSubject.onNext($0.localizedDescription) }).disposed(by: disposeBag)
//
//        Observable.combineLatest(fundsTransferRequest.elements().map { [unowned self] _ in self.contact }, amountSubject.map { Double($0 ?? "") ?? 0 })
//            .map { ($0.0, $0.1) }
//            .do(onNext: { _ in
//                SessionManager.current.refreshBalance()
//                AppAnalytics.shared.logEvent(transferType == .qrCode ? SendMoneyEvent.sendMoneyViaQR() : SendMoneyEvent.yaptoyap())
//            })
//            .bind(to: resultSubject)
//            .disposed(by: disposeBag)
    }
    
    func fetchData() {
        YAPProgressHud.showProgressHud()
        
        let getThreshold = repository.getThresholdLimits()
        let getCustomerBalance = repository.fetchCustomerAccountBalance()
        let getTransactionLimit = repository.getTransactionProductLimit(transactionProductCode: "P003")
        let getFee = repository.getFee(productCode: "P003")
        
        let zipped = Observable.zip(getThreshold, getCustomerBalance,getTransactionLimit,getFee)
        getThreshold.do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .flatMap{ _ in zipped.materialize() }
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() } )
            .subscribe(onNext: { [unowned self] materializeEvent in
                
                switch materializeEvent {
                case let .next((thresholdRes, customerBalanceRes, transactionLimtRes,feeRes)):
                    if let thRes = thresholdRes.element, let blnce = customerBalanceRes.element, let limit = transactionLimtRes.element, let fee = feeRes.element {
                        self.thresholdRes.onNext(thRes)
                        self.customerBalanceRes.onNext(blnce)
                        self.limitRes.onNext(limit)
                        self.feeRes.onNext(fee)
                    }
                    
                case let .error(error):
                    print("error \(error)")
                case .completed: break
                }
            }).disposed(by: disposeBag)
        //request.share()
        
       // requestShare.errors().map { $0.localizedDescription }.bind(to: errorSubject).disposed(by: disposeBag)
       /* requestShare.errors().subscribe(onNext: { [unowned self] error in
           print("error")
        }).disposed(by: disposeBag)
        
        
        requestShare.elements().subscribe(onNext: { [unowned self] res in
            print(res)
           // print(res.currency)
        }).disposed(by: disposeBag) */
        
//        YAPProgressHud.showProgressHud()
        
  //      let request = repository.fee(productCode: TransactionProductCode.y2yTransfer.rawValue).share()
       // amountSubject.onNext("12.0")
        
        Observable.combineLatest(amountSubject.map{ Double($0 ?? "") ?? 0 }, feeRes).map { (amount,fee) -> NSAttributedString in
            let amountFormatted = String(format: "%.2f", fee.fixedAmount)
            let amount = "PKR \(amountFormatted)"
            let text = String.init(format: "screen_y2y_funds_transfer_display_text_fee".localized, amount)
            
//                let attributed = NSMutableAttributedString(string: text)
//                attributed.addAttributes([.foregroundColor : UIColor.primaryDark], range: NSRange(location: (text as NSString).range(of: amount).location, length: amount.count))
            let attributed = NSMutableAttributedString(string: text)
            attributed.addAttributes([.foregroundColor : UIColor.darkText], range: NSRange(location: (text as NSString).range(of: amount).location, length: amount.count))
            return attributed as NSAttributedString }.bind(to: feeSubject).disposed(by: disposeBag)
        
     /*   Observable.combineLatest(amountSubject.map{ Double($0 ?? "") ?? 0 }, request.elements().do(onNext: { [unowned self] in self.transferFee = $0 }))
            .map {
                let amount = "PKR \($0.1.getTaxedFee(for: $0.0).formattedAmount)"
                let text = String.init(format: "screen_y2y_funds_transfer_display_text_fee".localized, amount)
                
//                let attributed = NSMutableAttributedString(string: text)
//                attributed.addAttributes([.foregroundColor : UIColor.primaryDark], range: NSRange(location: (text as NSString).range(of: amount).location, length: amount.count))
                let attributed = NSMutableAttributedString(string: text)
                attributed.addAttributes([.foregroundColor : UIColor.darkText], range: NSRange(location: (text as NSString).range(of: amount).location, length: amount.count))
                return attributed as NSAttributedString }
            .bind(to: feeSubject)
            .disposed(by: disposeBag) */
      
     /*   amountSubject.map{ Double($0 ?? "") ?? 0 }.map { doubleValue -> NSAttributedString in
            
            let amount = "PKR \(doubleValue)"
            let text = String.init(format: "screen_y2y_funds_transfer_display_text_fee".localized, amount)
            let attributed = NSMutableAttributedString(string: text)
            attributed.addAttributes([.foregroundColor : UIColor.darkText], range: NSRange(location: (text as NSString).range(of: amount).location, length: amount.count))
            return attributed as NSAttributedString
        }.bind(to: feeSubject).disposed(by: disposeBag) */
        let v: NSAttributedString = NSAttributedString(string: "PKR 12.0")
//        if #available(iOS 15, *) {
//             v =  NSAttributedString(AttributedString("12.0"))
//        } else {
//            // Fallback on earlier versions
//            v = NSAttributedString(string: "12.0")
//        }
      
        
//        let dailyLimitRequest = repository.transactionThresholds().share()
        
//        dailyLimitRequest.elements().subscribe(onNext: { [unowned self] in self.transactionThreshold = $0 }).disposed(by: disposeBag)
        
//        Observable.merge(request.errors(), dailyLimitRequest.errors())
//            .subscribe(onNext: { [weak self] in self?.showErrorSubject.onNext($0.localizedDescription) })
//            .disposed(by: disposeBag)
        
//        let transactionLimitRequest = self.repository.fetchTransactionLimits(productCode: TransactionProductCode.y2yTransfer, accountUuid: SessionManager.current.currentProfile?.uuid ?? "").share()
//
//        transactionLimitRequest.errors().subscribe(onNext: { [unowned self] in self.showErrorSubject.onNext($0.localizedDescription) }).disposed(by: disposeBag)
//        transactionLimitRequest.elements().subscribe(onNext: { [unowned self] in
//            let min = Double($0.min) ?? 0
//            let max = Double($0.max) ?? 0
//            self.transactionRange = min...max
//        }).disposed(by: disposeBag)
//
//        let coolingPeriodRequest = repository.getCoolingPeriod(accoundUUID: contact.yapAccountDetails?.first?.uuid ?? "").share()
        
//        coolingPeriodRequest.errors().subscribe(onNext: { [unowned self] in self.showErrorSubject.onNext($0.localizedDescription) }).disposed(by: disposeBag)
//
//        coolingPeriodRequest.elements().subscribe(onNext: { [unowned self] in self.coolingPeriod = $0 }).disposed(by: disposeBag)
//
//        Observable.zip(request.map{ _ in }, dailyLimitRequest.map{ _ in }, transactionLimitRequest.map{ _ in }).subscribe(onNext: { _ in YAPProgressHud.hideProgressHud() }).disposed(by: disposeBag)
    }
    
    func coolingPeriodTransactionReminder(amount: String) {
        
        let message = String(format: "You can only send up to %@ at this time. To transfer bigger amounts, please wait for %d hours from the time you \nadded %@.\n\n", CurrencyFormatter.formatAmountInLocalCurrency(self.coolingPeriod.remainingLimit), Int(self.coolingPeriod.coolingPeriodDuration), contact.name)
        
      //  YAPProgressHud.showProgressHud()
//        let coolingTransactionReminderRequest = repository.coolingPeriodTransactionReminder(for: String(contact.yapAccountDetails?.first?.uuid ?? ""), beneficiaryCreationDate: "", beneficiaryName: contact.name, amount: amount).share()
        
        
//        coolingTransactionReminderRequest
//            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
//            .elements()
//            .map{_ in message }
//            .bind(to: coolingTransactionReminderAlertSubject)
//            .disposed(by: disposeBag)
//
//        coolingTransactionReminderRequest
//            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
//            .errors()
//            .map{ $0.localizedDescription }
//            .bind(to: showErrorSubject)
//            .disposed(by: disposeBag)
    }
}

// MARK: Error handling

private extension Y2YFundsTransferViewModel {
    func handleErrors() {
        Observable.combineLatest(customerBalanceRes, amountSubject.map{ Double($0 ?? "") ?? 0 })
            .map{ [unowned self] in self.getError(forAmount: $0.1, availableBalance: $0.0.currentBalance) }
            .bind(to: amountErrorSubject)
            .disposed(by: disposeBag)
    }
    
    func getError(forAmount amount: Double, availableBalance balance: Double) -> String? {
        let fee = transferFee.getTaxedFee(for: amount)
        
        guard amount + fee <= balance else {
            return String.init(format: "common_display_text_available_balance_error".localized, CurrencyFormatter.formatAmountInLocalCurrency(amount))
        }
        
        guard amount <= transactionThreshold.dailyRemainingLimit else {
            return transactionThreshold.dailyRemainingLimit <= 0 ? "common_display_text_daily_limit_error_limit_reached".localized : amount > self.transactionThreshold.dailyLimit ? "common_display_text_daily_limit_error_single_transaction".localized : "common_display_text_daily_limit_error_multiple_transactions".localized
        }
        
        //        guard coolingPeriod.isCoolingPeriodOver || amount <= coolingPeriod.remainingLimit else {
        //            return coolingPeriod.remainingLimit <= 0 ?
        //                String.init(format: "common_display_text_cooling_period_limit_consumed_error".localized, String.init(format: "%0.0f", coolingPeriod.coolingPeriodDuration), contact.name) :
        //                String.init(format: "common_display_text_cooling_period_limit_error".localized, CurrencyFormatter.formatAmountInLocalCurrency(coolingPeriod.remainingLimit), String.init(format: "%0.0f", coolingPeriod.coolingPeriodDuration), contact.name)
        //        }
        
        guard amount <= transactionRange.upperBound else {
            return String.init(format: "common_display_text_transaction_limit_error".localized, "AED \(transactionRange.lowerBound.formattedAmount)", "PKR \(transactionRange.upperBound.formattedAmount)")
        }
        
        return nil
    }
}

fileprivate extension TransferType {
    var title: String {
        switch self {
        case .yapContact:
            return "screen_y2y_funds_transfer_display_text_title_yap_contact".localized
        case .qrCode:
            return "screen_y2y_funds_transfer_display_text_title_qr_contact".localized
        }
    }
}
