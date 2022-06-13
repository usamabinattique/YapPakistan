//
//  SendMoneyConfirmFundsTransferViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 30/03/2022.
//

import Foundation
import RxSwift
import UIKit
import YAPComponents
import MapKit

protocol SendMoneyConfirmFundsTransferViewModelInputs {
    var backObserver: AnyObserver<Void> { get }
    var nextObserver: AnyObserver<Void> { get }
}

protocol SendMoneyConfirmFundsTransferViewModelOutputs {
    var image: Observable<(String?, UIImage?)> { get }
    var name: Observable<String?> { get }
    var back: Observable<Void> { get }
    var next: Observable<Int> { get }
    var error: Observable<String> { get }
    var fee: Observable<NSAttributedString?> { get }
    var balance: Observable<NSAttributedString?> { get }
    var result: Observable<(SendMoneyBeneficiary,BankTransferResponse)> { get }
}

protocol SendMoneyConfirmFundsTransferViewModelType {
    var inputs: SendMoneyConfirmFundsTransferViewModelInputs { get }
    var outputs: SendMoneyConfirmFundsTransferViewModelOutputs { get }
}

class SendMoneyConfirmFundsTransferViewModel: SendMoneyConfirmFundsTransferViewModelType, SendMoneyConfirmFundsTransferViewModelInputs, SendMoneyConfirmFundsTransferViewModelOutputs {
    
    
    var inputs: SendMoneyConfirmFundsTransferViewModelInputs { return self }
    var outputs: SendMoneyConfirmFundsTransferViewModelOutputs { return self }
    
    // MARK: Inputs
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    
    // MARK: Outputs
    var image: Observable<(String?, UIImage?)> { return imageSubject.asObservable() }
    var name: Observable<String?> { return nameSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var next: Observable<Int> { nextResultSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var balance: Observable<NSAttributedString?> { balanceSubject.asObservable() }
    var fee: Observable<NSAttributedString?> { feeSubject.asObservable() }
    var result: Observable<(SendMoneyBeneficiary,BankTransferResponse)> { resultSubject.asObservable() }
    
    // MARK: Subjects
    private let backSubject = PublishSubject<Void>()
    private let nextSubject = PublishSubject<Void>()
    private let nextResultSubject = PublishSubject<Int>()
    private let errorSubject = PublishSubject<String>()
    private let balanceSubject = ReplaySubject<NSAttributedString?>.create(bufferSize: 1)
    private let imageSubject = BehaviorSubject<(String?, UIImage?)>(value: (nil, nil))
    private let nameSubject = BehaviorSubject<String?>(value: nil)
    private let feeSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    private let resultSubject = PublishSubject<(SendMoneyBeneficiary,BankTransferResponse)>()
    
    // MARK: Properties
    private let disposeBag = DisposeBag()
    private let repository: Y2YRepositoryType
    private var checkoutSessionObject: PaymentGatewayCheckoutSession?
    
    init(beneficiary: SendMoneyBeneficiary,  repository: Y2YRepositoryType){
       
        
        self.repository = repository
        let name = beneficiary.title ?? ""
        imageSubject.onNext((beneficiary.beneficiaryPictureUrl, name.thumbnail))
        nameSubject.onNext(name)
        if let amount = beneficiary.bankTransferReq?.amount {
            let balance = formattedBalance(amount: Double(amount) ?? 0)
            let text = "\(name.firstLetter) will receive \(balance)"
            let attributed = NSMutableAttributedString(string: text)
            attributed.addAttributes([.foregroundColor : UIColor(Color(hex: "#272262"))], range: NSRange(location: text.count - balance.count, length: balance.count))
            balanceSubject.onNext(attributed)
        }
        if let fee = beneficiary.bankTransferReq?.feeAmount {
            let amountFormatted = String(format: "%.2f", Double(fee) ?? 0.0)
            let amount = "PKR \(amountFormatted)"
            let text = String.init(format: "screen_y2y_funds_transfer_display_text_fee".localized, amount)
            let attributed = NSMutableAttributedString(string: text)
            attributed.addAttributes([.foregroundColor : UIColor(Color(hex: "#272262"))], range: NSRange(location: (text as NSString).range(of: amount).location, length: amount.count))
            feeSubject.onNext(attributed as NSAttributedString)
        }
        
        nextSubject.withUnretained(self)
            .subscribe(onNext:{ `self`, _ in
                if let input = beneficiary.bankTransferReq {
                    self.confirmTransfer(input: input,beneficiary: beneficiary)
                }
            }).disposed(by: disposeBag)
    }
    
    //MARK: - Apis helper methods
    private func confirmTransfer(input: SendMoneyBankTransferInput,beneficiary: SendMoneyBeneficiary) {
        YAPProgressHud.showProgressHud()
        let request = repository.sendMoneyViaBankTransfer(input: input).share()
        
        request.elements().withUnretained(self)
            .subscribe(onNext: { `self`, bankTransferResponse in
                YAPProgressHud.hideProgressHud()
                self.resultSubject.onNext((beneficiary, bankTransferResponse))
            })
            .disposed(by: disposeBag)
        
        request.errors().subscribe(onNext: { [weak self] error in
            self?.errorSubject.onNext(error.localizedDescription)
            YAPProgressHud.hideProgressHud()
        }).disposed(by: disposeBag)
    }
    
    private func formattedBalance(amount:Double,showCurrencyCode: Bool = true, shortFormat: Bool = true) -> String {
        let readable = amount.userReadable
        
        var formatted = CurrencyFormatter.format(amount: shortFormat ? readable.value : amount, in: "PKR")
        
        if !showCurrencyCode {
            formatted = formatted.amountFromFormattedAmount
        }
        
        if shortFormat {
            formatted += readable.denomination
        }
        
        return formatted
    }
}

