//
//  FreezUnfreezViewModel.swift
//  ios-b2c-pk-components
//
//  Created by Sarmad on 26/11/2021.
//

import Foundation
import RxSwift

protocol FreezUnfreezViewModelInputs {
    var button1Observer: AnyObserver<Void> { get }
    var button2Observer: AnyObserver<Void> { get }
}

protocol FreezUnfreezViewModelOutputs {
    typealias ResourcesType = FreezUnfreezViewModel.ResourcesType
    var button1Tap: Observable<Void> { get }
    var button2Tap: Observable<Void> { get }
    var resources: Observable<ResourcesType> { get }
}

protocol FreezUnfreezViewModelType {
    var inputs: FreezUnfreezViewModelInputs { get }
    var outputs: FreezUnfreezViewModelOutputs { get }
}

struct FreezUnfreezViewModel: FreezUnfreezViewModelType,
                              FreezUnfreezViewModelInputs,
                              FreezUnfreezViewModelOutputs  {
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

    var inputs: FreezUnfreezViewModelInputs { self }
    var outputs: FreezUnfreezViewModelOutputs  { self }

    init(resources: ResourcesType) {
        resourcesSubject = BehaviorSubject(value: resources)
    }

    struct ResourcesType {
        let iconName: String
        let title: String
        let buttonTitle: String
    }
}
