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
                                apiConfig.cardsURL, "/api/save-user-address",
                                body: body,
                                headers: authorizationProvider.authorizationHeaders)

        return self.request(apiClient: self.apiClient, route: route)
    }
}
