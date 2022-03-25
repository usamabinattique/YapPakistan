//
//  SendMoneyFundsTransferViewModel.swift
//  YAP
//
//  Created by Zain on 15/10/2019.
//  Copyright © 2019 YAP. All rights reserved.


import Foundation
import RxSwift
import YAPComponents
import RxDataSources

typealias FeeCharges = (fee: Double, vat: Double)

typealias SendMoneyTransactionResult = (beneficiary: SendMoneyBeneficiary, sourceAmount: Double, sourceCurrency: String, destinationAmount: Double?, destinationCurrency: String?, conversionRate: String, referenceNumber: String, charges: FeeCharges?, reason: TransferReason?, notes: String?, transactionThreshold: TransactionThreshold, postCutoff: Bool, willGetHeld: Bool, cutoffMessage: String?, isCbwsi: Bool)

protocol SendMoneyFundsTransferViewModelInput {
    var doneObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
    var otpVerifiedObsever: AnyObserver<Void> { get }
    var reasonSelectedObserver: AnyObserver<TransferReason> { get }
}

protocol SendMoneyFundsTransferViewModelOutput {
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }

    var doneEnabled: Observable<Bool> { get }
    var back: Observable<Void> { get }
    var showError: Observable<String> { get }
    var amountError: Observable<String?> { get }
    var title: Observable<String?> { get }
    var showActivity: Observable<Bool> { get }
    var otp: Observable<(beneficiary: SendMoneyBeneficiary, amount: Double)> { get }
    var result: Observable<SendMoneyTransactionResult> { get }
    var selectReason: Observable<[TransferReasonType]> { get }
    var coolingTransactionReminderAlert: Observable<String?>{ get }
}

protocol SendMoneyFundsTransferViewModelType {
    var inputs: SendMoneyFundsTransferViewModelInput { get }
    var outputs: SendMoneyFundsTransferViewModelOutput { get }
}

class SendMoneyFundsTransferViewModel: SendMoneyFundsTransferViewModelType, SendMoneyFundsTransferViewModelInput, SendMoneyFundsTransferViewModelOutput {

    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: SendMoneyFundsTransferViewModelInput { return self }
    var outputs: SendMoneyFundsTransferViewModelOutput { return self }
    private var accountProvider: AccountProvider?

    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let otpSubject = PublishSubject<(beneficiary: SendMoneyBeneficiary, amount: Double)>()
    private let otpVerifiedSubject = PublishSubject<Void>()
    private let resultSubject = PublishSubject<SendMoneyTransactionResult>()
    private let coolingTransactionReminderAlertSubject = PublishSubject<String?>()

    let doneSubject = PublishSubject<Void>()
    let doneEnabledSubject = BehaviorSubject<Bool>(value: false)
    private let showErrorSubject = PublishSubject<String>()
    let amountErrorSubject = PublishSubject<String?>()
    private let backSubject = PublishSubject<Void>()
    let titleSubject = BehaviorSubject<String?>(value: nil)
    let showActivitySubject = BehaviorSubject<Bool>(value: false)
    let conversionRate = BehaviorSubject<String>(value: String(CurrencyFormatter.formatAmountInLocalCurrency(1).split(separator: " ").last ?? ""))
    let selectReasonSubject = PublishSubject<[TransferReasonType]>()
    let reasonSelectedSubject = PublishSubject<TransferReason>()

    var beneficiary: SendMoneyBeneficiary!
    var viewModels: [ReusableTableViewCellViewModelType] = []
    var repository : YapItRepository!

    let tranferFee = BehaviorSubject<TransferFee>(value: TransferFee.mock)
    var transactionRange = 0.1...100.0
    var tranferReasons: [TransferReason]!
    let reasonsSubject = PublishSubject<[TransferReasonType]>()
    var selectedReason: TransferReason?
    var coolingPeriod = BeneficiaryCoolingPeriod.mock

    // MARK: - Inputs
    var doneObserver: AnyObserver<Void> { return doneSubject.asObserver() }
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    var otpVerifiedObsever: AnyObserver<Void> { otpVerifiedSubject.asObserver() }
    var reasonSelectedObserver: AnyObserver<TransferReason> { reasonSelectedSubject.asObserver() }

