//
//  SystemPermissionViewModel.swift
//  App
//
//  Created by Uzair on 18/06/2021.
//

import Foundation
import RxSwift

protocol SystemPermissionViewModelInputs {
    var backObserver: AnyObserver<Void> { get }
    var onPermissionObserver: AnyObserver<Void> { get }
    var onTermsConditionsObserver: AnyObserver<Void> { get }
    var onNoThanksObserver: AnyObserver<Void> { get }
    var successObserver: AnyObserver<Void> { get }
}

protocol SystemPermissionViewModelOutputs {
    var back: Observable<Void> { get }
    var permissionType: Observable<SystemPermissionType> { get }
    var permission: Observable<Void> { get }
    var termsConditions: Observable<Void> { get }
    var thanks: Observable<Void> { get }
    var icon: Observable<UIImage?> { get }
    var iconBackground: Observable<UIColor> { get }
    var heading: Observable<String> { get }
    var subHeading: Observable<String> { get }
    var termsConditionDescription: Observable<String> { get }
    var buttonTitle: Observable<String> { get }
    var loading: Observable<Bool> { get }
    var error: Observable<String> { get }
    var success: Observable<Void> { get }
}

protocol SystemPermissionViewModelType {
    var inputs: SystemPermissionViewModelInputs { get }
    var outputs: SystemPermissionViewModelOutputs { get }
}

class SystemPermissionViewModel: SystemPermissionViewModelType, SystemPermissionViewModelInputs, SystemPermissionViewModelOutputs {
    
    var inputs: SystemPermissionViewModelInputs { return self}
    var outputs: SystemPermissionViewModelOutputs { return self }
    
    private var backSubject = PublishSubject<Void>()
    private var permissionTypeSubject: BehaviorSubject<SystemPermissionType>!
    private var termsConditionsSubject = PublishSubject<Void>()
    private var permissionSubject = PublishSubject<Void>()
    private var noThanksSubject = PublishSubject<Void>()
    private var iconSubject = BehaviorSubject<UIImage?>(value: nil)
    private var iconBackgroundSubject = BehaviorSubject<UIColor>(value: .clear)
    private var headingSubject = BehaviorSubject<String>(value: "")
    private var subHeadingSubject = BehaviorSubject<String>(value: "")
    private var termsConditionDescriptionSubject = BehaviorSubject<String>(value: "")
    private var buttonTitleSubject = BehaviorSubject<String>(value: "")
    private let errorSubject = PublishSubject<String>()
    private let loadingSubject = PublishSubject<Bool>()
    private let successSubject = PublishSubject<Void>()
    
    // MARK: Inputs
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    var onPermissionObserver: AnyObserver<Void> { return permissionSubject.asObserver() }
    var onTermsConditionsObserver: AnyObserver<Void> { return termsConditionsSubject.asObserver() }
    var onNoThanksObserver: AnyObserver<Void> { return noThanksSubject.asObserver() }
    var successObserver: AnyObserver<Void> { return successSubject.asObserver() }
    
    // MARK: Outputs
    var back: Observable<Void> { return backSubject.asObservable() }
    var permission: Observable<Void> { return permissionSubject.asObservable() }
    var permissionType: Observable<SystemPermissionType> { return permissionTypeSubject.asObservable() }
    var termsConditions: Observable<Void> { return termsConditionsSubject.asObservable() }
    var thanks: Observable<Void> { return noThanksSubject.asObservable() }
    var icon: Observable<UIImage?> { return iconSubject.asObservable() }
    var heading: Observable<String> { return headingSubject.asObservable() }
    var subHeading: Observable<String> { subHeadingSubject.asObservable() }
    var termsConditionDescription: Observable<String> { return termsConditionDescriptionSubject.asObservable()}
    var buttonTitle: Observable<String> { return buttonTitleSubject.asObservable() }
    var loading: Observable<Bool> { return loadingSubject.asObservable() }
    var error: Observable<String> { return errorSubject.asObservable()   }
    var success: Observable<Void> { return successSubject.asObservable() }
    var iconBackground: Observable<UIColor> { iconBackgroundSubject.asObservable() }
    
    
    // MARK: Class Properties
    let disposeBag = DisposeBag()
    
    // MARK: Init
    init(permissionType: SystemPermissionType, account: Observable<Account?>) {
        permissionTypeSubject = BehaviorSubject(value: permissionType)
        propertiesInitialisation(type: permissionType)
        
        account.subscribe(onNext: { account in
            
        }).disposed(by: disposeBag)
        
        account.unwrap().map{ $0.customer }.take(1).subscribe(onNext: {
            switch permissionType {
            case .faceID, .touchID:
                BiometricsManager().setBiometryPermission(isPrompt: true, phone: $0.mobileNo, email: $0.email)
            case .notification:
                NotificationManager.shared.setNotificationPermission(isPrompt: true)
            }
        }).disposed(by: disposeBag)

        permissionSubject.withLatestFrom(account.unwrap().map{ $0.customer })
            .do(onNext: {
                switch permissionType {
                case .notification:
                    (UIApplication.shared.delegate as? PublicAppDelegate)?.registerForPushNotifications()
                case .faceID, .touchID:
                    BiometricsManager().setBiometry(isEnabled: true, phone: $0.mobileNo, email: $0.email)
                }
            }).map{ _ in}
            .bind(to: successSubject)
            .disposed(by: disposeBag)
    }
}

extension SystemPermissionViewModel {
    func propertiesInitialisation(type: SystemPermissionType) {
        switch type {
        case .faceID:
            iconSubject.onNext(UIImage(named: "icon_face_id")!)
            headingSubject.onNext("screen_system_permission_text_title_face_id".localized)
            subHeadingSubject.onNext("screen_system_permission_text_details_face_id".localized)
            termsConditionDescriptionSubject.onNext(String(format:  "screen_system_permission_text_title_terms_and_conditions".localized, type.rawValue))
            buttonTitleSubject.onNext(String(format:  "screen_system_permission_button_touch_id".localized, type.rawValue))
        case .touchID:
            iconSubject.onNext(UIImage(named: "icon_touch_id")!)
            headingSubject.onNext("screen_system_permission_text_title_touch_id".localized)
            subHeadingSubject.onNext("screen_system_permission_text_details_touch_id".localized)
            termsConditionDescriptionSubject.onNext(String(format:  "screen_system_permission_text_title_terms_and_conditions".localized, type.rawValue))
            buttonTitleSubject.onNext(String(format:  "screen_system_permission_button_touch_id".localized, type.rawValue))
        case .notification:
            iconSubject.onNext(UIImage(named: "icon_notifications")?.asTemplate)
            iconBackgroundSubject.onNext(UIColor.primary.withAlphaComponent(0.15))
            headingSubject.onNext("screen_system_permission_text_title_notification".localized)
            subHeadingSubject.onNext("screen_system_permission_text_details_notification".localized)
            termsConditionDescriptionSubject.onNext(String(format:  "screen_system_permission_text_title_terms_and_conditions".localized, type.rawValue))
            buttonTitleSubject.onNext( "screen_notification_permission_button_title".localized)
        }
    }
    
    static func systemPermissionTypeFor(biometryType: BiometryType) -> SystemPermissionType {
        if case BiometryType.faceID = biometryType { return .faceID } else { return .touchID }
    }
}
