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
    var jump: String?
    var waitingNewRank: Int
    var waitingBehind: Int
    var completedKyc: Bool
    var viewable: Bool
    var gainPoints: String?
    var inviteeDetails: [Invitee]?
    var totalGainedPoints: Int?
    var waiting: Bool?
}

struct Invitee: Codable {
    var inviteeCustomerId: String
    var inviteeCustomerName: String
}
