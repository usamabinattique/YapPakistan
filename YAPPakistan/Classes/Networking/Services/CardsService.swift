//
//  CardsService.swift
//  YAPPakistan
//
//  Created by Sarmad on 04/11/2021.
//

import Foundation
import RxSwift

protocol CardsServiceType {
    func saveUserAddress<T: Codable>(address: String,
                                     city: String,
                                     country: String,
                                     postCode: String,
                                     latitude: String,
                                     longitude: String ) -> Observable<T>
    func getCards<T: Codable>() -> Observable<T>
    func getCardDetail<T: Codable>(cardSerialNumber: String) -> Observable<T>
    func setPin<T: Codable>(cardSerialNumber: String, pin: String) -> Observable<T>
    func configFreezeUnfreezeCard<T: Codable>(cardSerialNumber: String) -> Observable<T>
    func configAllowAtm<T: Codable>(cardSerialNumber: String) -> Observable<T>
    func configRetailPayment<T: Codable>(cardSerialNumber: String) -> Observable<T>
    func verifyCardPin<T: Codable>(cardSerialNumber: String, pin: String) -> Observable<T>
    func changeCardPin<T: Codable>(oldPin: String,
                                   newPin: String,
                                   confirmPin: String,
                                   cardSerialNumber: String) -> Observable<T>
    func setCardName<T: Codable>(cardName: String,
                                 cardSerialNumber: String) -> Observable<T>
    func forgotCardPin<T: Codable>(newPin: String,
                                   token: String,
                                   cardSerialNumber: String) -> Observable<T>
    func closeCard<T: Codable>(_ cardserialNumber: String, reason: String) -> Observable<T>
    func getPhysicalCardAddress<T: Codable>() -> Observable<T>
    func reorderDebitCard<T: Codable>(cardSerialNumber: String,
                                      address: String,
                                      city: String,
                                      country: String,
                                      postCode: String,
                                      latitude: String,
                                      longitude: String) -> Observable<T>
    func getCardsScheme<T: Codable>() -> Observable<T>
}

public class CardsService: BaseService, CardsServiceType {

