//
//  CDTransactionPagesEntityHandler.swift
//  AppDatabase
//
//  Created by Zain on 20/03/2020.
//  Copyright © 2020 YAP. All rights reserved.
//
/*
import Foundation
import CoreData
import YAPComponents

typealias TransactionsSyncStatus = (syncedPages: Int, syncCompleted: Bool)

class CDTransactionPagesEntityHandler {
    
    // MARK: Properties
    
    static var fetchRequest: NSFetchRequest<CDTransactionPages> { return CDTransactionPages.fetchRequest() }
    
    // MARK: Initialization
    
    init () { }
    
    // MARK: Public functions
    
    func updatePages(for transactionCardType: TransactionCardType, cardSerialNumber: String?, pagesSynced: Int, isLast: Bool) {
        
        let context = CoreDataStack.shared.workingContext
        
        let transactionPages = pages(withTransactionCardType: transactionCardType, cardSerilaNumber: cardSerialNumber, onContext: context) ?? create(onContext: context)
        
        transactionPages.update(transactionCardType: transactionCardType, cardSerialNumber: cardSerialNumber, syncedPages: pagesSynced, isLast: isLast)
        
        CoreDataStack.shared.saveWorkingContext(context: context)
    }
    
    func syncStatus(for transactionCardType: TransactionCardType, cardSerialNumber: String?) -> TransactionsSyncStatus {
        
        let context = CoreDataStack.shared.managedObjectContext
        
        guard let transactionPages = pages(withTransactionCardType: transactionCardType, cardSerilaNumber: cardSerialNumber, onContext: context) else  {
            return (syncedPages: 0, syncCompleted: false)
        }
        
        return (syncedPages: Int(transactionPages.syncedPages), syncCompleted: transactionPages.syncCompleted)
    }
    
    static func clear() {
        let context = CoreDataStack.shared.workingContext
        let fetchRequest = CDTransactionPagesEntityHandler.fetchRequest
        let objects = (try? context.fetch(fetchRequest)) ?? []
        
        objects.forEach { context.delete($0) }
        
        CoreDataStack.shared.saveWorkingContext(context: context)
    }
}

// MARK: Queries

private extension CDTransactionPagesEntityHandler {
    func create(onContext context: NSManagedObjectContext) -> CDTransactionPages {
        return CDTransactionPages(entity: CDTransactionPages.entity(), insertInto: context)
    }
    
    func pages(withTransactionCardType cardType: TransactionCardType, cardSerilaNumber: String?, onContext context: NSManagedObjectContext? = nil) -> CDTransactionPages? {
        
        let fetchRequest = CDTransactionPagesEntityHandler.fetchRequest
        if let serial = cardSerilaNumber {
            fetchRequest.predicate = NSPredicate(format: "transactionCardType = %@ && cardSerialNumber = %@", cardType.rawValue, serial)
        } else {
            fetchRequest.predicate = NSPredicate(format: "transactionCardType = %@", cardType.rawValue)
        }
        
        do {
            let results = try (context ?? CoreDataStack.shared.managedObjectContext).fetch(fetchRequest)
            return results.first
        } catch {
            print(error)
        }
        
        return nil
    }
}
*/
