//
//  CDTransactionEntityHandler.swift
//  Database
//
//  Created by Zain on 16/11/2019.
//  Copyright © 2019 YAP. All rights reserved.
//
// swiftlint:disable line_length
// swiftlint:disable identifier_name

/*
import Foundation
import CoreData
import YAPComponents

enum TransactionCardType: String {
    case debit = "debit"
    case other = "other"
}

protocol CDTransactionEntityHandlerDelegate: NSObjectProtocol {
    func entityDidChangeContent(_ entityHandler: CDTransactionEntityHandler)
}

class CDTransactionEntityHandler: NSObject {
    
    // MARK: Initialization
    
    init(delegate: CDTransactionEntityHandlerDelegate? = nil) {
        super.init()
        self.delegate = delegate
    }
    
    // MARK: Properties
    
    static var fetchRequest: NSFetchRequest<CDTransaction> { return CDTransaction.fetchRequest() }
    
    private var transactionFRC: NSFetchedResultsController<CDTransaction>!
    
    weak var delegate: CDTransactionEntityHandlerDelegate?
    
    // MARK: Entity methods
    
    internal func create(onContext context: NSManagedObjectContext) -> CDTransaction {
        return CDTransaction(entity: CDTransaction.entity(), insertInto: context)
    }
    
    @discardableResult
    func update(with models: [TransactionResponse], transcationCardType: TransactionCardType, cardSerialNumber: String?) -> Int {
        
        guard models.count > 0 else { return 0 }
        
        let context = CoreDataStack.shared.workingContext
        
        var updateCount = models.filter { $0.updatedDate == nil }.count
        
        updateCount += models
            .filter { $0.updatedDate != nil }
            .map { [unowned self] model -> Bool in
                let transaction = self.transaction(withId: model.id, transactionCardType: transcationCardType, onContext: context) ?? self.create(onContext: context)
                return transaction.update(with: model, transactionCardType: transcationCardType, onContext: context, cardSerialNumber: cardSerialNumber) }
            .filter { $0 }
            .count
        
        CoreDataStack.shared.saveWorkingContext(context: context)
        
        return updateCount
    }
    
    static func clear() {
        let context = CoreDataStack.shared.workingContext
        let fetchRequest = CDTransactionEntityHandler.fetchRequest
        let objects = (try? context.fetch(fetchRequest)) ?? []
        
        objects.forEach { context.delete($0) }
        
        CoreDataStack.shared.saveWorkingContext(context: context)
    }
}

// MARK: Queries

extension CDTransactionEntityHandler {
    func transaction(withId tId: Int, transactionCardType: TransactionCardType, onContext context: NSManagedObjectContext? = nil) -> CDTransaction? {
        let fetchRequest = CDTransactionEntityHandler.fetchRequest
        fetchRequest.predicate = NSPredicate(format: "id = %d && transactionCardType = %@", tId, transactionCardType.rawValue)
        do {
            let results = try (context ?? CoreDataStack.shared.managedObjectContext).fetch(fetchRequest)
            return results.first
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func transaction(withTransactionId transactionId: String, onContext context: NSManagedObjectContext? = nil) -> CDTransaction? {
        let fetchRequest = CDTransactionEntityHandler.fetchRequest
        fetchRequest.predicate = NSPredicate(format: "transactionId = %@", transactionId)
        do {
            let results = try (context ?? CoreDataStack.shared.managedObjectContext).fetch(fetchRequest)
            return results.first
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func totalTransactionCount(onContext context: NSManagedObjectContext? = nil) -> Int {
        let fetchRequest = CDTransactionEntityHandler.fetchRequest
        do {
            let results = try (context ?? CoreDataStack.shared.managedObjectContext).fetch(fetchRequest)
            return results.count
        } catch {
            print(error)
        }
        
        return 0
    }
}

// MARK: Fetched results controllers

extension CDTransactionEntityHandler {
    func updateFRCRequest(sortDescriptors: [NSSortDescriptor]? = nil, predicate: NSPredicate? = nil, sectionNameKeyPath: String? = nil) throws {
        
        let request = CDTransactionEntityHandler.fetchRequest
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
        
        transactionFRC = NSFetchedResultsController<CDTransaction>(fetchRequest: request, managedObjectContext: CoreDataStack.shared.managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        transactionFRC.delegate = self
        do { try transactionFRC.performFetch() } catch { throw error }
    }
    
    func transaction(for indexPath: IndexPath) -> CDTransaction? {
        guard indexPath.section < transactionFRC.sections?.count ?? 0, indexPath.row < transactions(for: indexPath.section).count else { return nil }
        return transactionFRC.object(at: indexPath)
    }
    
    func transactions(for section: Int) -> [CDTransaction] {
        let sections = transactionFRC.sections?.count ?? 0
        guard sections > 0 && section < sections else { return [] }
        return (transactionFRC.sections?[section].objects as? [CDTransaction]) ?? []
    }
    
    func numberOfSection() -> Int {
        return transactionFRC.sections?.count ?? 0
    }
    
    func numberOfTransaction(in section: Int) -> Int {
        return transactions(for: section).count
    }
    
    func allSections() -> [[CDTransaction]] {
        (0..<numberOfSection()).map { [unowned self] in self.transactions(for: $0) }
    }
}

// MARK: Fetched results controller delegate

extension CDTransactionEntityHandler: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.entityDidChangeContent(self)
    }
}
*/
