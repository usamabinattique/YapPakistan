//
//  AccountLimits.swift
//  YAPPakistan
//
//  Created by Umair  on 10/05/2022.
//

import Foundation

struct AccountLimits: Codable {
    var title: String
    var logo: String
    var transactionLimits: [TransactionLimitsDetail]
    
}

struct TransactionLimitsDetail: Codable {
    var title: String
    var allocatedLimit: Int
    var consumedLimit: Int
}

/*
{
    "errors": null,
    "data": [
        {
            "title": "Credit Transactions",
            "logo": "https://asdasdasdasdasd",
            "transactionLimits": [
                {
                    "title": "Daily Credit",
                    "allocatedLimit": 50000,
                    "consumedLimit": 1000
                },
                {
                    "title": "Aggregate Monthly Loadable Limit",
                    "allocatedLimit": 50000,
                    "consumedLimit": 0
                },
                {
                    "title": "Max Balance",
                    "allocatedLimit": 250000,
                    "consumedLimit": 5000
                }
            ]
        },
        {
            "title": "Loading through Debit/Credit Cards",
            "logo": "https://asdasdasdasdasd",
            "transactionLimits": [
                {
                    "title": "Per Trx(upto) - Credit",
                    "allocatedLimit": 5000,
                    "consumedLimit": 100
                },
                {
                    "title": "Daily Credit",
                    "allocatedLimit": 20000,
                    "consumedLimit": 1000
                },
                {
                    "title": "Monthly Credit",
                    "allocatedLimit": 50000,
                    "consumedLimit": 10000
                }
            ]
        },
        {
            "title": "Debit Transactions",
            "logo": "https://asdasdasdasdasd",
            "transactionLimits": [
                {
                    "title": "Daily Debit",
                    "allocatedLimit": 50000,
                    "consumedLimit": 1000
                }
            ]
        },
        {
            "title": "Cash Withdrawal via ATM",
            "logo": "https://asdasdasdasdasd",
            "transactionLimits": [
                {
                    "title": "Daily Debit",
                    "allocatedLimit": 50000,
                    "consumedLimit": 1000
                }
            ]
        }
    ]
}
*/
