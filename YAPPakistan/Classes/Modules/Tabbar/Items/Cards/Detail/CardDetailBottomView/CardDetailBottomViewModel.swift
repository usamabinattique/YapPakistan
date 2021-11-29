//
//  CardDetailBottomViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 29/11/2021.
//

import RxTheme
import RxSwift

protocol CardDetailBottomViewModelInputs {
    var copyObserver: AnyObserver<Void> { get }
    var closeObserver: AnyObserver<Void> { get }
}

protocol CardDetailBottomViewModelOutputs {
    typealias ResourcesType = CardDetailBottomViewModel.ResourcesType
    var copy: Observable<Void> { get }
    var close: Observable<Void> { get }
    var resources: Observable<ResourcesType> { get }
}

protocol CardDetailBottomViewModelType {
    var inputs: CardDetailBottomViewModelInputs { get }
    var outputs: CardDetailBottomViewModelOutputs { get }
}

struct CardDetailBottomViewModel: CardDetailBottomViewModelType,
                                  CardDetailBottomViewModelInputs,
                                  CardDetailBottomViewModelOutputs {

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

    var inputs: CardDetailBottomViewModelInputs { self }
    var outputs: CardDetailBottomViewModelOutputs { self }

    init(resources: ResourcesType) {
        resourcesSubject = BehaviorSubject(value: resources)
    }

    struct ResourcesType {
        let titleLabel: String
        let numberTitleLabel: String
        let numberLabel: String
        let dateTitleLabel: String
        let dateLabel: String
        let cvvTitleLabel: String
        let cvvLabel: String
        let copyButtonTitle: String
    }
}
