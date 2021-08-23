//
//  TransactionsClient.swift
//  APIClient
//
//  Created by Wajahat Hassan on 27/08/2019.
//  Copyright © 2019 Muhammad Hassan. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

public struct TransactionsClient: APIClient {
    
    public init() { }
    public func upload(documents: [DocumentDataConvertible], route: YAPURLRequestConvertible, progressObserver: AnyObserver<Progress>?, otherFormValues formValues: [String: String]) -> Observable<APIResponseConvertible> {
        return Observable<APIResponseConvertible>.never()
    }
    
    public func request(route: YAPURLRequestConvertible) -> Observable<APIResponseConvertible> {
        
        let response =
        """
            {
              "errors": null,
              "data": {
                "content": [
                  {
                    "id": 144,
                    "txnDate": "2019-08-05T07:31:35",
                    "txnType": "CREDIT",
                    "txnAmount": 850.00,
                    "txnCurrency": "AED",
                    "txnCategory": "TRANSACTION",
                    "paymentMode": "DEBIT",
                    "closingBalance": 15657.99,
                    "title": null,
                    "merchant": null
                  },
                  {
                    "id": 143,
                    "txnDate": "2019-08-05T07:19:01",
                    "txnType": "DEBIT",
                    "txnAmount": 890.00,
                    "txnCurrency": "AED",
                    "txnCategory": "TRANSACTION",
                    "paymentMode": "DEBIT",
                    "closingBalance": 1719.99,
                    "title": null,
                    "merchant": null
                  },
                  {
                    "id": 140,
                    "txnDate": "2019-08-06T06:00",
                    "txnType": "CREDIT",
                    "txnAmount": 831.00,
                    "txnCurrency": "AED",
                    "txnCategory": "TRANSACTION",
                    "paymentMode": "DEBIT",
                    "closingBalance": 831.00,
                    "title": null,
                    "merchant": null
                  },
                  {
                    "id": 138,
                    "txnDate": "2019-08-06T05:50:43",
                    "txnType": "DEBIT",
                    "txnAmount": 820.00,
                    "txnCurrency": "AED",
                    "txnCategory": "TRANSACTION",
                    "paymentMode": "DEBIT",
                    "closingBalance": 12333.99,
                    "title": null,
                    "merchant": null
                  },
                  {
                    "id": 137,
                    "txnDate": "2019-08-07T05:47:28",
                    "txnType": "CREDIT",
                    "txnAmount": 85.00,
                    "txnCurrency": "AED",
                    "txnCategory": "TRANSACTION",
                    "paymentMode": "DEBIT",
                    "closingBalance": 11513.99,
                    "title": null,
                    "merchant": null
                  }
                ],
                "pageable": {
                  "sort": {
                    "sorted": false,
                    "unsorted": true
                  },
                  "pageSize": 5,
                  "pageNumber": 1,
                  "offset": 5,
                  "unpaged": false,
                  "paged": true
                },
                "last": false,
                "totalElements": 56,
                "totalPages": 12,
                "sort": {
                  "sorted": false,
                  "unsorted": true
                },
                "numberOfElements": 5,
                "first": false,
                "size": 5,
                "number": 1
              }
            }
            """
        
        return Observable.of(APIResponse(code: 200, data: response.data(using: .utf8)!))
    }
}
/*,
 {
 "date": "October 06, 2018",
 "totalAmount": "545454",
 "transaction": [
 {
 "vendor": "Amazon",
 "type": "Debit",
 "imageUrl": "https:\\dsfsdfsdfsdfsdfsdfsf.png",
 "time": "09:56",
 "category": "Payrole",
 "amount": "95000",
 "currency": "AED",
 "amountPercentage": "90"
 },
 {
 "vendor": "Amazon",
 "type": "Debit",
 "imageUrl": "https:\\dsfsdfsdfsdfsdfsdfsf.png",
 "time": "09:56",
 "category": "Payrole",
 "amount": "95000",
 "currency": "AED"
 },
 {
 "vendor": "Amazon",
 "type": "Debit",
 "imageUrl": "https:\\dsfsdfsdfsdfsdfsdfsf.png",
 "time": "09:56",
 "category": "Payrole",
 "amount": "95000",
 "currency": "AED",
 "amountPercentage": "90"
 }
 ]
 },
 {
 "date": "October 06, 2018",
 "totalAmount": "545454",
 "transaction": [
 {
 "vendor": "Amazon",
 "type": "Debit",
 "imageUrl": "https:\\dsfsdfsdfsdfsdfsdfsf.png",
 "time": "09:56",
 "category": "Payrole",
 "amount": "95000",
 "currency": "AED",
 "amountPercentage": "90"
 },
 {
 "vendor": "Amazon",
 "type": "Debit",
 "imageUrl": "https:\\dsfsdfsdfsdfsdfsdfsf.png",
 "time": "09:56",
 "category": "Payrole",
 "amount": "95000",
 "currency": "AED",
 "amountPercentage": "90"
 }
 ]
 }*/
