//
//  BiometryManager.swift
//  Authentication
//
//  Created by Hussaan S on 27/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import LocalAuthentication
import RxSwift

public typealias BiometryType = LABiometryType

extension BiometryType {
    public var title: String? {
        switch self {
        case .none:
            return nil
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        @unknown default:
            return nil
        }
    }
}

public class BiometricsManager {

    private let context: LAContext = LAContext()

    public init() {
        guard deviceBiometryType == .none else { return }
        setBiometryPermission(isPrompt: false, phone: "", email: "")
    }

    public func isBiometryPermissionPrompt(for username: String) -> Bool {
        return  UserDefaults.standard.bool(forKey: "USER_DEFAULTS_KEY_BIOMETRY_PERMISSION_PROMPT" + username)
    }

    public func setBiometryPermission(isPrompt: Bool, phone: String, email: String) {
        UserDefaults.standard.set(isPrompt, forKey: "USER_DEFAULTS_KEY_BIOMETRY_PERMISSION_PROMPT" + phone)
        UserDefaults.standard.set(isPrompt, forKey: "USER_DEFAULTS_KEY_BIOMETRY_PERMISSION_PROMPT" + email)
    }

    public func isBiometryEnabled(for username: String) -> Bool {
       return  UserDefaults.standard.bool(forKey: "USER_DEFAULTS_KEY_BIOMETRY_STATUS" + username)
    }

    public func setBiometry(isEnabled: Bool, phone: String, email: String) {
        UserDefaults.standard.set(isEnabled, forKey: "USER_DEFAULTS_KEY_BIOMETRY_STATUS" + phone)
        UserDefaults.standard.set(isEnabled, forKey: "USER_DEFAULTS_KEY_BIOMETRY_STATUS" + email)
    }

    public func deleteBiometryForUser(username: String) {
        UserDefaults.standard.removeObject(forKey: "USER_DEFAULTS_KEY_BIOMETRY_STATUS" + username)
        UserDefaults.standard.removeObject(forKey: "USER_DEFAULTS_KEY_BIOMETRY_PERMISSION_PROMPT" + username)
    }

    public var isBiometrySupported: Bool {
        deviceBiometryType != .none
    }

    public var deviceBiometryTypeString: String? {
        let type = deviceBiometryType
        return type.title
    }

    public var deviceBiometryType: BiometryType {
        var type: BiometryType = .none
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            type = context.biometryType
        }
        return type
    }

    public func canAuthenticateWithBiomatircs() -> Observable<Void> {
        return Observable<Void>.create { [unowned self] observer in
            var error: NSError?
            if self.context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                observer.onNext(())
            } else {
                observer.onError(error ?? NSError(domain: "com.apple.LocalAuthentication", code: -100, userInfo: nil))
            }
            return Disposables.create()
        }
    }

    // TODO: AppTranslation.shared.translation(forKey: "screen_verify_passcode_display_text_biometrics_reason")
    public func biometricsAuthenticate(reason: String = "") -> Observable<Bool> {
        let canAuthenticate = canAuthenticateWithBiomatircs().share()
        return canAuthenticate.catchAndReturn(()).flatMap { _ -> Observable<Bool> in
            return Observable<Bool>.create { [unowned self]  observer in
                let reason = reason
                // TODO: AppTranslation.shared.translation(forKey: "screen_verify_passcode_text_enter_passcode")
                self.context.localizedFallbackTitle = ""
                self.context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason ) { success, error in
                    if success {
                        observer.onNext(true)
                    } else {
                        observer.onError(error ?? NSError(domain: "com.apple.LocalAuthentication", code: -100, userInfo: nil))
                    }
                }
                return Disposables.create()
            }
                .observe(on: MainScheduler.instance)
        }
    }
}
