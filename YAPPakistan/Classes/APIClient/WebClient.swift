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

// swiftlint:disable identifier_name
// swiftlint:disable line_length
let BASE_URL = "https://pk-dev.yap.co"
let BASE_URL_ADMIN = "https:/$()/dev-hci.yap.co"
let PUBLIC_KEY = "MIIGxDCCBaygAwIBAgIJANerZJE7qcSaMA0GCSqGSIb3DQEBCwUAMIG0MQswCQYDVQQGEwJVUzEQMA4GA1UECBMHQXJpem9uYTETMBEGA1UEBxMKU2NvdHRzZGFsZTEaMBgGA1UEChMRR29EYWRkeS5jb20sIEluYy4xLTArBgNVBAsTJGh0dHA6Ly9jZXJ0cy5nb2RhZGR5LmNvbS9yZXBvc2l0b3J5LzEzMDEGA1UEAxMqR28gRGFkZHkgU2VjdXJlIENlcnRpZmljYXRlIEF1dGhvcml0eSAtIEcyMB4XDTIwMDIxODE1MzY0MVoXDTIyMDIxODE1MzY0MVowWzELMAkGA1UEBhMCQUUxDjAMBgNVBAgTBUR1YmFpMQ4wDAYDVQQHEwVEdWJhaTEYMBYGA1UEChMPWUFQIEhvbGRpbmcgTFREMRIwEAYDVQQDDAkqLnlhcC5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCnIQBPM0Eieu1cGPhduRKUNeNHjQ0vtZRpu/$()/W+A0LFieXhwu0jlivjL4CeGwvFuqQPSDXEoQOWrf4BpsiGcOvqr9MwpyMUoArLO7gu906xBkFcve15wGJtR6tdlBTw40PmvpOa+/kii+vUA+5YaOVfB6fZqnMmpxpDEBF1HQRm5/GO1S8o1ISvFGpq47aB4+ZRUb20SKFXPC13zvfGTaPAHXxHTIUBKLz6TRsgCX8wjvFzEDLrd48UBc9+RzQ8arAe12zCZ9mLf7gtb+i0o/Rel4wwkyaDhUOMAyrD432a7Etw1gIsFBZ/foa8sUyakQnKaYQVqosOcBLnMCo5Wn1AgMBAAGjggMvMIIDKzAMBgNVHRMBAf8EAjAAMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAOBgNVHQ8BAf8EBAMCBaAwNgYDVR0fBC8wLTAroCmgJ4YlaHR0cDovL2NybC5nb2RhZGR5LmNvbS9nZGlnMnMyLTE1LmNybDBdBgNVHSAEVjBUMEgGC2CGSAGG/W0BBxcCMDkwNwYIKwYBBQUHAgEWK2h0dHA6Ly9jZXJ0aWZpY2F0ZXMuZ29kYWRkeS5jb20vcmVwb3NpdG9yeS8wCAYGZ4EMAQICMHYGCCsGAQUFBwEBBGowaDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZ29kYWRkeS5jb20vMEAGCCsGAQUFBzAChjRodHRwOi8vY2VydGlmaWNhdGVzLmdvZGFkZHkuY29tL3JlcG9zaXRvcnkvZ2RpZzIuY3J0MB8GA1UdIwQYMBaAFEDCvSeOzDSDMKIz1/tss/C0LIDOMB0GA1UdEQQWMBSCCSoueWFwLmNvbYIHeWFwLmNvbTAdBgNVHQ4EFgQUII6Z4HzA3Y4jaWjL18TwFRRRoRwwggF8BgorBgEEAdZ5AgQCBIIBbASCAWgBZgB1AKS5CZC0GFgUh7sTosxncAo8NZgE+RvfuON3zQ7IDdwQAAABcFjx1+YAAAQDAEYwRAIgZDkRvWkgPkTmgQbvNNKCgG/gh7nnHL855miickG1vDgCIDZ5ivYroKpYRsQYC3BlMKvVYQYzHaTJYX6cePjHlLh7AHYA7ku9t3XOYLrhQmkfq+GeZqMPfl+wctiDAMR7iXqo/csAAAFwWPHcQQAABAMARzBFAiBi5dB4C+12FfPJ834p4ZOHIXItjnauwRlSVGv7iVklzQIhANYt8Sb0Px8ry43Bv+q8cFjEXABlJWFIUJG91V7bY3tEAHUAVhQGmi/XwuzT9eG9RLI+x0Z2ubyZEVzA75SYVdaJ0N0AAAFwWPHfDQAABAMARjBEAiBj6eCmtk4WQyxlCj1cRDRd6OctaJm/BAl/4Q4BpidwcAIgQPkYD1UlMXsF+PbTIHeviJBDEect1XF/Z5B9IymC08EwDQYJKoZIhvcNAQELBQADggEBAJ8xOro1Z40M7YPI35qATjDupdg0/mJJDlTujVLfwCuRxbRbXiFGa0DU5V8P/Oa8hRtaxrvdqb2z4mrIWkZWwwzhOyFOPjUaUuNhVt6/PBzoGmVq403IQU6cdODist0Vkst9GYoHFp9nkzM5cC845aaxBhPr73eG4fxJlQ5pP7VWxtiJ8yEzJLDwMZ9cSGiqJYXGoo+hDLv33yWoYQRhPTbw5im0jOHbJV+hmGy1W7WCHqRFHGfTIbKn0CEyEkJCvKhlK1T5C6gRlCnqMCMyNVQTN7UqBci2JETtCwrxW5FbfrlMyvwHV+y5aMfM+PXCadIQd5y76oMbh/KN/jbMGy8="

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
    // if
    let urlString: String = BASE_URL // Bundle(for: WebClient.self).object(forInfoDictionaryKey: "BaseURL") as? String,
    if let url = URL(string: urlString) {
        return QABaseURL ?? url
    } else {
        fatalError("URL not found.")
    }
}()

