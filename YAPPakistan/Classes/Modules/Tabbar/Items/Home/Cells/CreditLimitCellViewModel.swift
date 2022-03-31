//
//  CreditLimitCellViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 31/03/2022.
//

import Foundation
import YAPComponents
import RxSwift

protocol CreditLimitCellViewModelInput {
    var creditInfo: AnyObserver<Void> { get }
}

protocol CreditLimitCellViewModelOutput {
    var credit: Observable<NSAttributedString?> { get }
    var info: Observable<Void> { get }
}

protocol CreditLimitCellViewModelType {
    var inputs: CreditLimitCellViewModelInput { get }
    var outputs: CreditLimitCellViewModelOutput { get }
}

class CreditLimitCellViewModel: CreditLimitCellViewModelType, CreditLimitCellViewModelInput, CreditLimitCellViewModelOutput, ReusableTableViewCellViewModelType {
    var reusableIdentifier: String  { CreditLimitCell.defaultIdentifier }
    
    
    // MARK: - Propertiesfileprivate var limitSubject = ReplaySubject<NSAttributedString?>.create(bufferSize: 1)
    fileprivate let limitSubject = ReplaySubject<NSAttributedString?>.create(bufferSize: 1)
    private let infoSubject = PublishSubject<Void>()
    
    // Inputs
    var creditInfo: AnyObserver<Void> { infoSubject.asObserver() }

    // Outputs
    var credit: Observable<NSAttributedString?> { limitSubject.asObservable() }
    var info: Observable<Void> { infoSubject.asObservable() }

    var inputs: CreditLimitCellViewModelInput { self }
    var outputs: CreditLimitCellViewModelOutput { self }

    // Properties
    private let disposeBag = DisposeBag()

    init(_ limit: Double) {
        let amountFormatted = String(format: "%.2f", limit)
        let amount = "PKR \(amountFormatted)"
        let text = String.init(format: "screen_dashboard_credit_limit_display_text".localized, amount)
        let attributed = NSMutableAttributedString(string: text)
        attributed.addAttributes([.foregroundColor : UIColor(Color(hex: "#272262"))], range: NSRange(location: (text as NSString).range(of: amount).location, length: amount.count))
        limitSubject.onNext(attributed as NSAttributedString)
    }
    init() {
//        bank = BankDetail(bankLogoUrl: nil, bankName: "Dummy looooooooooooooong Name", accountNoMinLength: 0, accountNoMaxLength: 0, ibanMinLength: 0, ibanMaxLength: 0, consumerId: "adf", formatMessage: "abc")
//        nameSubject.onNext(bank.bankName)
//        shimmeringSubject = BehaviorSubject(value: true)
//        isShimmering = true
    }
}

