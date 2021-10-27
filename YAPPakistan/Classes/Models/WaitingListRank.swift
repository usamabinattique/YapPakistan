//
//  WaitingListRank.swift
//  YAPPakistan
//
//  Created by Tayyab on 07/09/2021.
//

import Foundation

/*
{
    "jump": "200",
    "waitingNewRank": 1840,
    "waitingBehind": 20,
    "completedKyc": false,
    "viewable": true,
    "gainPoints": "200",
    "inviteeDetails": [
        {
            "inviteeCustomerId": "10000029",
            "inviteeCustomerName": "Post Man One"
        }
    ],
    "totalGainedPoints": 200,
    "waiting": false
}
*/
struct WaitingListRank: Codable {
    var jump: String? = "0"
    var waitingNewRank: Int = 0
    var waitingBehind: Int = 0
    var completedKyc: Bool = false
    var viewable: Bool = true
    var gainPoints: String? = "0"
    var inviteeDetails: [Invitee]? = []
    var totalGainedPoints: Int? = 0
    var waiting: Bool? = false
}

struct Invitee: Codable {
    var inviteeCustomerId: String
    var inviteeCustomerName: String
}