    // MARK: - Outputs
    var doneEnabled: Observable<Bool> { return doneEnabledSubject.asObservable() }
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    var back: Observable<Void> { return backSubject.asObservable() }
    var showError: Observable<String> { return showErrorSubject.asObservable() }
    var title: Observable<String?> { return titleSubject.asObservable() }
    var showActivity: Observable<Bool> { return showActivitySubject.asObservable() }
    var otp: Observable<(beneficiary: SendMoneyBeneficiary, amount: Double)> { return otpSubject.asObservable() }
    var result: Observable<SendMoneyTransactionResult> { return resultSubject.asObservable() }
    var amountError: Observable<String?> { amountErrorSubject.asObservable() }
    let enteredAmount = PublishSubject<Double>()
    var selectReason: Observable<[TransferReasonType]> { selectReasonSubject.asObservable() }
    var coolingTransactionReminderAlert: Observable<String?>{ return coolingTransactionReminderAlertSubject.asObservable() }

    var currentAmount: Double = 0
    var currentNote: String? = nil
    var currentCharges: FeeCharges = (0, 0)
    var currentRate: String  = "1.00"
    var destinationAmount: Double = 0
    var transactionThreshold: TransactionThreshold = .empty
    private var cutoffMessage: String?
    var temp = false

    var transactionMightGetHeld: Bool = false
    var transactionWillGetHeld: Bool = false

    // MARK: - Init
    init(beneficiary: SendMoneyBeneficiary, sendMoneyType: SendMoneyType, repository: YapItRepository) {
        self.beneficiary = beneficiary
        self.repository = repository
//        self.accountProvider = accountProvider
        generateCellViewModels()
        loadCells()
//        makeTransaction()
        handleErrors()

//        reasonSelectedSubject.subscribe(onNext: { [weak self] in
//            self?.selectedReason = $0
//        }).disposed(by: disposeBag)

//        SessionManager.current.currentBalance.subscribe(onNext: { (balance) in
//            print(balance.amount)
//        }).disposed(by: disposeBag)
    }

    func generateCellViewModels() {
        fatalError("'generateCellViewModels()' not implementd")
    }
    
    internal func loadCells() {
        dataSourceSubject.onNext([SectionModel(model: 0, items: viewModels)])
    }
}

extension SendMoneyFundsTransferViewModel {
    func productCode(for beneficiaryType: SendMoneyBeneficiaryType) -> TransactionProductCode {
        switch beneficiaryType {
        case .domestic:
            return TransactionProductCode.domestic
        case .cashPayout:
            return TransactionProductCode.cashPayout
        case .rmt:
            return TransactionProductCode.rmt
        case .swift:
            return TransactionProductCode.swift
        case .uaefts:
            return TransactionProductCode.uaeftsTransfer
        case .IBFT:
            return TransactionProductCode.domestic
        }
    }
}

