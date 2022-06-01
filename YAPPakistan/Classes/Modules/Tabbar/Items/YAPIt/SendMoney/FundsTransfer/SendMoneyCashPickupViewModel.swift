//
//  SendMoneyCashPickupViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 22/03/2022.
//

import Foundation
import RxSwift
import YAPComponents

class SendMoneyCashPickupViewModel: SendMoneyFundsTransferViewModel {
    
    override func generateCellViewModels() {
        
        titleSubject.onNext("screen_cash_pickup_funds_display_text_header".localized)
        
        viewModels.append(SMFTBeneficiaryCellViewModel(beneficiary))
        
        var validations = [Observable<Bool>]()
        
        let amount = SMFTAmountInputCellViewModel("PKR")
        self.amountErrorSubject.map{ $0 == nil }.bind(to: amount.inputs.isValidAmountObserver).disposed(by: disposeBag)
        amount.outputs.text.map { Double(convertWithLocale: $0 ?? "0") ?? 0.0 }.bind(to: enteredAmount).disposed(by: disposeBag)
        viewModels.append(amount)
        validations.append(Observable.combineLatest(enteredAmount, amountErrorSubject).map{ $0.0 > 0 && $0.1 == nil })

        let charges = SMFTChargesCellViewModel(chargesType: .cashPickup)
        viewModels.append(charges)
        
        viewModels.append(SMFTAvailableBalanceCellViewModel())

        let note = SMFTNoteCellViewModel()
        note.outputs.text.subscribe(onNext: { [unowned self] in self.currentNote = $0 }).disposed(by: disposeBag)
        viewModels.append(note)
        
        validations.append(note.outputs.text.map{ ValidationService.shared.validateTransactionRemarks($0) })
        
        Observable.combineLatest(validations)
            .map { !$0.contains(false) }
            .bind(to: doneEnabledSubject)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(tranferFee, enteredAmount.startWith(0))
            .map { fee, amount -> FeeCharges in
                fee.getFeeCharges(for: amount) }
            .map { [unowned self] in
                self.currentCharges = $0
                return CurrencyFormatter.formatAmountInLocalCurrency($0.fee + $0.vat) }
            .bind(to: charges.inputs.feeObserver)
            .disposed(by: disposeBag)
    }
    
//    override func fetchRequiredData() {
//        showActivitySubject.onNext(true)
//
//        Observable.zip(fetchTransactionFee(), fetchTransactionLimit(), fetchTransactionThresholds(), getCoolingPeriod()).map { _ in false }.bind(to: showActivitySubject).disposed(by: disposeBag)
//    }
}
