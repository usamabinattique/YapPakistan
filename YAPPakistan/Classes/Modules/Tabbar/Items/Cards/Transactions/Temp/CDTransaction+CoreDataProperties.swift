//
//  CDTransaction+CoreDataProperties.swift
//  AppDatabase
//
//  Created by Wajahat Hassan on 08/07/2021.
//  Copyright © 2021 YAP. All rights reserved.
//
//

import Foundation
// import CoreData


struct CDTransaction {

//    @nonobjc class func fetchRequest() -> NSFetchRequest<CDTransaction> {
//        return NSFetchRequest<CDTransaction>(entityName: "CDTransaction")
//    }

   var amount: Double
   var beneficiaryId: String?
   var calculatedAmount: Double
   var cancelReason: String?
   var cardHolderBillingAmount: Double
   var cardHolderBillingCurrency: String?
   var cardHolderBillingTotalAmount: Double
   var cardSerialNumber: String?
   var cardType: String?
   var category: String?
   var closingBalance: Double
   var createdDate: Date?
   var currency: String?
   var customerId: String?
   var detailTransferType: String?
   var fee: Double
   var finalizedStatus: String?
   var finalizedTitle: String?
   var formattedTime: String?
   var fxRate: String?
   var iconName: String?
   var id: Int64
   var initiator: String?
   var isTransactionInProgress: Bool
   var itemIndex: Int64
   var location: String?
   var maskedCardNumber: String?
   var merchantCategory: String?
   var merchantLogo: String?
   var merchantName: String?
   var otherBankBIC: String?
   var otherBankBranch: String?
   var otherBankCountry: String?
   var otherBankCurrency: String?
   var otherBankName: String?
   var paymentMode: String?
   var productCode: String?
   var productName: String?
   var receiverName: String?
   var receiverTransactionNote: String?
   var receiverTransactionNoteDate: Date?
   var receiverUrl: String?
   var remarks: String?
   var senderCustomerId: String?
   var senderName: String?
   var senderUrl: String?
   var settlementAmount: Double
   var status: String?
   var statusIconName: String?
   var tapixCategory: String?
   var tapixCategoryIconURL: String?
   var title: String?
   var totalAmount: Double
   var transactionCardType: String?
   var transactionDay: Date?
   var transactionId: String?
   var transactionNote: String?
   var transactionNoteDate: Date?
   var transferCategory: String?
   var transferType: String?
   var type: String?
   var updatedDate: Date?
   var vat: Double
   var virtualCardColors: String?
   var latitude: Double
   var longitude: Double

}
