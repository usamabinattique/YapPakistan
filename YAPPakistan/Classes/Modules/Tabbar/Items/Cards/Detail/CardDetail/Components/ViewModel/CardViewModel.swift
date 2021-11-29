//
//  CardViewModel.swift
//  ios-b2c-pk-components
//
//  Created by Sarmad on 26/11/2021.
//

import Foundation
import RxSwift

protocol CardViewModelInputs {
    var datailTapObserver: AnyObserver<Void> { get }
}

protocol CardViewModelOutputs {
    typealias ResourcesType = CardViewModel.ResourcesType
    var datailTap: Observable<Void> { get }
    var resources: Observable<ResourcesType> { get }
}

protocol CardViewModelType {
    var inputs: CardViewModelInputs { get }
    var outputs: CardViewModelOutputs { get }
}

struct CardViewModel: CardViewModelType, CardViewModelInputs, CardViewModelOutputs {

    // Subjects
    fileprivate var datailTapSubject = PublishSubject<Void>()
    fileprivate var resourcesSubject: BehaviorSubject<ResourcesType>

    // Inputs
    var datailTapObserver: AnyObserver<Void> { datailTapSubject.asObserver() }

    // Outputs
    var resources: Observable<ResourcesType> { resourcesSubject.asObservable() }
    var datailTap: Observable<Void> { datailTapSubject.asObservable() }

    var inputs: CardViewModelInputs { self }
    var outputs: CardViewModelOutputs { self }

    init(resources: ResourcesType) {
        self.resourcesSubject = BehaviorSubject<ResourcesType>(value: resources)
    }

    struct ResourcesType {
        let title: String
        let subtitle: String
        let subsubTitle: String
        let buttonTitle: String
        let leftImageName: String
        let subsubTitleIconName: String
    }
}
