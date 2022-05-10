//
//  CustomersService.swift
//  YAPPakistan
//
//  Created by Tayyab on 26/08/2021.
//

import Foundation
import RxSwift

public enum RecentServicesType: String{
    case Y2Y = "Y2Y"
    case BankTransfer = "BANK_TRANSFER"
    case None = ""
}

public protocol CustomerServiceType {
    func signUpEmail<T: Codable>( email: String,
                                  otpToken: String,
                                  accountType: String ) -> Observable<T>

    func saveProfile<T: Codable>( countryCode: String,
                                  mobileNo: String,
                                  passcode: String,
                                  firstName: String,
                                  lastName: String,
                                  email: String,
                                  token: String,
                                  whiteListed: Bool,
                                  accountType: String ) -> Observable<T>

    func saveDemographics<T: Codable>( action: String,
                                       deviceId: String,
                                       deviceName: String,
                                       deviceModel: String,
                                       osType: String,
                                       osVersion: String,
                                       token: String?) -> Observable<T>

    func fetchAccounts<T: Codable>() -> Observable<T>

    func assignIBAN<T: Codable>(countryCode: String, mobileNo: String) -> Observable<T>

    func saveInvite<T: Codable>( inviterCustomerId: String,
                                 referralDate: String) -> Observable<T>

    func fetchRanking<T: Codable>() -> Observable<T>

    func saveReferralInvitation<T: Codable>(inviterCustomerId: String,
                                            referralDate: String) -> Observable<T>

    func verifyUser<T: Codable>(username: String) -> Observable<T>
    
    func verifyPasscode<T: Codable>(passcode: String) -> Observable<T>
    
    func updatePasscode<T: Codable>(newPasscode: String, token : String) -> Observable<T>
    
    
    func generateLoginOTP<T: Codable>(username: String,
                                      passcode: String,
                                      deviceID: String) -> Observable<T>
    
    func verifyLoginOTP<T: Codable>(username: String,
                                           passcode: String,
                                           deviceID: String,
                                           otp: String) -> Observable<T>

    func fetchDocument<T: Codable>(byType documentType: String) -> Observable<T>

    func newPassword<T: Codable>(username: String, token: String, password: String) -> Observable<T>
    func detectCNICInfo<T: Codable>(_ documents: [(fileName: String, data: Data, format: String)],
                                    progressObserver: AnyObserver<Progress>?) -> Observable<T>
    func performNadraVerification<T: Codable>(cnic: String, dateOfIssuance: String) -> Observable<T>
    func uploadSelfie<T: Codable>(_ selfie: (data: Data, format: String)) -> Observable<T>
    func setCardName<T: Codable>(cardName: String) -> Observable<T>
    
    func fetchRecentBeneficiaries<T: Codable>(_ type:RecentServicesType) -> Observable<T>
    func fetchRecentY2YBeneficiaries<T: Codable>() -> Observable<T>
    func fetchRecentSendMoneyBeneficiaries<T: Codable>() -> Observable<T>
    
    func classifyContacts<T: Codable>(contacts: [(name: String, phoneNumber: String, email: String?, photoUrl: String?, countryCode: String)]) -> Observable<T>
    func fetchCustomerAccountBalance<T: Codable>() -> Observable<T>
    func fetchPaymentGatewayBeneficiaries<T: Codable>() -> Observable<T>
    func addOnboardingExternalCardBeneficiaries<T: Codable>(alias: String, color: String, sessionId: String, cardNumber: String) -> Observable<T>
    func addTopupExternalCardBeneficiaries<T: Codable>(alias: String, color: String, sessionId: String, cardNumber: String) -> Observable<T>
    func deletePaymentGatewayBeneficiary<T: Codable>(id: String) -> Observable<T>
    func getCustomerInfoFromQR<T: Codable>(_ qrString: String) -> Observable<T>
    func getBankDetail<T: Codable>() -> Observable<T>
    func fetchBeneficiaryAccountTitle<T: Codable>(accountNo: String, consumerId: String) -> Observable<T>
    func addBankBenefiiary<T: Codable>(input body: AddBankBeneficiaryRequest) -> Observable<T>
    func updateEmail<T: Codable>(input email : String) -> Observable<T>
    func updateMobileNumber<T: Codable>(countryCode: String, mobileNumber: String) -> Observable<T>
    func fetchCustomerPersonalDetails<T: Codable>() -> Observable<T>
    func getDashboardWidgets<T: Codable> () -> Observable<T>
    func updateDashboardWidgets<T:Codable>(widgets: [DashboardWidgetsRequest], uuid: String, customer_uuid: String)-> Observable<T>
}

    
public class CustomersService: BaseService, CustomerServiceType {
    
