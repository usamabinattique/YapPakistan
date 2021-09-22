//
//  DemographicsRepository.swift
//  YAPPakistan
//
//  Created by Tayyab on 22/09/2021.
//

import Foundation
import RxSwift

public protocol DemographicsRepositoryType {
    func saveDemographics(action: String, deviceId: String, deviceName: String, deviceModel: String,
                          osType: String, osVersion: String, token: String?) -> Observable<Event<String?>>
}

extension DemographicsRepositoryType {
    func saveDemographics(action: String, token: String?) -> Observable<Event<String?>> {
        return saveDemographics(action: action, deviceId: UIDevice.deviceID,
                                deviceName: UIDevice.current.name,
                                deviceModel: UIDevice.current.model,
                                osType: "iOS",
                                osVersion: UIDevice.current.systemVersion,
                                token: token)
    }
}

public class DemographicsRepository: DemographicsRepositoryType {
    private let customersService: CustomersService

    public init(customersService: CustomersService) {
        self.customersService = customersService
    }

    public func saveDemographics(action: String, deviceId: String, deviceName: String,
                                 deviceModel: String, osType: String, osVersion: String,
                                 token: String?) -> Observable<Event<String?>> {
        return customersService.saveDemographics(action: action, deviceId: deviceId,
                                                 deviceName: deviceName, deviceModel: deviceModel,
                                                 osType: osType, osVersion: osVersion, token: token).materialize()
    }
}
