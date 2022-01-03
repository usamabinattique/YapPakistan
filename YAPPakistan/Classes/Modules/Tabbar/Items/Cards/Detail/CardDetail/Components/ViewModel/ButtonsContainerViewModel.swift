//
//  ButtonsContainerViewModel.swift
//  ios-b2c-pk-components
//
//  Created by Sarmad on 26/11/2021.
//

// swiftlint:disable identifier_name

import Foundation
import RxSwift

protocol ButtonsContainerViewModelInputs {
    var button1Observer: AnyObserver<Void> { get }
    var button2Observer: AnyObserver<Void> { get }
}

protocol ButtonsContainerViewModelOutputs {
    typealias ResourcesType = ButtonsContainerViewModel.ResourcesType
    var button1Tap: Observable<Void> { get }
    var button2Tap: Observable<Void> { get }
    var resources: Observable<ResourcesType> { get }
}

protocol ButtonsContainerViewModelType {
    var inputs: ButtonsContainerViewModelInputs { get }
    var outputs: ButtonsContainerViewModelOutputs { get }
}

struct ButtonsContainerViewModel: ButtonsContainerViewModelType,
                                  ButtonsContainerViewModelInputs,
                                  ButtonsContainerViewModelOutputs  {
    // Subjects
    fileprivate let button1TapSubject = PublishSubject<Void>()
    fileprivate let button2TapSubject = PublishSubject<Void>()
    fileprivate var resourcesSubject: BehaviorSubject<ResourcesType>

    // Inputs
    var button1Observer: AnyObserver<Void> { button1TapSubject.asObserver() }
    var button2Observer: AnyObserver<Void> { button2TapSubject.asObserver() }

    // Outputs
    var button1Tap: Observable<Void> { button1TapSubject.asObservable() }
    var button2Tap: Observable<Void> { button2TapSubject.asObservable() }
    var resources: Observable<ResourcesType> { resourcesSubject.asObservable() }

    var inputs: ButtonsContainerViewModelInputs { self }
    var outputs: ButtonsContainerViewModelOutputs  { self }

    init(resources: ResourcesType) {
        resourcesSubject = BehaviorSubject(value: resources)
    }

    struct ResourcesType {
        let button1_0Image: String
        let button1_1Title: String
        let button2_0Image: String
        let button2_1Title: String
    }
}