    public func updateEmail<T: Codable>(input email: String) -> Observable<T> {
        let pathVariables = [email]
        //let route = APIEndpoint(.put, apiConfig.customersURL, "/api/change-email", pathVariables: pathVariables, headers: authorizationProvider.authorizationHeaders)
        let route = APIEndpoint<String>(.put, apiConfig.customersURL, "/api/change-email", pathVariables: pathVariables, headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func updateMobileNumber<T: Codable>(countryCode: String, mobileNumber: String) -> Observable<T> {
        let pathVariables = [countryCode, mobileNumber]
        //let route = APIEndpoint(.put, apiConfig.customersURL, "/api/change-email", pathVariables: pathVariables, headers: authorizationProvider.authorizationHeaders)
        let route = APIEndpoint<String>(.put, apiConfig.customersURL, "/api/change-mobile-number", pathVariables: pathVariables, headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func fetchCustomerPersonalDetails<T>() -> Observable<T> where T : Decodable, T : Encodable {
//        let pathVariables = ["personalAddress=true"]
        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/customer/personal-details", pathVariables: nil,body: nil ,headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func signUpEmail<T: Codable>(email: String, otpToken: String,
                                        accountType: String = "B2C_ACCOUNT") -> Observable<T> {
        let body = SignUpEmailRequest(email: email, accountType: accountType, token: otpToken)
        let route = APIEndpoint(.post, apiConfig.customersURL, "/api/sign-up/email", body: body, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func saveProfile<T: Codable>(countryCode: String, mobileNo: String, passcode: String,
                                        firstName: String, lastName: String, email: String,
                                        token: String, whiteListed: Bool,
                                        accountType: String = "B2C_ACCOUNT") -> Observable<T> {
        let body = SaveProfileRequest(countryCode: countryCode, mobileNo: mobileNo,
                                      passcode: passcode, firstName: firstName, lastName: lastName,
                                      email: email, token: token, whiteListed: whiteListed,
                                      accountType: accountType)
        let route = APIEndpoint(.post,
                                apiConfig.customersURL, "/api/profile",
                                body: body,
                                headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func saveDemographics<T: Codable>(action: String, deviceId: String, deviceName: String,
                                             deviceModel: String, osType: String, osVersion: String,
                                             token: String?) -> Observable<T> {
        let body = SaveDemographicsRequest(action: action, deviceId: deviceId,
                                           deviceName: deviceName, deviceModel: deviceModel,
                                           osType: osType, osVersion: osVersion, token: token)
        let route = APIEndpoint(.put, apiConfig.customersURL, "/api/demographics/", body: body,
                                headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func fetchAccounts<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/accounts", headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func assignIBAN<T: Codable>(countryCode: String, mobileNo: String) -> Observable<T> {
        let body = [
            "countryCode": countryCode,
            "mobileNo": mobileNo
        ]
        let route = APIEndpoint(.post, apiConfig.customersURL, "/api/v2/profile", body: body,
                                headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func saveInvite<T: Codable>(inviterCustomerId: String, referralDate: String) -> Observable<T> {
        let body = [
            "inviterCustomerId": inviterCustomerId,
            "referralDate": referralDate
        ]

        let route = APIEndpoint(.post, apiConfig.customersURL, "/api/save-invite", body: body,
                                headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func fetchRanking<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/portal/fetch-ranking", headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func saveReferralInvitation<T: Codable>(inviterCustomerId: String, referralDate: String) -> Observable<T> {
        let body = [
            "inviterCustomerId": inviterCustomerId,
            "referralDate": referralDate
        ]

        let route = APIEndpoint(.post, apiConfig.customersURL, "/api/save-referral-invitation", body: body,
                                headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func verifyUser<T: Codable>(username: String) -> Observable<T> {
        let query = ["username": username]
        
        let route = APIEndpoint<String>(.post, apiConfig.customersURL, "/api/verify-user", query: query, headers: authorizationProvider.authorizationHeaders)
        
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func uploadProfilePhoto<T: Codable>(data: Data, name: String, fileName: String, mimeType: String, progressObserver: AnyObserver<Progress>?) -> Observable<T> {
        let photoRequest = DocumentUploadRequest(data: data, name: name, fileName: fileName, mimeType: mimeType)
        let documents = [photoRequest]
        
        
//        let profilePhotoRequest = ProfilePhotoRequest.init(profilePicture: photoRequest.data)
//        let input = RouterInput(body: profilePhotoRequest, query: nil, pathVariables: nil)
//        let route = CustomersRouter.uploadPhoto(input)
        
        let route = APIEndpoint(.post,
                                apiConfig.customersURL,
                                "/api/customers/profile-picture",
                                body: documents,
                                headers: authorizationProvider.authorizationHeaders)
        
        return self.upload(apiClient: apiClient, documents: documents, route: route, progressObserver: progressObserver, otherFormValues: [:])
    }
    
    public func removeProfilePhoto<T: Codable>() -> Observable<T> {
        let router = APIEndpoint<String>(.delete,
                                 apiConfig.customersURL,
                                 "/api/customers/profile-picture",
                                 query: nil,
                                 body: nil,
                                 headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: router)
    }
    
    public func verifyPasscode<T: Codable>(passcode: String) -> Observable<T> {
        let body = ["passcode": passcode]

        let route = APIEndpoint(.post,
                                apiConfig.customersURL,
                                "/api/user/verify-passcode",
                                query: nil,
                                body: body,
                                headers: authorizationProvider.authorizationHeaders)
        
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func updatePasscode<T: Codable>(newPasscode: String, token : String) -> Observable<T> {
        let body = ["new-password": newPasscode,
                    "token": token]

        let route = APIEndpoint(.post,
                                apiConfig.customersURL,
                                "/api/user/change-password",
                                query: nil,
                                body: body,
                                headers: authorizationProvider.authorizationHeaders)
        
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func generateLoginOTP<T: Codable>(username: String, passcode: String, deviceID: String) -> Observable<T> {
        let request = [
            "clientId": username,
            "clientSecret": passcode,
            "deviceId": deviceID
        ]

        let route = APIEndpoint(.post, apiConfig.customersURL, "/api/demographics/device-login",
                                body: request, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func verifyLoginOTP<T: Codable>(username: String, passcode: String, deviceID: String, otp: String) -> Observable<T> {
        let body = [
            "clientId": username,
            "clientSecret": passcode,
            "deviceId": deviceID,
            "otp": otp
        ]

        let route = APIEndpoint(.put, apiConfig.customersURL, "/api/demographics/device-login",
                                body: body, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func fetchDocument<T: Codable>(byType documentType: String) -> Observable<T> {
        let params = ["documentType": documentType]
        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/document-information",
                                        query: params,
                                        headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: apiClient, route: route)
    }

    public func newPassword<T: Codable>(username: String, token: String, password: String) -> Observable<T> {
        let body = [
            "mobileNo": username,
            "token": token,
            "newPassword": password
        ]

        let route = APIEndpoint(.put, apiConfig.customersURL, "/api/forgot-password",
                                body: body, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func detectCNICInfo<T: Codable>(_ documents: [(fileName: String, data: Data, format: String)],
                                           progressObserver: AnyObserver<Progress>? = nil) -> Observable<T> {
        var docs: [DocumentUploadRequest] = []
        for document in documents {
            let info = fileInfo(from: document.fileName, format: document.format)
            docs.append(DocumentUploadRequest(data: document.data, name: info.0, fileName: info.1, mimeType: info.2))
        }

        let route = APIEndpoint<String>(.post, apiConfig.baseURL, "/digi-ocr/detect/",
                                        headers: authorizationProvider.authorizationHeaders)

        return upload(apiClient: apiClient,
                      documents: docs,
                      route: route,
                      progressObserver: progressObserver,
                      otherFormValues: [:])
    }

    public func performNadraVerification<T: Codable>(cnic: String, dateOfIssuance: String) -> Observable<T> {
        let body = [
            "cnic": cnic,
            "dateOfIssuance": dateOfIssuance
        ]
        let route = APIEndpoint(.post, apiConfig.customersURL, "/api/kyc/document-data",
                                body: body, headers: authorizationProvider.authorizationHeaders)

        return request(apiClient: apiClient, route: route)
    }

    public func saveDocuments<T: Codable>(_ documents: [(data: Data, format: String)],
                                          documentType: String, identityNo: String,
                                          nationality: String, fullName: String, fatherName: String, gender: String,
                                          dob: String, dateIssue: String, dateExpiry: String) -> Observable<T> {
        var docs: [DocumentUploadRequest] = []
        for document in documents {
            let info = fileInfo(format: document.format)
            docs.append(DocumentUploadRequest(data: document.data, name: info.0, fileName: info.1, mimeType: info.2))
        }

        let formData = [
            "documentType": documentType,
            "identityNo": identityNo,
            "nationality": nationality,
            "firstName": fullName,
            "lastName": fatherName,
            "fullName": fullName+fatherName,
            "gender": gender,
            "dob": dob,
            "dateIssue": dateIssue,
            "dateExpiry": dateExpiry
        ]

        let route = APIEndpoint<String>(.post, apiConfig.customersURL, "/api/v2/documents",
                                        headers: authorizationProvider.authorizationHeaders)

        return upload(apiClient: apiClient, documents: docs, route: route,
                      progressObserver: nil, otherFormValues: formData)
    }

    public func getMotherMaidenNames<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/getMotherMaidenNames", headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func getCityOfBirthNames<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/getCityOfBirthNames", headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func verifySecretQuestions<T: Codable>(motherMaidenName: String, cityOfBirth: String ) -> Observable<T> {
        let body:[String:String] = [
            "motherMaidenName": motherMaidenName,
            "cityOfBirth": cityOfBirth
        ]

        let route = APIEndpoint(.post, apiConfig.customersURL, "/api/verifySecretQuestions", body: body, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func uploadSelfie<T: Codable>(_ selfie: (data: Data, format: String)) -> Observable<T> {
        var docs: [DocumentUploadRequest] = []
        let info = fileInfo(format: selfie.format)
        docs.append(DocumentUploadRequest(data: selfie.data,
                                          name: "selfie-picture",
                                          fileName: info.1,
                                          mimeType: info.2))

        let route = APIEndpoint<String>(.post, apiConfig.customersURL, "/api/customers/selfie-picture",
                                        headers: authorizationProvider.authorizationHeaders)

        return upload(apiClient: apiClient, documents: docs, route: route,
                      progressObserver: nil, otherFormValues: [:])
    }

    public func setCardName<T: Codable>(cardName: String) -> Observable<T> {
        let query = [
            "cardName": cardName
        ]
        let route = APIEndpoint(.post, apiConfig.customersURL, "/api/accounts/set-card-name",
                                 query: query,
                                 body: ([:] as [String: String]),
                                 headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func getCities<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/cities", headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func fetchRecentBeneficiaries<T: Codable>(_ type:RecentServicesType = .None) -> Observable<T> {
        let params = ["type": type.rawValue]
        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/beneficiaries/recent", query: params, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func fetchRecentY2YBeneficiaries<T: Codable>() -> Observable<T> {
        let params = ["type": "Y2Y"]
        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/beneficiaries/recent", query: params, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func fetchAllIBFTBeneficiaries<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/beneficiaries/bank-transfer", headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func fetchRecentSendMoneyBeneficiaries<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/beneficiaries/recent", query: ["type" : "BANK_TRANSFER"], headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
        
//        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/beneficiaries/bank-transfer", headers: authorizationProvider.authorizationHeaders)
//        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func editBeneficiary<T: Codable>(_ documents: [(data: Data, format: String)],
                                            id: String,
                                            nickname: String?) -> Observable<T> {
        var docs: [DocumentUploadRequest] = []
        for document in documents {
            let info = fileInfo(format: document.format)
            docs.append(DocumentUploadRequest(data: document.data, name: info.0, fileName: info.1, mimeType: info.2))
        }

        var formData = [ "id": id ]
        if let nick = nickname { formData.updateValue(nick, forKey: "nickName") }

        let route = APIEndpoint<String>(.put, apiConfig.customersURL, "/api/beneficiaries/bank-transfer",
                                        headers: authorizationProvider.authorizationHeaders)

        return upload(apiClient: apiClient, documents: docs, route: route,
                      progressObserver: nil, otherFormValues: formData)
    }
    
    public func deleteBeneficiary<T: Codable>(id: String) -> Observable<T> {
        let route = APIEndpoint<String>(.delete, apiConfig.customersURL, "/api/beneficiaries/bank-transfer/\(id)", headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func classifyContacts<T: Codable>(contacts: [(name: String, phoneNumber: String, email: String?, photoUrl: String?, countryCode: String)]) -> Observable<T> {
        var allContacts = [Contact]()
        for contact in contacts {

            allContacts.append(Contact(name: contact.name, phoneNumber: contact.phoneNumber, countryCode: contact.countryCode, email: contact.email, photoUrl: contact.photoUrl))
        }

        let route = APIEndpoint(.post, apiConfig.customersURL, "/api/y2y-beneficiaries", body: allContacts, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func fetchCustomerAccountBalance<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/account/balance", headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func fetchPaymentGatewayBeneficiaries<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/mastercard/beneficiaries", headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func addOnboardingExternalCardBeneficiaries<T: Codable>(alias: String, color: String, sessionId: String, cardNumber: String) -> Observable<T> {
        
        let body = ExternalBeneficiaryRequest(alias: alias, color: color, session: SessionR(id: sessionId, number: cardNumber))
        
        let route = APIEndpoint(.post, apiConfig.customersURL, "/api/external-card/beneficiaries", body: body, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func getCustomerInfoFromQR<T: Codable>(_ qrString: String) -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/customers-info/\(qrString)",  headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func addTopupExternalCardBeneficiaries<T: Codable>(alias: String, color: String, sessionId: String, cardNumber: String) -> Observable<T> {
        
        let body = ExternalBeneficiaryRequest(alias: alias, color: color, session: SessionR(id: sessionId, number: cardNumber))
        
        let route = APIEndpoint(.post, apiConfig.customersURL, "/api/mastercard/beneficiaries", body: body, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func deletePaymentGatewayBeneficiary<T: Codable>(id: String) -> Observable<T> {
        let pathVariables = [id]
        let route = APIEndpoint<String>(.delete, apiConfig.customersURL, "/api/mastercard/beneficiaries/", pathVariables: pathVariables, body: nil, headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func getBankDetail<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/bank-detail",  headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func fetchBeneficiaryAccountTitle<T: Codable>(accountNo: String, consumerId: String) -> Observable<T> {
        let params = ["accountNo": accountNo, "consumerId": consumerId]
        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/fetch-beneficiary-account-title", query: params, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func addBankBenefiiary<T: Codable>(input body: AddBankBeneficiaryRequest) -> Observable<T> {
        let route = APIEndpoint(.post, apiConfig.customersURL, "/api/beneficiaries/bank-transfer", body: body, headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func getDashboardWidgets<T: Codable> () -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.customersURL, "/api/getWidgets",  headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func updateDashboardWidgets<T:Codable>(widgets: [DashboardWidgetsRequest], uuid: String, customer_uuid: String)-> Observable<T>  {
        let pathVariables = [customer_uuid]
//        let route = APIEndpoint(.put, apiConfig.customersURL, "/api/updateWidgets/uuid/\(customer_uuid)" ,body: widgets, headers: authorizationProvider.authorizationHeaders)
        let route = APIEndpoint(.put, apiConfig.customersURL, "/api/updateWidgets/uuid/" , pathVariables: pathVariables, body: widgets, headers: authorizationProvider.authorizationHeaders)
        return self.request(apiClient: self.apiClient, route: route)
    }
    
}

// MARK: Helpers

fileprivate extension CustomersService {
    func fileInfo(from fileName: String = "files", format: String) -> (String, String, String) {
        switch format {
        case "image/jpg":
            return (fileName, "image.jpg", format)
        case "image/png":
            return (fileName, "image.png", format)
        case "image/tiff":
            return (fileName, "file.tiff", format)
        case "video/mp4":
            return (fileName, "video.mp4", format)
        case "application/pdf":
            return (fileName, "file.pdf", format)
        default:
            let formatData = format.split(separator: "/").map({ String($0) })
            let file = formatData.first ?? ""
            let fileName = formatData.last == nil ? "": ("file." + (formatData.last ?? "") )
            return (file, fileName, format)
        }
    }
}
