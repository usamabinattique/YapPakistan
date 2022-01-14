//
//  APIResponseStatus.swift
//  Movies
//
//  Created by Zuhair on 2/17/19.
//  Copyright © 2019 Zuhair Hussain. All rights reserved.
//

/*
import Foundation

enum ErrorCode:Int {
    case success = 200, noNetwork = 503, unauthenticated = 401, unknown = 404, invalidRequest = 422, invalidResponse = 423, locationDenied = 5000, noServices = 5001
}

struct APIResponseStatus {
    var isSuccess = false
    var code: Int = 0
    var message = ""
    
    init() {}
    
    init(isSuccess: Bool, code: ErrorCode, message: String) {
        self.isSuccess = isSuccess
        self.code = code.rawValue
        self.message = message
    }
    
    init(isSuccess: Bool, code: Int, message: String) {
        self.isSuccess = isSuccess
        self.code = code
        self.message = message
    }
    
    init(error: NSError) {
        self.isSuccess = false
        self.code = error.code
        self.message = error.localizedDescription
    }
    
    init(error: Error) {
        let error = error as NSError
        self.isSuccess = false
        self.code = error.code
        self.message = error.localizedDescription
    }
    
    func isEqual(to errorCode:ErrorCode) -> Bool {
        return self.code == errorCode.rawValue
    }
    
    static var success: APIResponseStatus {
        return APIResponseStatus(isSuccess: true, code: .success, message: "ErrorString.noNetwork".localized)
    }
    static var noNetwork: APIResponseStatus {
        return APIResponseStatus(isSuccess: false, code: .noNetwork, message: "ErrorString.noNetwork".localized)
    }
    static var unauthenticated: APIResponseStatus {
        return APIResponseStatus(isSuccess: false, code: .unauthenticated, message: "ErrorString.unauthenticated".localized)
    }
    static var unknown: APIResponseStatus {
        return APIResponseStatus(isSuccess: false, code: .unknown, message: "ErrorString.unknown".localized)
    }
    static var invalidRequest: APIResponseStatus {
        return APIResponseStatus(isSuccess: false, code: .invalidRequest, message: "ErrorString.invalidRequest".localized)
    }
    static var invalidResponse: APIResponseStatus {
        return APIResponseStatus(isSuccess: false, code: .invalidResponse, message: "ErrorString.invalidResponse".localized)
    }
    static var locationDeniedRestricted:APIResponseStatus {
        return APIResponseStatus(isSuccess: false, code: .locationDenied, message: "ErrorString.locationDeniedRestricted".localized)
    }
    static var noserviceArea:APIResponseStatus {
        return APIResponseStatus(isSuccess: false, code: .noServices, message: "ErrorString.noServices".localized)
    }
    static func failureWith(message: String, code: Int) -> APIResponseStatus {
        return APIResponseStatus(isSuccess: false, code: code, message: message)
    }
}
*/
