//
//  TopupPCCVCellViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 09/02/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift
import RxDataSources


protocol TopupPCCVCellViewModelInputs {
    var infoObserver: AnyObserver<Void> { get }
}

protocol TopupPCCVCellViewModelOutputs {
    var cardImage: Observable<UIImage?> { get }
    var openDetails: Observable<ExternalPaymentCard> { get }
    var expired: Observable<Bool> { get }
}

protocol TopupPCCVCellViewModelType {
    var inputs: TopupPCCVCellViewModelInputs { get }
    var outputs: TopupPCCVCellViewModelOutputs { get }
}

class TopupPCCVCellViewModel: TopupPCCVCellViewModelType, TopupPCCVCellViewModelInputs, TopupPCCVCellViewModelOutputs, ReusableCollectionViewCellViewModelType {
    
    var reusableIdentifier: String { return TopupPCCVCell.defaultIdentifier }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: TopupPCCVCellViewModelInputs { return self }
    var outputs: TopupPCCVCellViewModelOutputs { return self }
    let beneficiary: ExternalPaymentCard!
    
    private let cardImageSubject: BehaviorSubject<UIImage?>
    private let infoSubject = PublishSubject<Void>()
    private let expiredSubject = BehaviorSubject<Bool>(value: false)
    
    // MARK: - Inputs
    var infoObserver: AnyObserver<Void> { return infoSubject.asObserver() }
    
    // MARK: - Outputs
    var cardImage: Observable<UIImage?> { return cardImageSubject.asObservable() }
    var openDetails: Observable<ExternalPaymentCard> { return infoSubject.map { [unowned self] in self.beneficiary }.asObservable() }
    var expired: Observable<Bool> { return expiredSubject.asObservable() }
    
    let paymentBeneficiary: ExternalPaymentCard
    
    // MARK: - Init
    init(paymentGatewayBeneficiary: ExternalPaymentCard) {
        self.paymentBeneficiary = paymentGatewayBeneficiary
        self.beneficiary = paymentGatewayBeneficiary
        self.cardImageSubject = BehaviorSubject(value: paymentGatewayBeneficiary.cardImage())
        expiredSubject.onNext((paymentGatewayBeneficiary.expiryDate ?? Date()) < Date())
    }
}
    
