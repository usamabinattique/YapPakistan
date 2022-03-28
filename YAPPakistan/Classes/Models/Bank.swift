//
//  Bank.swift
//  YAP
//
//  Created by Muhammad Hassan on 28/02/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public struct Bank: Codable {
   public let id: Int
   public let name: String
   public let bankCode: String
   public let swiftCode: String
   public let address: String
}

//"bankLogoUrl": "https://s3-eu-west-1.amazonaws.com//qa-yap-pk-documents-public/banks/Al Baraka.png",
//            "bankName": "Bank Islami",
//            "accountNoMinLength": 13,
//            "accountNoMaxLength": 13,
//            "ibanMinLength": 24,
//            "ibanMaxLength": 24,
//            "consumerId": "639530",
//            "formatMessage": "Please enter the complete 13 digit bank-islami Account Number OR Please enter the complete 24 alpha-numeric IBAN provided by the beneficiary"
//pk-qa.yap.co/customers/api/bank-detail

public struct BankDetail: Codable {
   public let bankLogoUrl: String?
   public let bankName: String
    public let accountNoMinLength: Int
    public let accountNoMaxLength: Int
    public let ibanMinLength: Int
    public let ibanMaxLength: Int
   public let consumerId: String
   public let formatMessage: String
    
    func thumbnail(forIndex index: Int) -> UIImage? {
        let colorIndex = index % 4
    
        return bankName.initialsImage(color: colorIndex == 0 ? .magenta : colorIndex == 1 ? .green.withAlphaComponent(0.50) : colorIndex == 2 ? .blue.withAlphaComponent(0.50) : .orange.withAlphaComponent(0.50), font: UIFont.systemFont(ofSize: 11.0))
        //return name.initialsImage(color: colorIndex == 0 ? .secondaryMagenta : colorIndex == 1 ? .secondaryGreen : colorIndex == 2 ? .secondaryBlue : .secondaryOrange)
    }
}
