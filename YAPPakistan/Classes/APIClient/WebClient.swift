//
//  WebClient.swift
//  Networking
//
//  Created by Muhammad Hassan on 18/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

public enum WebClientError: LocalizedError {
    case noInternet
    case requestTimedOut
    case badGateway
    case notFound
    case forbidden
    case internalServerError(InternalServerError?)
    case serverError(Int, String)
    case authError(AuthError?)
    case unknown
}

public struct ServerError: Codable {
    public let code: String
    public let message: String
}

public struct InternalServerError: Codable {
    public let errors: [ServerError]
}

public struct AuthError: Codable {
    public struct AuthErrorDetail: Codable {
        public let code: String
        public let message: String
    }
    public let error: AuthErrorDetail
}

private var QABaseURL: URL? {
    guard Bundle.main.object(forInfoDictionaryKey: "Environment") as? String == "QA" else { return nil }
    return UserDefaults.standard.url(forKey: "userEnteredBaseURL")
}

private var QAAdminURL: URL? {
    guard let baseURL = QABaseURL?.absoluteString else { return nil }
    return baseURL.contains("stg") ? URL(string: "https://stg-hci.yap.co") :
        baseURL.contains("dev") ? URL(string: "https://dev-hci.yap.co") :
        baseURL.contains("qa") ? URL(string: "https://qa-hci.yap.co") :
        baseURL.contains("preprod") ? URL(string: "https://ae-preprod-hci.yap.com") :
        baseURL.contains("prod") ? URL(string: "https://ae-prod-hci.yap.com") :
    nil
}

public var BaseURL: URL = {
    if let urlString = Bundle(for: WebClient.self).object(forInfoDictionaryKey: "BaseURL") as? String,
        let url = URL(string: urlString) {
        return QABaseURL ?? url
    } else {
        fatalError("URL not found.")
    }
}()

public var BaseURLAdmin: URL = {
    if let urlString = Bundle(for: WebClient.self).object(forInfoDictionaryKey: "BaseURLAdmin") as? String,
        let url = URL(string: urlString) {
        return QAAdminURL ?? url
    } else {
        fatalError("URL not found.")
    }
}()

public class WebClient: APIClient {

    private var session: Session

    public init() {
        let serverTrustPolicies : [String: PublicKeysTrustEvaluator] = [
            BaseURL.host ?? BaseURL.absoluteString : PublicKeysTrustEvaluator(keys: WebClient.publicSecuredKeys, performDefaultValidation: true, validateHost: true)
        ]

        session = Session(configuration: URLSessionConfiguration.default, serverTrustManager: WebClient.publicSecuredKeys.count > 0 ? ServerTrustManager(evaluators: serverTrustPolicies) : nil)
    }

    private static var publicSecuredKeys: [SecKey] {

        guard let publicKey = Bundle(for: WebClient.self).object(forInfoDictionaryKey: "PublicKey") as? String, publicKey != "NONE" else { return [] }

        guard let certificateData = Data(base64Encoded: publicKey, options: []), let certificate = SecCertificateCreateWithData(nil, certificateData as CFData) else { return [] }

        var trust: SecTrust?
        let policy = SecPolicyCreateBasicX509()
        let status = SecTrustCreateWithCertificates(certificate, policy, &trust)

        guard status == errSecSuccess, let secTrust = trust, let publicSecKey = SecTrustCopyPublicKey(secTrust) else { return [] }

        return [publicSecKey]
    }

    public func request(route: YAPURLRequestConvertible) -> Observable<APIResponseConvertible> {
        let urlRequest = route.urlRequest
        var requestUrl = ""
        if let url = urlRequest?.url?.absoluteString {
            requestUrl = url + " -> " + (String(data: urlRequest?.httpBody ?? Data(), encoding: .utf8) ?? "Failed to Convert")
            print("Initiating request: \(requestUrl)")
        }

        return Observable.create { [unowned self] observer in
            self.session.request(route).validate().responseData(completionHandler: { response in
                response.data.map { String(data: $0, encoding: .utf8 ).map { print("Response for : \(requestUrl)" + "\n" + $0) } }
                if response.error != nil {
                    let code = response.response?.statusCode ?? ((response.error!) as NSError).code
                    let errorData = response.data ?? Data()
                    let apiResponse = APIResponse(code: code, data: errorData)
                    observer.onNext(apiResponse)
                } else {
                    let code = response.response?.statusCode ?? 200
                    let data = response.data ?? Data()
                    let apiResponse = APIResponse(code: code, data: data)
                    observer.onNext(apiResponse)
                }
            })
            return Disposables.create()
        }
    }

    public func upload(documents: [DocumentDataConvertible], route: YAPURLRequestConvertible, progressObserver: AnyObserver<Progress>?, otherFormValues formValues: [String: String]) -> Observable<APIResponseConvertible> {
        let urlRequest = route.urlRequest
        if let url = urlRequest?.url?.absoluteString {
            print(url + " -> " + (String(data: urlRequest?.httpBody ?? Data(), encoding: .utf8) ?? "Failed to Convert"))
        }

        return Observable.create { [unowned self] observer in

            self.session.upload(multipartFormData: { (multipartFormData) in
                documents.forEach { multipartFormData.append($0.data, withName: $0.name, fileName: $0.fileName, mimeType: $0.mimeType) }

                formValues.forEach { multipartFormData.append($0.value.data(using: .utf8) ?? Data(), withName: $0.key) }
            }, with: route).response { response in

                guard response.error == nil else { observer.onError(response.error!); return }
                print(String(data: response.data!, encoding: .utf8 )!)
                if response.error != nil {
                    let code = response.response?.statusCode ?? ((response.error!) as NSError).code
                    let errorData = response.data ?? Data()
                    let apiResponse = APIResponse(code: code, data: errorData)
                    observer.onNext(apiResponse)
                } else {
                    let code = response.response?.statusCode ?? 200
                    let data = response.data ?? Data()
                    let apiResponse = APIResponse(code: code, data: data)
                    observer.onNext(apiResponse)
                }
            }
            return Disposables.create()
        }
    }
}
