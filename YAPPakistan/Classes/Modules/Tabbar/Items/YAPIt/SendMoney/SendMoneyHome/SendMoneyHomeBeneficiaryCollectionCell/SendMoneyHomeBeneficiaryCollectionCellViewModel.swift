//
//  SendMoneyHomeBeneficiaryCellViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 15/03/2022.
//

import Foundation
import RxSwift
import YAPComponents

protocol SendMoneyHomeBeneficiaryCollectionCellViewModelInput {

}

protocol SendMoneyHomeBeneficiaryCollectionCellViewModelOutput {
    var shimmering: Observable<Bool> { get }
    var image: Observable<(String?, UIImage?)> { get }
    var name: Observable<String?> { get }
    var fullName: Observable<String?>{ get }
    var typeIcon: Observable<UIImage?> { get }
    var flag: Observable<UIImage?> { get }
    var typeColor: Observable<UIColor> { get }
}


protocol SendMoneyHomeBeneficiaryCollectionCellViewModelType {
    var inputs: SendMoneyHomeBeneficiaryCollectionCellViewModelInput { get }
    var outputs: SendMoneyHomeBeneficiaryCollectionCellViewModelOutput { get }
}

class SendMoneyHomeBeneficiaryCollectionCellViewModel: SendMoneyHomeBeneficiaryCollectionCellViewModelInput, SendMoneyHomeBeneficiaryCollectionCellViewModelOutput, SendMoneyHomeBeneficiaryCollectionCellViewModelType, ReusableCollectionViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: SendMoneyHomeBeneficiaryCollectionCellViewModelInput { return self }
    var outputs: SendMoneyHomeBeneficiaryCollectionCellViewModelOutput { return self }
    var reusableIdentifier: String { return SendMoneyHomeBeneficiaryCell.defaultIdentifier }

    let beneficiary: SendMoneyBeneficiary
    let isShimmering: Bool

    private var imageSubject = BehaviorSubject<(String?, UIImage?)>(value: (nil, nil))
    private let nameSubject = BehaviorSubject<String?>(value: nil)
    private let typeIconSubject = BehaviorSubject<UIImage?>(value: nil)
    private let flagSubject = BehaviorSubject<UIImage?>(value: nil)
    private let typeColorSubject = BehaviorSubject<UIColor>(value: UIColor.darkGray)
    private let fullNameSubject = BehaviorSubject<String?>(value: nil)
    private let shimmeringSubject = BehaviorSubject<Bool>(value: false)
    
    // MARK: - Inputs

    // MARK: - Outputs
    var image: Observable<(String?, UIImage?)> { return imageSubject.asObservable() }
    var name: Observable<String?> { return nameSubject.asObservable() }
    var typeIcon: Observable<UIImage?> { return typeIconSubject.asObservable() }
    var flag: Observable<UIImage?> { return flagSubject.asObservable() }
    var typeColor: Observable<UIColor> { return typeColorSubject.asObservable() }
    var fullName: Observable<String?>{ return fullNameSubject.asObservable() }
    var shimmering: Observable<Bool> { return shimmeringSubject.asObservable() }
    
    // MARK: - Init
    init(_ beneficiary: SendMoneyBeneficiary) {
        self.beneficiary = beneficiary
        let nickname = beneficiary.nickName
        let fullName = beneficiary.title
        imageSubject.onNext((nil, fullName!.initialsImage(color: UIColor.red)))
        nameSubject.onNext(nickname)
        fullNameSubject.onNext(fullName)
        typeColorSubject.onNext(beneficiary.type! == .cashPayout ? UIColor.darkGray : UIColor.darkGray)
        self.isShimmering = false
        
        
        
//        if beneficiary.type != .domestic && beneficiary.type != .uaefts {
//            flagSubject.onNext(UIImage.sharedImage(named: beneficiary.country!))
//            typeIconSubject.onNext(beneficiary.type! == .cashPayout ? UIImage.init(named: "icon_cash_pickup", in: sendMoneyBundle, compatibleWith: nil)?.asTemplate : UIImage.init(named: "icon_bank_transfer", in: sendMoneyBundle, compatibleWith: nil)?.asTemplate)
//        }
        DispatchQueue.main.async { [weak self] in
            self?.shimmeringSubject.onNext(false)
        }
    }

    init() {
        /// Adding dummy data for shimmer effect
        self.beneficiary = SendMoneyBeneficiary.mocked
        let nickname = "Dummy long Nick"
        let fullName = "Dummy looooooooooooooong Name"
        imageSubject = BehaviorSubject(value: ("icon.imageUrl", nil))
        nameSubject.onNext(nickname)
        fullNameSubject.onNext(fullName)
        typeColorSubject.onNext(UIColor.darkGray)
        typeIconSubject.onNext(nil)
        flagSubject.onNext(nil)
        shimmeringSubject.onNext(true)
        isShimmering = true
    }
    
}