    public func saveUserAddress<T: Codable>(address: String,
                                            city: String,
                                            country: String,
                                            postCode: String,
                                            latitude: String,
                                            longitude: String ) -> Observable<T> {

        let body: [String: String] = [
            "address1": address,
            "address2": "0",
            "city": city,
            "country": country,
            "postCode": postCode,
            "latitude": latitude,
            "longitude": longitude
        ]

        let route = APIEndpoint(.post,
                                apiConfig.cardsURL, "/api/save-address-and-order-card",
                                body: body,
                                headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func getCards<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.cardsURL, "/api/cards", headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func getCardDetail<T: Codable>(cardSerialNumber: String) -> Observable<T> {
        // let body: [String: String] = [:]
        let query: [String: String] = ["cardSerialNumber": cardSerialNumber]

//        let route = APIEndpoint<String>(.get, apiConfig.cardsURL, "/api/cards/details?cardSerialNumber=\(cardSerialNumber)", headers: authorizationProvider.authorizationHeaders)

        let route = APIEndpoint<String>(.get, apiConfig.cardsURL, "/api/cards/details", query: query, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func setPin<T: Codable>(cardSerialNumber: String, pin: String) -> Observable<T> {
        let body = ["newPin": pin]
        let pathVariables = [cardSerialNumber]

        let route = APIEndpoint(.post, apiConfig.cardsURL, "/api/cards/create-pin", pathVariables: pathVariables, query: nil, body: body, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func configFreezeUnfreezeCard<T: Codable>(cardSerialNumber: String) -> Observable<T> {
        let body = ["cardSerialNumber": cardSerialNumber]

        let route = APIEndpoint(.put, apiConfig.cardsURL, "/api/cards/block-unblock", pathVariables: nil, query: nil, body: body, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func configAllowAtm<T>(cardSerialNumber: String) -> Observable<T> where T : Decodable, T : Encodable {
        let body = ["cardSerialNumber": cardSerialNumber]

        let route = APIEndpoint(.put, apiConfig.cardsURL, "/api/cards/atm-allow", pathVariables: nil, query: nil, body: body, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func configRetailPayment<T>(cardSerialNumber: String) -> Observable<T> where T : Decodable, T : Encodable {
        let body = ["cardSerialNumber": cardSerialNumber]

        let route = APIEndpoint(.put, apiConfig.cardsURL, "/api/cards/retail-payment", pathVariables: nil, query: nil, body: body, headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func verifyCardPin<T: Codable>(cardSerialNumber: String, pin: String) -> Observable<T> {
        let body = ["pin": pin]

        let route = APIEndpoint(.post,
                                apiConfig.cardsURL,
                                "api/cards/verify-pin/\(cardSerialNumber)",
                                pathVariables: nil,
                                query: nil,
                                body: body,
                                headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func changeCardPin<T: Codable>(oldPin: String,
                                          newPin: String,
                                          confirmPin: String,
                                          cardSerialNumber: String) -> Observable<T> {

        let body = [
            "oldPin": oldPin,
            "newPin": newPin,
            "confirmPin": confirmPin,
            "cardSerialNumber": cardSerialNumber
        ]

        let route = APIEndpoint(.post,
                                apiConfig.cardsURL,
                                "/api/cards/change-pin",
                                pathVariables: nil,
                                query: nil,
                                body: body,
                                headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func setCardName<T: Codable>(cardName: String,
                                        cardSerialNumber: String) -> Observable<T> {

        let query: [String: String] = [
            "cardSerialNumber": cardSerialNumber,
            "cardName": cardName
        ]

        let route = APIEndpoint<String>(.put,
                                        apiConfig.cardsURL,
                                        "/api/cards/card-name",
                                        query: query,
                                        headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func forgotCardPin<T: Codable>(newPin: String,
                                          token: String,
                                          cardSerialNumber: String) -> Observable<T> {
        let body = [
            "newPin": newPin,
            "token": token
        ]
        let route = APIEndpoint(.post,
                                apiConfig.cardsURL,
                                "/api/cards/forgot-pin/\(cardSerialNumber)",
                                pathVariables: nil,
                                query: nil,
                                body: body,
                                headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func closeCard<T: Codable>(_ cardserialNumber: String, reason: String) -> Observable<T> {
        let body = ClosePaymentCardRequest(cardSerialNumber: cardserialNumber, hotListReason: reason)
        let route = APIEndpoint(.post,
                                apiConfig.cardsURL,
                                "/api/card-hot-list",
                                pathVariables: nil,
                                query: nil,
                                body: body,
                                headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }

    public func getPhysicalCardAddress<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(
            .get,
            apiConfig.cardsURL,
            "/api/user-address",
            headers: authorizationProvider.authorizationHeaders
        )
        return self.request(apiClient: self.apiClient, route: route)
    }

    public func reorderDebitCard<T: Codable>(cardSerialNumber: String,
                                             address: String,
                                             city: String,
                                             country: String,
                                             postCode: String,
                                             latitude: String,
                                             longitude: String ) -> Observable<T> {
        let body: [String: String] = [
            "cardSerialNumber": cardSerialNumber,
            "address1": address,
            "address2": "0",
            "city": city,
            "country": country,
            "postCode": postCode,
            "latitude": latitude,
            "longitude": longitude
        ]
        let route = APIEndpoint(
            .post,
            apiConfig.cardsURL, "/api/cards/debit/reorder",
            body: body,
            headers: authorizationProvider.authorizationHeaders
        )
        return self.request(apiClient: self.apiClient, route: route)
    }
    
    public func getCardsScheme<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, apiConfig.cardsURL, "/api/schemes/active", headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }
}
