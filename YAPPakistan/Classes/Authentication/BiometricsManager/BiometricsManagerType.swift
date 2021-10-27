//
//  BiometricsManagerType.swift
//  YAPPakistan
//
//  Created by Sarmad on 26/10/2021.
//

import Foundation
import RxSwift

public protocol BiometricsManagerType {

    var isBiometrySupported: Bool { get }
    var deviceBiometryTypeString: String? { get }
    var deviceBiometryType: BiometryType { get }

    func isBiometryPermissionPrompt(for phone: String) -> Bool
    func setBiometryPermission(isPrompt: Bool, phone: String)
    func isBiometryEnabled(for phone: String) -> Bool
    func setBiometry(isEnabled: Bool, phone: String)
    func deleteBiometryForUser(phone: String)
    func canAuthenticateWithBiomatircs() -> Observable<Void>
    func biometricsAuthenticate(reason: String) -> Observable<Bool>
}
