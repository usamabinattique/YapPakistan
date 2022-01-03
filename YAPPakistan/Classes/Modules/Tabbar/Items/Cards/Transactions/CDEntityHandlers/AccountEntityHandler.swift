//
//  AccountEntityHandler.swift
//  AppDatabase
//
//  Created by Janbaz Ali on 21/05/2021.
//  Copyright © 2021 YAP. All rights reserved.
//
/*
import Foundation
import CoreData

typealias YapContactForDb = (name: String, phoneNumber: String, countryCode: String, email: String?, isYapUser: Bool, photoUrl: String?, index: Int?, yapAccountDetails: [AccountForDb])

class AccountEntityHandler {
    
    func fetchRequest() -> NSFetchRequest<NSFetchRequestResult>? {
        return CDAccount.fetchRequest()
    }
    
    func create<T>(context: NSManagedObjectContext) -> T where T : NSManagedObject {
        let object = CDAccount(entity: CDAccount.entity(), insertInto: context)
        return object as! T
    }

}
*/