//// MARK: Data fetching
//
//extension SendMoneyFundsTransferViewModel {
//
//    func fetchTransactionLimit() -> Observable<Void> {
//        let transactionLimitRequest = self.repository.fetchTransactionLimits(productCode: productCode(for: beneficiary.type ?? .domestic)).share()
//
//        transactionLimitRequest.errors().subscribe(onNext: { [unowned self] in self.showErrorSubject.onNext($0.localizedDescription) }).disposed(by: disposeBag)
//        transactionLimitRequest.elements().subscribe(onNext: { [unowned self] in
//            let min = Double($0.min) ?? 0
//            let max = Double($0.max) ?? 0
//            self.transactionRange = min...max
//        }).disposed(by: disposeBag)
//
//        return transactionLimitRequest.flatMap{ [unowned self] _ in self.fetchTransactionLimitForCountry() }
//    }
//
//    func fetchTransactionFee() -> Observable<Void> {
//
//        let feeRequest = repository.getTransferFee(productCode: productCode(for: beneficiary.type ?? .domestic), country: beneficiary.country ?? "AE", currency: (beneficiary.type == .swift || beneficiary.type == .rmt) ? beneficiary.currency ?? "AED" : nil).share()
//
//        feeRequest.errors().subscribe(onNext: { [unowned self] in self.showErrorSubject.onNext($0.localizedDescription) }).disposed(by: disposeBag)
//
//        feeRequest.elements().map{ $0 == nil ? TransferFee.mock : $0! }.bind(to: tranferFee).disposed(by: disposeBag)
//
//        return feeRequest.map { _ in }
//    }
//
//    func fetchTransactionReasons() -> Observable<Void> {
//        let reasonsRequest = repository.fetchTransferReasons(productCode: productCode(for: beneficiary.type ?? .domestic)).share()
//
//        reasonsRequest.errors().subscribe(onNext: { [unowned self] in self.showErrorSubject.onNext($0.localizedDescription) }).disposed(by: disposeBag)
//
//        reasonsRequest.elements()
//            .map { $0.filter { $0.code != nil } }
//            .do(onNext: { [unowned self] in self.tranferReasons = $0 })
//            .map{ reasons in
//                var reasonTypes = [TransferReasonType]()
//
//                var reasonsWithoutCategory = reasons.filter{ $0.category == nil }
//                let reasonsWithCategory = reasons.filter{ $0.category != nil }
//
//                let groups = Dictionary(grouping: reasonsWithCategory, by: { $0.category })
//
//                reasonsWithoutCategory.append(contentsOf: groups.filter{ $0.1.count == 1 && $0.1.first?.category == $0.1.first?.title }.flatMap{ $0.1 })
//
//                groups.filter{ $0.1.count > 1 || $0.1.first?.category != $0.1.first?.title }
//                    .forEach { (category, reasons) in
//                        reasonTypes.append(TransferReasonCategory(categoryName: category ?? "", reasons: reasons)) }
//
//                reasonTypes.append(contentsOf: reasonsWithoutCategory)
//
//                return reasonTypes.sorted(by: { $0.title < $1.title }) }
//            .bind(to: reasonsSubject)
//            .disposed(by: disposeBag)
//
//        return reasonsRequest.map { _ in }
//    }
//
//    func fetchTransactionLimitForCountry() -> Observable<Void> {
//        let countryLimitRequest = repository.transactionLimitForCountryAndCurrency(countryCode: beneficiary.country ?? "AE", currencyCode: beneficiary.currency).share()
//
//        countryLimitRequest.errors().subscribe(onNext: { [unowned self] in self.showErrorSubject.onNext($0.localizedDescription) }).disposed(by: disposeBag)
//
//        countryLimitRequest.elements()
//            .map{ Double($0 ?? "0") ?? 0 }
//            .filter{ $0 > 0 }
//            .subscribe(onNext: { [unowned self] in
//                let min: Double = self.transactionRange.lowerBound <= $0 ? self.transactionRange.lowerBound : 1.0
//                let max: Double = $0
//                self.transactionRange = min...max })
//            .disposed(by: disposeBag)
//
//        return countryLimitRequest.map{ _ in }
//    }
//
//    func fetchTransactionThresholds() -> Observable<Void> {
//        let dailyLimitRequest = repository.transactionThresholds().share()
//
//        dailyLimitRequest.errors().subscribe(onNext: { [unowned self] in self.showErrorSubject.onNext($0.localizedDescription) }).disposed(by: disposeBag)
//
//        dailyLimitRequest.elements().subscribe(onNext: { [unowned self] in self.transactionThreshold = $0 }).disposed(by: disposeBag)
//
//        let cutOffResult = dailyLimitRequest.elements()
//            .filter{ [unowned self] _ in self.beneficiary.type == .swift || self.beneficiary.type == .uaefts }
//            .flatMap{ [unowned self] in self.getCutoffMessage(amount: $0.cbwsiLimit + 100, isCbwsi: false) }
//            .share()
//            .map{ _ in }
//
//        return Observable.merge(cutOffResult,
//                                dailyLimitRequest
//                                    .filter{ [unowned self] _ in self.beneficiary.type != .swift && self.beneficiary.type != .uaefts }.map{ _ in }
//        )
//    }
//
//    func getFxRate() -> Observable<Void> {
//
//        let conversionRequest = self.repository.getFxRate(productCode: productCode(for: beneficiary.type ?? .domestic), beneficiaryId: String(self.beneficiary.id!)).share()
//
//        conversionRequest.errors().subscribe(onNext: { [unowned self] in self.showErrorSubject.onNext($0.localizedDescription) }).disposed(by: disposeBag)
//
//        conversionRequest.elements()
//            .map { $0.fxRates.first?.rate ?? "1.00" }
//            .do(onNext: { [unowned self] in self.currentRate = $0 })
//            .map { $0.replace(string: ".", replacement: localeNumberFormatter.currencyDecimalSeparator) }
//            .debug("Conversion rate")
//            .bind(to: conversionRate).disposed(by: disposeBag)
//
//        return conversionRequest.map { _ in }
//    }
//
//    func getCutoffMessage(amount: Double, isCbwsi: Bool) -> Observable<Void> {
//        let cutoffMessageReqeust = repository.cutOfftime(productCode: beneficiary.type?.productCode ?? .domestic, currency: beneficiary.currency ?? "AED", amount: amount, isCbwsi: isCbwsi).share()
//
//        cutoffMessageReqeust.errors().subscribe(onNext: { [unowned self] in self.showErrorSubject.onNext($0.localizedDescription) }).disposed(by: disposeBag)
//
//        cutoffMessageReqeust.elements()
//            .do(onNext: { [unowned self] in self.cutoffMessage = $0?.message })
//            .map{ $0?.message != nil }
//            .subscribe(onNext: { [unowned self] in self.transactionMightGetHeld = $0 })
//            .disposed(by: disposeBag)
//
//        return cutoffMessageReqeust.map{ _ in }
//
//    }
//
//    func getCoolingPeriod() -> Observable<Void> {
//        let coolingPeriodRequest = repository.getCoolingPeriod(for: String(beneficiary.id ?? 0), productCode: beneficiary.type?.productCode.rawValue ?? SendMoneyBeneficiaryType.domestic.productCode.rawValue).share()
//
//        coolingPeriodRequest.errors().subscribe(onNext: { [unowned self] in self.showErrorSubject.onNext($0.localizedDescription) }).disposed(by: disposeBag)
//
//        coolingPeriodRequest.elements().subscribe(onNext: { [unowned self] in self.coolingPeriod = $0 }).disposed(by: disposeBag)
//
//        return coolingPeriodRequest.map{ _ in }
//    }
//
//    func coolingPeriodTransactionReminder() {
//
//        let message = String(format: "You can only send up to %@ at this time. To transfer bigger amounts, please wait for %d hours from the time you \nadded %@.\n\n", CurrencyFormatter.formatAmountInLocalCurrency(self.coolingPeriod.remainingLimit), Int(self.coolingPeriod.coolingPeriodDuration), beneficiary.fullName)
//
//        YAPProgressHud.showProgressHud()
//        let coolingTransactionReminderRequest = repository.coolingPeriodTransactionReminder(for: String(beneficiary.id ?? 0), beneficiaryCreationDate: beneficiary.beneficiaryCreationDate ?? "", beneficiaryName: beneficiary.name, amount: String(currentAmount) ).share()
//
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
//    }
//}
//
//// MARK: Error handling

