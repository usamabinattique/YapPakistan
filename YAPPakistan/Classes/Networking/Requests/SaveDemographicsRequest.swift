//
//  SaveDemographicsRequest.swift
//  YAPPakistan
//
//  Created by Tayyab on 27/08/2021.
//

import Foundation

/*
{
  "action": "SIGNUP",
  "deviceId": "EC358860-D924-4317-95C4-6F433E08FECB",
  "deviceName": "Dev’s iPhone",
  "deviceModel": "iPhone",
  "osType": "iOS",
  "osVersion": "13.5.1",
  "token": "{{otp_data}}"
}
*/
struct SaveDemographicsRequest: Codable {
    var action: String
    var deviceId: String
    var deviceName: String
    var deviceModel: String
    var osType: String
    var osVersion: String
    var token: String?
}
