//
//  CardDetailPopUpViewModel.swift
//  ios-b2c-pk-components
//
//  Created by Sarmad on 26/11/2021.
//

import Foundation
import RxSwift

protocol CardDetailPopUpViewModelInputs {
    var copyObserver: AnyObserver<Void> { get }
    var closeObserver: AnyObserver<Void> { get }
}

protocol CardDetailPopUpViewModelOutputs {
    typealias ResourcesType = CardDetailPopUpViewModel.ResourcesType
    var copy: Observable<Void> { get }
    var close: Observable<Void> { get }
    var resources: Observable<ResourcesType> { get }
}

protocol CardDetailPopUpViewModelType {
    var inputs: CardDetailPopUpViewModelInputs { get }
    var outputs: CardDetailPopUpViewModelOutputs { get }
}

struct CardDetailPopUpViewModel: CardDetailPopUpViewModelType,
                                 CardDetailPopUpViewModelInputs,
                                 CardDetailPopUpViewModelOutputs {

    // Subjects
    var copySubject = PublishSubject<Void>()
    var closeSubject = PublishSubject<Void>()
    var resourcesSubject: BehaviorSubject<ResourcesType>

    // Inputs
    var copyObserver: AnyObserver<Void> { copySubject.asObserver() }
    var closeObserver: AnyObserver<Void> { closeSubject.asObserver() }

    // Outputs
    var copy: Observable<Void> { copySubject.asObservable() }
    var close: Observable<Void> { closeSubject.asObservable() }
    var resources: Observable<ResourcesType> { resourcesSubject.asObservable() }

    var inputs: CardDetailPopUpViewModelInputs { self }
    var outputs: CardDetailPopUpViewModelOutputs { self }

    init(resources: ResourcesType) {
        resourcesSubject = BehaviorSubject(value: resources)
    }

    struct ResourcesType {
        let cardImage: String
        let closeImage: String
        let titleLabel: String
        let subTitleLabel: String
        let numberTitleLabel: String
        let numberLabel: String
        let dateTitleLabel: String
        let dateLabel: String
        let cvvTitleLabel: String
        let cvvLabel: String
        let copyButtonTitle: String
    }
}