public var baseURLAdmin: URL = {
    // if
    let urlString = BASE_URL_ADMIN // Bundle(for: WebClient.self).object(forInfoDictionaryKey: "BaseURLAdmin") as? String,
    if let url = URL(string: urlString) {
        return QAAdminURL ?? url
    } else {
        fatalError("URL not found.")
    }
}()

public class WebClient: APIClient {

    private var session: Alamofire.Session

    public init() {
        let serverTrustPolicies: [String: PublicKeysTrustEvaluator] = [
            BaseURL.host ?? BaseURL.absoluteString: PublicKeysTrustEvaluator(keys: WebClient.publicSecuredKeys, performDefaultValidation: true, validateHost: true)
        ]

        session = Alamofire.Session(configuration: URLSessionConfiguration.default,
                                    serverTrustManager: WebClient.publicSecuredKeys.count > 0 ?
                                        ServerTrustManager(evaluators: serverTrustPolicies) : nil)
    }

    private static var publicSecuredKeys: [SecKey] {

        // guard
        let publicKey = PUBLIC_KEY // Bundle(for: WebClient.self).object(forInfoDictionaryKey: "PublicKey") as? String, publicKey != "NONE" else { return [] }

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
            #if DEBUG
            print("Initiating request: \(requestUrl)")
            print("HEADERS")
            urlRequest?.allHTTPHeaderFields?.forEach { print("\($0.key) : \($0.value)") }
            #endif
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

    public func upload(documents: [DocumentDataConvertible],
                       route: YAPURLRequestConvertible,
                       progressObserver: AnyObserver<Progress>?,
                       otherFormValues formValues: [String: String]) -> Observable<APIResponseConvertible> {
        let urlRequest = route.urlRequest
        if let url = urlRequest?.url?.absoluteString {
            print(url + " -> " + (String(data: urlRequest?.httpBody ?? Data(), encoding: .utf8) ?? "Failed to Convert"))
        }

        return Observable.create { [unowned self] observer in

            self.session.upload(multipartFormData: { multipartFormData in
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
