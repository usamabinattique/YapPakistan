//
//  SendMoneyInternationalTransferViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 22/03/2022.
//

import Foundation
import RxSwift
import YAPComponents

class SendMoneyInternationalTransferViewModel: SendMoneyFundsTransferViewModel {
    
    override func generateCellViewModels() {
        
        titleSubject.onNext("screen_international_funds_transfer_display_text_title".localized)
        var validations = [Observable<Bool>]()
        
        viewModels.append(SMFTBeneficiaryCellViewModel(beneficiary, showsFlag: true))
        
        let amountViewModel = SMFTAmountInputCellViewModel(beneficiary.currency ?? "AED")
        self.amountErrorSubject.map{ $0 == nil }.bind(to: amountViewModel.inputs.isValidAmountObserver).disposed(by: disposeBag)
        let amount = amountViewModel.outputs.text
            .map { $0 ?? "0" }
            .map { Double(convertWithLocale: $0) ?? 0 }
            .do(onNext: { [unowned self] in self.destinationAmount = $0})
        
        Observable.combineLatest(amount, conversionRate.map{ $0.doubleValue })
            .map{ [unowned self] in
                let value = $0.0 * $0.1
                return self.beneficiary.type == .rmt ? value.roundedHalfEvenUp(toPlaces: CurrencyFormatter.decimalPlaces(for: "AED")) : value.rounded(toPlaces: CurrencyFormatter.decimalPlaces(for: "AED")) }
            .bind(to: enteredAmount).disposed(by: disposeBag)
        viewModels.append(amountViewModel)
        validations.append(Observable.combineLatest(enteredAmount, amountErrorSubject).map{ $0.0 > 0 && $0.1 == nil })
                
        if beneficiary.currency ?? "AED" != "AED" {
            let convertedAmountViewModel = SMFTConvertedAmountInputCellViewModel(currency: "AED", convertedCurrency: beneficiary.currency ?? "AED")
            viewModels.append(convertedAmountViewModel)
            
            conversionRate.bind(to: convertedAmountViewModel.inputs.conversionRate).disposed(by: disposeBag)
            
            let convertedAmountText = enteredAmount
                .map{ CurrencyFormatter.formatAmountInLocalCurrency($0) }
                .map{ $0.components(separatedBy: " ").last }

            Observable.combineLatest(convertedAmountText, amountViewModel.outputs.text)
                .map{ ($0.1?.isEmpty ?? true) ? nil : $0.0 }
                .bind(to: convertedAmountViewModel.inputs.textObserver)
                .disposed(by: disposeBag)
        }
        
        
        let charges = SMFTChargesCellViewModel(chargesType: .internationalTransfer)
        
        if beneficiary.currency ?? "AED" != "AED" {
            viewModels.append(charges)
        }
        
        viewModels.append(SMFTAvailableBalanceCellViewModel(CustomerBalanceResponse.mock,beneficiary.currency ?? "AED" == "AED"))

        let reason = SMFTReasonCellViewModel()
        viewModels.append(reason)
        reasonSelectedSubject.bind(to: reason.inputs.selectedReasonObserver).disposed(by: disposeBag)
        reason.outputs.selectReason.withLatestFrom(reasonsSubject).bind(to: selectReasonSubject).disposed(by: disposeBag)
        
        let note = SMFTNoteCellViewModel()
        note.outputs.text.subscribe(onNext: { [unowned self] in self.currentNote = $0 }).disposed(by: disposeBag)
        viewModels.append(note)
        
        let validNote = note.outputs.text.map{ ValidationService.shared.validateTransactionRemarks($0) }
        validations.append(validNote)
        validNote
            .map{ $0 ? nil : "Please remove special characters to continue" }
            .bind(to: note.inputs.errorObserver)
            .disposed(by: disposeBag)
        
//        if beneficiary.currency ?? "AED" != "AED" {
//            viewModels.append(charges)
//        }
                
        validations.append(reasonSelectedSubject.map { _ in true })
        
        Observable.combineLatest(validations)
            .map { !$0.contains(false) }
            .bind(to: doneEnabledSubject)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(tranferFee, enteredAmount.startWith(0), amount.startWith(0), conversionRate.map{ $0.doubleValue })
            .map { fee, aedAmount, foreignAmount, exchangeRate -> FeeCharges in
                fee.getFeeCharges(for: fee.slabCurrency != "AED" ? foreignAmount : aedAmount, exchangeRate: exchangeRate) }
            .map { [unowned self] in
                self.currentCharges = $0
                return CurrencyFormatter.formatAmountInLocalCurrency(($0.fee + $0.vat)) }
            .bind(to: charges.inputs.feeObserver)
            .disposed(by: disposeBag)
    }
    
//    override func fetchRequiredData() {
//        showActivitySubject.onNext(true)
//
//        var dataToFetch = [Observable<Void>]()
//
//        dataToFetch.append(contentsOf: [fetchTransactionLimit(), fetchTransactionReasons(), fetchTransactionFee(), fetchTransactionThresholds(), getCoolingPeriod()])
//        if beneficiary.currency != "AED" {
//            dataToFetch.append(getFxRate())
//        }
//
//        Observable.zip(dataToFetch).map { _ in false }.bind(to: showActivitySubject).disposed(by: disposeBag)
//    }
}
