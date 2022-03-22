//
//  SendMonyeLocalTransferViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 22/03/2022.
//

import Foundation
import RxSwift
import YAPComponents

class SendMoneyLocalTransferViewModel: SendMoneyFundsTransferViewModel {
    
    override func generateCellViewModels() {
        titleSubject.onNext("screen_domestic_funds_transfer_display_text_heading".localized)
        var validations = [Observable<Bool>]()
        
        viewModels.append(SMFTBeneficiaryCellViewModel(beneficiary, showsIban: true))
        
        let amount = SMFTAmountInputCellViewModel(beneficiary.currency ?? "AED")
        amount.outputs.text.map{ Double(convertWithLocale: $0 ?? "0") ?? 0.0 }.bind(to: enteredAmount).disposed(by: disposeBag)
        self.amountErrorSubject.map{ $0 == nil }.bind(to: amount.inputs.isValidAmountObserver).disposed(by: disposeBag)
        viewModels.append(amount)
        validations.append(Observable.combineLatest(enteredAmount, amountErrorSubject).map{ $0.0 > 0 && $0.1 == nil })
        
        let charges = SMFTChargesCellViewModel(chargesType: .cashPickup)
        viewModels.append(charges)
        
        viewModels.append(SMFTAvailableBalanceCellViewModel())
        
        let reason = SMFTReasonCellViewModel()
        viewModels.append(reason)
        reasonSelectedSubject.bind(to: reason.inputs.selectedReasonObserver).disposed(by: disposeBag)
        reason.outputs.selectReason.withLatestFrom(reasonsSubject).bind(to: selectReasonSubject).disposed(by: disposeBag)
        
        validations.append(reasonSelectedSubject.map { _ in true })
        
        Observable.combineLatest(validations)
            .map { !$0.contains(false) }
            .bind(to: doneEnabledSubject)
            .disposed(by: disposeBag)
        
        let note = SMFTNoteCellViewModel()
        note.outputs.text.subscribe(onNext: { [unowned self] in self.currentNote = $0 }).disposed(by: disposeBag)
        viewModels.append(note)
        
        let validNote = note.outputs.text.map{ ValidationService.shared.validateTransactionRemarks($0) }
        validations.append(validNote)
        validNote
            .map{ $0 ? nil : "Please remove special characters to continue" }
            .bind(to: note.inputs.errorObserver)
            .disposed(by: disposeBag)
        
        
        Observable.combineLatest(tranferFee, enteredAmount.startWith(0), reasonSelectedSubject.startWith(.mocked))
            .map { [weak self] fee, amount, reason -> FeeCharges in
                
                guard self?.beneficiary.type ?? .domestic == .uaefts else { return fee.getFeeCharges(for: amount) }
                guard reason.isFeeChargeable else { return (0, 0) }
                guard reason.isCBWSIApplicable && (amount <= self?.transactionThreshold.cbwsiLimit ?? 0) && (self?.beneficiary.cbwsiCompliant ?? false) else { return fee.getFeeCharges(for: amount) }
                return (0, 0) }
            .map { [unowned self] in
                self.currentCharges = $0
                return CurrencyFormatter.formatAmountInLocalCurrency($0.fee + $0.vat) }
            .bind(to: charges.inputs.feeObserver)
            .disposed(by: disposeBag)
    }
    
//    override func fetchRequiredData() {
//        showActivitySubject.onNext(true)
//        
//        Observable.zip(fetchTransactionLimit(), fetchTransactionReasons(), fetchTransactionFee(), fetchTransactionThresholds(), getCoolingPeriod()).map { _ in false }.bind(to: showActivitySubject).disposed(by: disposeBag)
//    }
}
