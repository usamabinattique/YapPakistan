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
    var selectReason: Observable<[TransferReason]> { get }
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
    private var accountProvider: AccountProvider

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
    let selectReasonSubject = PublishSubject<[TransferReason]>()
    let reasonSelectedSubject = PublishSubject<TransferReason>()

    var beneficiary: SendMoneyBeneficiary!
    var viewModels: [ReusableTableViewCellViewModelType] = []
    var repository : Y2YRepositoryType!

    let tranferFee = BehaviorSubject<TransferFee>(value: TransferFee.mock)
    var transactionRange = 0.1...100.0
    var tranferReasons: [TransferReason]!
    let reasonsSubject = PublishSubject<[TransferReason]>()
    var selectedReason: TransferReason?
    var coolingPeriod = BeneficiaryCoolingPeriod.mock
    
    private let feeRes = ReplaySubject<TransactionProductCodeFeeResponse>.create(bufferSize: 1)
    private let customerBalanceRes = ReplaySubject<CustomerBalanceResponse>.create(bufferSize: 1)
    private let thresholdRes = ReplaySubject<TransactionThreshold>.create(bufferSize: 1)

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
    var selectReason: Observable<[TransferReason]> { selectReasonSubject.asObservable() }
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
    private var transactionFee = TransactionProductCodeFeeResponse.mock

    // MARK: - Init
    init(beneficiary: SendMoneyBeneficiary, sendMoneyType: SendMoneyType, repository: Y2YRepositoryType, accountProvider: AccountProvider) {
        self.beneficiary = beneficiary
        self.repository = repository
        self.accountProvider = accountProvider
        generateCellViewModels()
        loadCells()
       // makeTransaction()
        fetchRequiredData()
        handleErrors()

        reasonSelectedSubject.subscribe(onNext: { [weak self] in
            self?.selectedReason = $0
        }).disposed(by: disposeBag)
    }

    func generateCellViewModels() {
        
        titleSubject.onNext("screen_domestic_funds_transfer_display_text_heading".localized)
        var validations = [Observable<Bool>]()
        
        viewModels.append(SMFTBeneficiaryCellViewModel(beneficiary, showsIban: true))
        
        let amount = SMFTAmountInputCellViewModel(beneficiary.currency ?? "PKR")
        
        amount.outputs.text.map{ Double(convertWithLocale: $0 ?? "0") ?? 0.0 }.bind(to: enteredAmount).disposed(by: disposeBag)
        self.amountErrorSubject.map{ $0 == nil }.bind(to: amount.inputs.isValidAmountObserver).disposed(by: disposeBag)
        
        feeRes.map { fee in
            let amountFormatted = String(format: "%.2f", fee.fixedAmount ?? 0.0)
            let amount = "PKR \(amountFormatted)"
            let text = String.init(format: "screen_cash_pickup_funds_display_text_fee".localized, amount)
            let attributed = NSMutableAttributedString(string: text)
            attributed.addAttributes([.foregroundColor : UIColor(Color(hex: "#272262"))], range: NSRange(location: (text as NSString).range(of: amount).location, length: amount.count))
            return attributed
        }.bind(to: amount.inputs.feeObserver).disposed(by: disposeBag)

        
        viewModels.append(amount)
        validations.append(Observable.combineLatest(enteredAmount, amountErrorSubject).map{ $0.0 > 0 && $0.1 == nil })
        
        let charges = SMFTChargesCellViewModel() //SMFTChargesCellViewModel(chargesType: .cashPickup)
        Observable.combineLatest(enteredAmount, feeRes).map { (amount,fee) -> NSAttributedString in
            let amountFormatted = String(format: "%.2f", fee.fixedAmount ?? 0.0)
            let amount = "PKR \(amountFormatted)"
            let text = String.init(format: "screen_y2y_funds_transfer_display_text_fee".localized, amount)
            let attributed = NSMutableAttributedString(string: text)
            attributed.addAttributes([.foregroundColor : UIColor(Color(hex: "#272262"))], range: NSRange(location: (text as NSString).range(of: amount).location, length: amount.count))
            return attributed as NSAttributedString }.bind(to: charges.chargesSubject).disposed(by: disposeBag)
        
        viewModels.append(charges)
        
        //TODO: add customer balance from api here in cellviewmodel
        let availableBalance = SMFTAvailableBalanceCellViewModel(.mock,true)
        //TODO: uncomment following comment
        customerBalanceRes.map{
            customerBalance -> NSAttributedString in
            let balance = customerBalance.formattedBalance()
            let text = "Your available balance is \(balance)"
            let attributed = NSMutableAttributedString(string: text)
            attributed.addAttributes([.foregroundColor : UIColor(Color(hex: "#272262"))], range: NSRange(location: text.count - balance.count, length: balance.count))
            return attributed
        }.bind(to: availableBalance.balanceSubject).disposed(by: disposeBag)
        viewModels.append(availableBalance)
        
        let reason = SMFTReasonCellViewModel()
        viewModels.append(reason)
        reasonSelectedSubject.bind(to: reason.inputs.selectedReasonObserver).disposed(by: disposeBag)
        reason.outputs.selectReason.withLatestFrom(reasonsSubject).bind(to: selectReasonSubject).disposed(by: disposeBag)
        
        validations.append(reasonSelectedSubject.map { _ in true })
        
        //TODO: uncomment following line
        Observable.combineLatest(validations)
            .map { !$0.contains(false) }
            .bind(to: doneEnabledSubject)
            .disposed(by: disposeBag)
        
        //TODO: remove following line
//        doneEnabledSubject.onNext(true)
        
        let note = SMFTNoteCellViewModel()
        note.outputs.text.subscribe(onNext: { [unowned self] in self.currentNote = $0 }).disposed(by: disposeBag)
        viewModels.append(note)
        
        let validNote = note.outputs.text.map{ ValidationService.shared.validateTransactionRemarks($0) }
        validations.append(validNote)
        validNote
            .map{ $0 ? nil : "Please remove special characters to continue" }
            .bind(to: note.inputs.errorObserver)
            .disposed(by: disposeBag)
        
      
     /*   Observable.combineLatest(tranferFee, enteredAmount.startWith(0), reasonSelectedSubject.startWith(.mock))
            .map { [weak self] fee, amount, reason -> FeeCharges in
                
                guard self?.beneficiary.type ?? .domestic == .uaefts else { return fee.getFeeCharges(for: amount) }
                guard reason.isFeeChargeable else { return (0, 0) }
                guard reason.isCBWSIApplicable && (amount <= self?.transactionThreshold.cbwsiLimit ?? 0) && (self?.beneficiary.cbwsiCompliant ?? false) else { return fee.getFeeCharges(for: amount) }
                return (0, 0) }
            .map { [unowned self] in
                self.currentCharges = $0
                return CurrencyFormatter.formatAmountInLocalCurrency($0.fee + $0.vat) }
            .bind(to: charges.inputs.feeObserver)
            .disposed(by: disposeBag) */
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


private extension SendMoneyFundsTransferViewModel {
    
    func fetchRequiredData() {
        showActivitySubject.onNext(true)
        
        //TODO: remove following comment
//        Observable.zip(fetchTransactionLimit(), fetchTransactionReasons(), fetchTransactionFee(), fetchThresholdLimits(), fetchCustomerAccountBalance()).map { _ in false }.bind(to: showActivitySubject).disposed(by: disposeBag)
        
        //TODO: remove following line
        Observable.zip(fetchTransactionLimit(), fetchTransactionReasons(), fetchTransactionFee(), fetchThresholdLimits()).map { _ in false }.bind(to: showActivitySubject).disposed(by: disposeBag)
        
//        fetchCustomerAccountBalance().map { _ in false }.bind(to: showActivitySubject).disposed(by: disposeBag)
    }
    
    func fetchTransactionLimit() -> Observable<Void> {
        let transactionLimitRequest = self.repository.getTransactionProductLimit(transactionProductCode: TransactionProductCode.topUpByExternalCard.rawValue).share()

        transactionLimitRequest.errors().subscribe(onNext: { [unowned self] in self.showErrorSubject.onNext($0.localizedDescription) }).disposed(by: disposeBag)
        transactionLimitRequest.elements().subscribe(onNext: { [unowned self] in
            let min = Double($0.minLimit) ?? 0
            let max = Double($0.maxLimit) ?? 0
            self.transactionRange = min...max
        }).disposed(by: disposeBag)

        return transactionLimitRequest.map{ _ in }//in self.fetchTransactionLimitForCountry() }
    }

    func fetchTransactionFee() -> Observable<Void> {

        let feeRequest = repository.getFee(productCode: TransactionProductCode.topUpByExternalCard.rawValue).share()

        feeRequest.errors().subscribe(onNext: { [unowned self] in self.showErrorSubject.onNext($0.localizedDescription) }).disposed(by: disposeBag)

        //feeRequest.elements().map{ $0 == nil ? TransferFee.mock : $0! }.bind(to: tranferFee).disposed(by: disposeBag)
        feeRequest.elements().bind(to: feeRes).disposed(by: disposeBag)
        feeRequest.elements().subscribe(onNext: { [unowned self]  in
            self.transactionFee = $0
        }).disposed(by: disposeBag)
        return feeRequest.map { _ in }
    }
    
    func fetchCustomerAccountBalance() -> Observable<Void> {
        
        let getCustomerBalanceRequest = repository.fetchCustomerAccountBalance().share()

        getCustomerBalanceRequest.errors().subscribe(onNext: { [unowned self] in self.showErrorSubject.onNext($0.localizedDescription) }).disposed(by: disposeBag)

        getCustomerBalanceRequest.elements().bind(to: customerBalanceRes).disposed(by: disposeBag)
        return getCustomerBalanceRequest.map { _ in }
    }
    
    func fetchThresholdLimits() -> Observable<Void> {
        
        let request = repository.getThresholdLimits().share()

        request.errors().subscribe(onNext: { [unowned self] in self.showErrorSubject.onNext($0.localizedDescription) }).disposed(by: disposeBag)

        request.elements().bind(to: thresholdRes).disposed(by: disposeBag)
        
        request.elements().subscribe(onNext: { [unowned self] _ in
            print("limits")
        }).disposed(by: disposeBag)
        return request.map { _ in }
    }
    

    func fetchTransactionReasons() -> Observable<Void> {
        let reasonsRequest = repository.fetchTransferReasons().share()

        reasonsRequest.errors().subscribe(onNext: { [unowned self] in self.showErrorSubject.onNext($0.localizedDescription) }).disposed(by: disposeBag)

        reasonsRequest.elements()
            //.map { $0.filter { $0.code != nil } }
            .do(onNext: { [unowned self] in self.tranferReasons = $0 })
            .map{ reasons in
              /*  var reasonTypes = [TransferReasonType]()

                var reasonsWithoutCategory = reasons.filter{ $0.category == nil }
                let reasonsWithCategory = reasons.filter{ $0.category != nil }

                let groups = Dictionary(grouping: reasonsWithCategory, by: { $0.category })

                reasonsWithoutCategory.append(contentsOf: groups.filter{ $0.1.count == 1 && $0.1.first?.category == $0.1.first?.title }.flatMap{ $0.1 })

                groups.filter{ $0.1.count > 1 || $0.1.first?.category != $0.1.first?.title }
                    .forEach { (category, reasons) in
                        reasonTypes.append(TransferReasonCategory(categoryName: category ?? "", reasons: reasons)) }

                reasonTypes.append(contentsOf: reasonsWithoutCategory)

                return reasonTypes.sorted(by: { $0.title < $1.title }) } */
                return reasons.sorted(by: { $0.transferReason < $1.transferReason }) }
            .bind(to: reasonsSubject)
            .disposed(by: disposeBag)

        return reasonsRequest.map { _ in }
    }
}

// MARK: Error handling

private extension SendMoneyFundsTransferViewModel {
    func handleErrors() {
       
//        Observable.combineLatest(customerBalanceRes, amountSubject.map{ Double($0 ?? "") ?? 0 })
//            .map{ [unowned self] in self.getError(forAmount: $0.1, availableBalance: $0.0.currentBalance) }
//            .bind(to: amountErrorSubject)
//            .disposed(by: disposeBag)
        
        Observable.combineLatest(customerBalanceRes, enteredAmount, tranferFee, reasonSelectedSubject.startWith(.mock))
            .do(onNext: { [unowned self] in self.currentAmount = $0.1 })
                .map{ [unowned self] in self.getError(forAmount: $0.1, availableBalance: $0.0.currentBalance, transferFee: $0.2, selectedReason: $0.3) }
            .bind(to: amountErrorSubject)
            .disposed(by: disposeBag)
    }
    
    func getError(forAmount amount: Double, availableBalance balance: Double, transferFee: TransferFee ,selectedReason reason: TransferReason) -> String? {
        let fee =  transactionFee.fixedAmount ?? 0.0 //transferFee.getTaxedFee(for: amount)

        guard amount + fee <= balance else {
            return String.init(format: "common_display_text_available_balance_error".localized, CurrencyFormatter.formatAmountInLocalCurrency(amount))
        }

        guard amount <= transactionThreshold.dailyRemainingLimit else {
            return transactionThreshold.dailyRemainingLimit <= 0 ? "common_display_text_daily_limit_error_limit_reached".localized : amount > self.transactionThreshold.dailyLimit ? "common_display_text_daily_limit_error_single_transaction".localized : "common_display_text_daily_limit_error_multiple_transactions".localized
        }

        guard amount <= transactionRange.upperBound else {
            return String.init(format: "common_display_text_transaction_limit_error".localized, "PKR \(transactionRange.lowerBound.formattedAmount)", "PKR \(transactionRange.upperBound.formattedAmount)")
        }
        
        return nil
    }
}
