//
// SystemPermissionViewModel.swift
// App
//
// Created by Uzair on 18/06/2021.
//

import Foundation
import RxSwift

protocol SystemPermissionViewModelInputs {
    var permissionObserver: AnyObserver<Void> { get }
    var termsConditionsObserver: AnyObserver<Void> { get }
    var noThanksObserver: AnyObserver<Void> { get }
}

protocol SystemPermissionViewModelOutputs {
    var termsConditions: Observable<Void> { get }
    var thanks: Observable<Void> { get }
    var error: Observable<String> { get }
    var success: Observable<Void> { get }
    var loading: Observable<Bool> { get }
    var resources: Observable<SystemPermissionType> { get }
}

protocol SystemPermissionViewModelType {
    var inputs: SystemPermissionViewModelInputs { get }
    var outputs: SystemPermissionViewModelOutputs { get }
}

class SystemPermissionViewModel: SystemPermissionViewModelType,
                                 SystemPermissionViewModelInputs,
                                 SystemPermissionViewModelOutputs {

    var inputs: SystemPermissionViewModelInputs { return self }
    var outputs: SystemPermissionViewModelOutputs { return self }

    // MARK: Inputs
    var permissionObserver: AnyObserver<Void> { return permissionSubject.asObserver() }
    var termsConditionsObserver: AnyObserver<Void> { return termsConditionsSubject.asObserver() }
    var noThanksObserver: AnyObserver<Void> { return noThanksSubject.asObserver() }

    // MARK: Outputs
    var termsConditions: Observable<Void> { return termsConditionsSubject.asObservable() }
    var thanks: Observable<Void> { return noThanksSubject.asObservable() }
    // var icon: Observable<UIImage?> { return iconSubject.asObservable() }
    var loading: Observable<Bool> { return loadingSubject.asObservable() }
    var error: Observable<String> { return errorSubject.asObservable() }
    var success: Observable<Void> { return successSubject.asObservable() }
    var resources: Observable<SystemPermissionType> { return resourcesSubject.asObserver() }

    // MARK: Subjects
    fileprivate var termsConditionsSubject = PublishSubject<Void>()
    fileprivate var permissionSubject = PublishSubject<Void>()
    fileprivate var noThanksSubject = PublishSubject<Void>()
    // fileprivate var iconSubject = BehaviorSubject<UIImage?>(value: nil)
    fileprivate let loadingSubject = PublishSubject<Bool>()
    fileprivate let errorSubject = PublishSubject<String>()
    fileprivate let successSubject = PublishSubject<Void>()
    fileprivate let resourcesSubject: BehaviorSubject<SystemPermissionType>

    // MARK: Class Properties
    let disposeBag = DisposeBag()
    fileprivate var permissonPromptCompletion: () -> Void
    fileprivate var setPermissonCompletion: () -> Void

    // MARK: Init
    init(permissionType: SystemPermissionType,
         permissonPromptCompletion: @escaping () -> Void,
         setPermissonCompletion: @escaping () -> Void
    ) {
        self.permissonPromptCompletion = permissonPromptCompletion
        self.setPermissonCompletion = setPermissonCompletion
        self.resourcesSubject = BehaviorSubject<SystemPermissionType>.init(value: permissionType)

        noThanksSubject
            .do(onNext: { [unowned self] _ in self.permissonPromptCompletion() })
            .subscribe()
            .disposed(by: disposeBag)

        permissionSubject
            .do(onNext: { [unowned self] _ in
                self.permissonPromptCompletion()
                self.setPermissonCompletion()
            })
            .bind(to: successSubject)
            .disposed(by: disposeBag)
    }
}
