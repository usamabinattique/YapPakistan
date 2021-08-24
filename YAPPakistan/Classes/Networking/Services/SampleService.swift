//
//  SampleService.swift
//  YAPPakistan
//
//  Created by Tayyab on 24/08/2021.
//

import Foundation
import RxSwift

class SampleService: BaseService {
    private let apiClient: APIClient
    private let config: APIConfiguration

    init(apiClient: APIClient = WebClient(), config: APIConfiguration) {
        self.apiClient = apiClient
        self.config = config
    }

    func getRequest<T: Codable>() -> Observable<T> {
        let route = APIEndpoint<String>(.get, config.baseURL, "/get",
                                        query: ["lat": "30", "long": "30"])

        return self.request(apiClient: self.apiClient, route: route)
    }

    func postRequest<T: Codable>(param1: String, param2: String) -> Observable<T> {
        let body = PostRequest(param1: param1, param2: param2)
        let route = APIEndpoint(.post, config.baseURL, "/post", body: body)

        return self.request(apiClient: self.apiClient, route: route)
    }
}
