//
//  AddTopupPCCVCellViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 10/02/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxDataSources
import RxSwift

protocol AddTopupPCCVCellViewModelInputs {
    var addNewCardObserver: AnyObserver<Void> { get }
    var cardAlreadyExistsObserver: AnyObserver<Bool> { get }

}

protocol AddTopupPCCVCellViewModelOutputs {
    var addNewCard: Observable<Void> { get }
    var addCardButtonTitle: Observable<String?> { get }
}

protocol AddTopupPCCVCellViewModelType {
    var inputs: AddTopupPCCVCellViewModelInputs { get }
    var outputs: AddTopupPCCVCellViewModelOutputs { get }
}

class AddTopupPCCVCellViewModel: AddTopupPCCVCellViewModelType, AddTopupPCCVCellViewModelInputs, AddTopupPCCVCellViewModelOutputs, ReusableCollectionViewCellViewModelType {
    
    var reusableIdentifier: String { return AddTopupPCCVCell.defaultIdentifier }
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: AddTopupPCCVCellViewModelInputs { return self }
    var outputs: AddTopupPCCVCellViewModelOutputs { return self }
    
    private let addNewCardSubject = PublishSubject<Void>()
    private let cardAlreadyExistsSubject = BehaviorSubject<Bool>(value: false)
    private let buttonTitleSubject = BehaviorSubject<String?>(value: "")

    // MARK: - Inputs
    var addNewCardObserver: AnyObserver<Void> { return addNewCardSubject.asObserver() }
    var cardAlreadyExistsObserver: AnyObserver<Bool> { cardAlreadyExistsSubject.asObserver() }
    
    // MARK: - Outputs
    var addNewCard: Observable<Void> { return addNewCardSubject.asObservable() }
    var addCardButtonTitle: Observable<String?> { buttonTitleSubject.asObservable() }
    
    // MARK: - Init
    init() {
        cardAlreadyExistsSubject.subscribe(onNext: { [weak self] isCardExist in
            let title = isCardExist ? "screen_topup_card_selection_display_text_add_new_card".localized : "screen_topup_card_selection_display_text_add_card".localized
            self?.buttonTitleSubject.onNext(title)
        }).disposed(by: disposeBag)

    }
}