private extension SendMoneyFundsTransferViewModel {
    func handleErrors() {
//        Observable.combineLatest(self.accountProvider?.currentAccount.balance, enteredAmount, tranferFee, reasonSelectedSubject.startWith(.mocked))
//            .do(onNext: { [unowned self] in self.currentAmount = $0.1 })
//            .map{ [unowned self] in self.getError(forAmount: $0.1, availableBalance: $0.0, transferFee: $0.2, selectedReason: $0.3) }
//            .bind(to: amountErrorSubject)
//            .disposed(by: disposeBag)
    }
//
//    func getError(forAmount amount: Double, availableBalance balance: Balance, transferFee: TransferFee, selectedReason: TransferReason) -> String? {
//        let fee = transferFee.getTaxedFee(for: amount)
//        guard amount + fee <= balance.amount else {
//            return String.init(format: "common_display_text_available_balance_error".localized, CurrencyFormatter.formatAmountInLocalCurrency(amount))
//        }
//
//        transactionWillGetHeld = (transactionMightGetHeld &&
//            (beneficiary.type == .swift ||
//                (beneficiary.type == .uaefts &&
//                    ( !selectedReason.isCBWSI || amount > transactionThreshold.cbwsiLimit || !(beneficiary.cbwsiCompliant ?? false) )
//                )
//            )
//        )
//
//        if transactionWillGetHeld && !transactionThreshold.holdAmountIncludedInDebitAmount {
//            guard amount <= transactionThreshold.onHoldDailyRemainingLimit else {
//                return transactionThreshold.onHoldDailyRemainingLimit <= 0 ? "common_display_text_daily_limit_error_limit_reached".localized : String.init(format: "common_display_text_on_hold_limit_error".localized, CurrencyFormatter.formatAmountInLocalCurrency(transactionThreshold.onHoldDailyRemainingLimit) )
//            }
//        } else {
//            guard amount <= transactionThreshold.dailyRemainingLimit else {
//                return  transactionThreshold.dailyRemainingLimit <= 0 ? "common_display_text_daily_limit_error_limit_reached".localized : amount > self.transactionThreshold.dailyLimit ? "common_display_text_daily_limit_error_single_transaction".localized : "common_display_text_daily_limit_error_multiple_transactions".localized
//            }
//        }
//
//        //        guard coolingPeriod.isCoolingPeriodOver || amount <= coolingPeriod.remainingLimit else {
//        //            return coolingPeriod.remainingLimit <= 0 ?
//        //            String.init(format: "common_display_text_cooling_period_limit_consumed_error".localized, String.init(format: "%0.0f", coolingPeriod.coolingPeriodDuration), beneficiary.fullName) :
//        //            String.init(format: "common_display_text_cooling_period_limit_error".localized, CurrencyFormatter.formatAmountInLocalCurrency(coolingPeriod.remainingLimit), String.init(format: "%0.0f", coolingPeriod.coolingPeriodDuration), beneficiary.fullName)
//        //        }
//
//        guard amount <= transactionRange.upperBound else {
//            return String.init(format: "common_display_text_transaction_limit_error".localized, "AED \(transactionRange.lowerBound.formattedAmount)", "AED \(transactionRange.upperBound.formattedAmount)")
//        }
//
//        return nil
//    }
}
//
//// MARK: Transactions APIs
//
//extension SendMoneyFundsTransferViewModel {
//    func makeTransaction() {
//
//        let coolingPeriodOver = doneSubject.map{ [unowned self] in self.coolingPeriod.isCoolingPeriodOver || self.currentAmount <= self.coolingPeriod.remainingLimit }
//
//        coolingPeriodOver.filter{ !$0 }.subscribe(onNext: {[weak self] _ in
//            self?.coolingPeriodTransactionReminder()
//        }).disposed(by: disposeBag)
//
//        let result = coolingPeriodOver.filter{ $0 }.map{ _ in self.enteredAmount.map{ $0 <= self.coolingPeriod.remainingLimit }.map{ $0 || self.coolingPeriod.isCoolingPeriodOver }}
//
//        let doneError = result.withLatestFrom(Observable.combineLatest(SessionManager.current.currentBalance, enteredAmount, tranferFee, reasonSelectedSubject.startWith(.mocked)))
//            .map{ [unowned self] in self.getError(forAmount: $0.1, availableBalance: $0.0, transferFee: $0.2, selectedReason: $0.3) }
//
//        doneError.unwrap().bind(to: amountErrorSubject).disposed(by: disposeBag)
//
//        let done = doneError.filter{ $0 == nil }.withLatestFrom(enteredAmount)
//
//        let verifiedAmount = done
//            .filter{ [unowned self] in self.transactionRange.contains($0) }
//
//        done
//            .filter{ [unowned self] in !self.transactionRange.contains($0) }
//            .map{ [unowned self] _ in return String.init(format: "common_display_text_transaction_limit_error".localized, "AED \(self.transactionRange.lowerBound.formattedAmount)", "AED \(self.transactionRange.upperBound.formattedAmount)")}
//            .bind(to: amountErrorSubject)
//            .disposed(by: disposeBag)
//
//        verifiedAmount
//            .filter{ [unowned self] amount in
//                let type = self.beneficiary.type ?? .domestic
//                return type == .cashPayout && amount > self.transactionThreshold.remittanceOTPRemainingLimit}
//            .map{ [unowned self] _ -> (SendMoneyBeneficiary, Double) in return (self.beneficiary, Double(self.currentAmount) ) }
//            .bind(to: otpSubject).disposed(by: disposeBag)
//
//        let confirmationReq = verifiedAmount
//            .filter{ [unowned self] amount in
//                let type = self.beneficiary.type ?? .domestic
//                return type == .rmt || type == .swift || type == .uaefts || type == .domestic || amount <= self.transactionThreshold.remittanceOTPRemainingLimit }
//
//        confirmationReq.filter{ [unowned self] _ in
//            let type = self.beneficiary.type ?? .domestic
//            return (self.transactionMightGetHeld && (type == .swift || type == .uaefts)) || type == .rmt || type == .domestic }
//            .map{ _ in }
//            .bind(to: otpVerifiedSubject)
//            .disposed(by: disposeBag)
//
//        let cutoffReq = confirmationReq.filter{ [unowned self] _ in
//            let type = self.beneficiary.type ?? .domestic
//            return !self.transactionMightGetHeld && (type == .swift || type == .uaefts) }
//            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
//            .flatMap{ [unowned self] in self.getCutoffMessage(amount: $0, isCbwsi: (self.selectedReason?.isCBWSI ?? false) && (self.beneficiary.cbwsiCompliant ?? false)) }
//            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
//            .share()
//            .map{ [unowned self] in self.transactionMightGetHeld }
//
//        cutoffReq.filter{ !$0 }.map{ _ in }.bind(to: otpVerifiedSubject).disposed(by: disposeBag)
//        cutoffReq.filter{ $0 }.map{ _ in }.bind(to: doneSubject).disposed(by: disposeBag)
//
//        let transferRequest = otpVerifiedSubject
//            .flatMap{ [unowned self] _ -> Observable<Event<String?>> in
//                self.showActivitySubject.onNext(true)
//                switch self.beneficiary.type ?? .domestic {
//                case .cashPayout:
//                    return self.cashPayout()
//                case .domestic:
//                    return self.domestic()
//                case .uaefts:
//                    return self.uaefts()
//                case .rmt:
//                    return self.rmt()
//                case .swift:
//                    return self.swift()
//                } }
//            .share()
//
//        transferRequest.map{ _ in false }.bind(to: showActivitySubject).disposed(by: disposeBag)
//
//        transferRequest.errors().map{ $0.localizedDescription }.bind(to: amountErrorSubject).disposed(by: disposeBag)
//
//        transferRequest.elements().map{ [unowned self] reference in SendMoneyTransactionResult(beneficiary: self.beneficiary, sourceAmount: self.currentAmount, sourceCurrency: "AED", destinationAmount: self.destinationAmount, destinationCurrency: self.beneficiary.currency ?? "AED", conversionRate: self.currentRate, referenceNumber: reference ?? "", charges: self.currentCharges, reason: self.selectedReason, notes: self.currentNote, transactionThreshold: self.transactionThreshold, postCutoff: self.cutoffMessage != nil, willGetHeld: self.transactionWillGetHeld, cutoffMessage: self.cutoffMessage, isCbwsi: self.beneficiary.type == .uaefts && (self.beneficiary.cbwsiCompliant ?? false) && self.currentAmount <= self.transactionThreshold.cbwsiLimit && (self.selectedReason?.isCBWSI ?? false)) }.bind(to: resultSubject).disposed(by: disposeBag)
//    }
//
//    func cashPayout() -> Observable<Event<String?>> {
//        repository.cashPayout(beneficiaryId: beneficiary.id!, amount: CurrencyFormatter.amountString(for: "AED", currentAmount), purposeCode: selectedReason?.code ?? "8", purposeReason: selectedReason?.text, notes: currentNote, currency: "AED")
//    }
//
//    func domestic() -> Observable<Event<String?>> {
//        BehaviorSubject<String?>(value: nil).asObservable().materialize()
//    }
//
//    func uaefts() -> Observable<Event<String?>> {
//        BehaviorSubject<String?>(value: nil).asObservable().materialize()
//    }
//
//    func rmt() -> Observable<Event<String?>> {
//        BehaviorSubject<String?>(value: nil).asObservable().materialize()
//    }
//
//    func swift() -> Observable<Event<String?>> {
//        BehaviorSubject<String?>(value: nil).asObservable().materialize()
//    }
//}
