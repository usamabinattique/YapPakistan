//
//  ContactEntitiyHandler.swift
//  AppDatabase
//
//  Created by Janbaz Ali on 20/05/2021.
//  Copyright © 2021 YAP. All rights reserved.
//
/*
import Foundation
// import CoreData
import UIKit

typealias AccountForDb = (accountType: String, accountNumber: String?, uuid: String, beneficiaryCreationDate: String?)

protocol ContactEntityHandlerDelegate: NSObjectProtocol {
    
    func entityDidChangeContent(_ entityHandler: ContactEntitiyHandler)
    
}

class ContactEntitiyHandler: NSObject {
    
    // MARK: Properties
    
    static var fetchRequest: NSFetchRequest<CDContact> { return CDContact.fetchRequest() }
    private var contactsFRC: NSFetchedResultsController<CDContact>!
    weak var delegate: ContactEntityHandlerDelegate?
    private let coreDataStack = CoreDataStack.shared
    private let  accountEntityHandler = AccountEntityHandler()
    
    // MARK:- Add Task
    
    func add(yapContacts: [YapContactForDb]) {
        
        let context = coreDataStack.workingContext
        
        for yapContact in yapContacts {
            
            let contact = create(onContext: context)
            
            contact.name = yapContact.name
            contact.email = yapContact.email
            contact.phoneNumber = yapContact.phoneNumber
            contact.countryCode = yapContact.countryCode
            contact.isYapUser = yapContact.isYapUser
            contact.photoUrl = yapContact.photoUrl
            contact.index = Int16(yapContact.index ?? 0)
            
            for item in yapContact.yapAccountDetails {
                let account = accountEntityHandler.create(context: context) as! CDAccount
                account.update(with: item, and: contact)
            }
        }
        
        coreDataStack.saveWorkingContext(context: context)
    
    }
    
    //MARK: - Update Record
    
    func update(with number: String, description: String, date: Date) {
        
        let context = coreDataStack.workingContext
       // let record = fetchContact(with: number, onContext: context)
        
        coreDataStack.saveWorkingContext(context: context)
    }
    
    //MARK:- Delete
    
    func delete( contacts : [CDContact]) {
        let context = coreDataStack.workingContext
        contacts.forEach {
            if let record = fetchContact(with:  $0.phoneNumber ?? "", onContext: context)  {
                context.delete(record)
            }
        }
    
        coreDataStack.saveWorkingContext(context: context)
    }
    
    //MARK:- Queries
    
   private func fetchContact(with number : String, onContext context: NSManagedObjectContext? = nil) -> CDContact? {
        
        let fetchRequest = ContactEntitiyHandler.fetchRequest
        fetchRequest.predicate = NSPredicate(format: "phoneNumber = %@", number)
        do {
            let results = try (context ?? coreDataStack.managedObjectContext).fetch(fetchRequest)
            return results.first
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func fetchContacts() -> [CDContact]? {
        let context = coreDataStack.managedObjectContext
         let fetchRequest = ContactEntitiyHandler.fetchRequest
         do {
            let results = try (context).fetch(fetchRequest)
             return results
         } catch {
             print(error)
         }
         
         return nil
     }
    
}

internal extension ContactEntitiyHandler {
    func create(onContext context: NSManagedObjectContext) -> CDContact {
        return CDContact(entity: CDContact.entity(), insertInto: context)
    }
}

// MARK:- FRC
extension ContactEntitiyHandler {
    func fetchRequest() throws {
        
        let request = ContactEntitiyHandler.fetchRequest
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        contactsFRC = NSFetchedResultsController<CDContact>(fetchRequest: request, managedObjectContext: coreDataStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        contactsFRC.delegate = self
        
        do {
            try contactsFRC.performFetch()
            
        } catch {
            throw error
            
        }
    }
    
    func contacts(for section: Int) -> [CDContact] {
        let sections = contactsFRC.sections?.count ?? 0
        guard sections > 0 && section < sections else { return [] }
        return (contactsFRC.sections?[section].objects as? [CDContact]) ?? []
    }
    
}

// MARK: Fetched results controller delegate

extension ContactEntitiyHandler: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.entityDidChangeContent(self)
    }
}

























//    func contact(for indexPath: IndexPath) -> Contact? {
//        guard indexPath.section < contactsFRC.sections?.count ?? 0, indexPath.row < contacts(for: indexPath.section).count else { return nil }
//        return contactsFRC.object(at: indexPath)
//    }
//
//    func contacts(for section: Int) -> [Contact] {
//        let sections = contactsFRC.sections?.count ?? 0
//        guard sections > 0 && section < sections else { return [] }
//        return (contactsFRC.sections?[section].objects as? [Contact]) ?? []
//    }
//
//    func numberOfContacts(in section: Int) -> Int {
//        return contacts(for: section).count
//    }
*/
