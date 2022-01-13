//
//  ContactsManager.swift
//  YAP
//
//  Created by Zain on 28/11/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import Contacts
import PhoneNumberKit
import RxSwift
import YAPComponents
import UIKit

public protocol ContactsRepositoryType {
    func classifyContacts(_ contacts: [Contact])-> Observable<Event<[YAPContact]>>
}

public class ContactsManager: NSObject {
    
    private let contactStore = CNContactStore()
    private let repository: ContactsRepositoryType
    private var disposeBag = DisposeBag()
    private var results = [YAPContact]()
    public var contactsNeedToBeSynced = true
    
    private var progress: CGFloat = 0.0 {
        didSet {
            progressSubject.onNext(progress)
        }
    }
    
    private var isSyncingSubject = BehaviorSubject<Bool>(value: false)
    private var errorSubject = PublishSubject<String>()
    private var resultSubject = BehaviorSubject<[YAPContact]>(value: [])
    private var progressSubject = BehaviorSubject<CGFloat>(value: 0)
    
    public var result: Observable<[YAPContact]> { resultSubject.asObservable() }
    public var isSyncing: Observable<Bool> { isSyncingSubject.asObservable() }
    public var error: Observable<String> { errorSubject.asObservable() }
    public var syncProgress: Observable<CGFloat> { progressSubject.asObservable() }
    
    private func processAllContacts() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if self.allContacts.count > 0 {
                self.syncContacts()
            } else {
                self.progress = 1
                self.resultSubject.onNext([])
                self.isSyncingSubject.onNext(false)
            }
        }
    }
    
    var allContacts = [Contact]()
    var thumbnails = [String: Data]()
    
    public init(repository: ContactsRepositoryType) {
        self.repository = repository
        super.init()
//        self.setupFRC()
//        NotificationCenter.default.addObserver(
//            self, selector: #selector(contactStoreDidChange), name: .CNContactStoreDidChange, object: nil)
    }
    
    @objc func contactStoreDidChange(notification: NSNotification) {
        contactsNeedToBeSynced = true
        self.allContacts = []
        self.resultSubject.onNext([])
        progressSubject.onNext(0)
    }
    
    public func resetContactManager() {
        contactsNeedToBeSynced = true
        self.allContacts = []
        self.resultSubject.onNext([])
        progressSubject.onNext(0)
    }
    
    public func syncPhoneBookContacts() {
        self.results = []
        self.resultSubject.onNext([])
        self.makeContacts()
    }
    
    private func fetchAllPhoneContact() -> [CNContact] {
        self.isSyncingSubject.onNext(true)
        var contacts = [CNContact]()
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactThumbnailImageDataKey, CNContactIdentifierKey] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        
        do {
            try self.contactStore.enumerateContacts(with: request) {
                (contact, _) in
                contacts.append(contact)
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.isSyncingSubject.onNext(false)
            }
        }
        return contacts.filter { $0.phoneNumbers.count > 0 }
    }
    
    private func makeContacts() {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let `self` = self else { return }
            
            let contacts = self.fetchAllPhoneContact()
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.processContacts(contacts)
            }
        }
    }
    
    private func processContacts(_ contacts: [CNContact]) {
        
        let phoneNumberKit = PhoneNumberKit()
        var processedContacs = [Contact]()
        var phoneNumbersArray: [String] = []
        var contactsArray: [CNContact] = []
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            for cnContact in contacts {
                guard cnContact.phoneNumbers.count > 0 else { continue }
                for phoneNumber in cnContact.phoneNumbers {
                    guard !phoneNumber.value.stringValue.isEmpty else { continue }
                    let phoneNumber = phoneNumber.value.stringValue.filter("+0123456789".contains)
                    guard !phoneNumber.isEmpty else { continue }
                    phoneNumbersArray.append(phoneNumber)
                    contactsArray.append(cnContact)
                }
            }
            
            let result = phoneNumberKit.parse(phoneNumbersArray, ignoreType: true, shouldReturnFailedEmptyNumbers: true)
            
            for (index, number) in result.enumerated() {
                let cnContact = contactsArray[index]
                var formatted = phoneNumbersArray[index]
                if !number.numberString.isEmpty {
                    formatted = phoneNumberKit.format(number, toType: .international)
                }
                var components = formatted.components(separatedBy: " ")
                guard let countryCode = components.first?.replacingOccurrences(of: "+", with: "00") else { continue }
                components.removeFirst()
                
                if let data = cnContact.thumbnailImageData {
                    self.thumbnails[countryCode + components.joined()] = data
                }
                
                let name = CNContactFormatter.string(from: cnContact, style: .fullName) ?? (cnContact.givenName.isEmpty ? (countryCode + " " + components.joined()) : cnContact.givenName)
                let pNumbber = components.joined()
                let email = cnContact.emailAddresses.first?.value as String?
                
                processedContacs.append(Contact(name: name, phoneNumber: pNumbber, countryCode: countryCode, email: email, photoUrl: nil))
            }
            
            self.allContacts.append(contentsOf: processedContacs)
            self.processAllContacts()
        }
    }
    
    private func chunkSize(forContacts count: Int) -> Int {
        return count < 5000 ? 1000 : count < 25000 ? 3000 : 5000
    }
    
}

// MARK: API methods

extension ContactsManager {
    
    private func syncContacts() {
        
//                deleteFromDB(contacts: contactsTobeDeletedFromLocalDb())
//                allContacts = contactsTobeSynced()
        
        if allContacts.count == 0 {
            self.progress = 1
            //            self.entityDidChangeContent(entityHandler)
            return
        }
        
        let classifictionRequests = self.sendRequest(forContacts: allContacts)

//        let completed = Observable.combineLatest(classifictionRequests).share()
        
        classifictionRequests.map { _ in false }.bind(to: isSyncingSubject).disposed(by: disposeBag)

//        Observable.merge(classifictionRequests.map { $0.errors() }).map { $0.localizedDescription }.bind(to: errorSubject).disposed(by: disposeBag)

        classifictionRequests.elements().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            
            var classification = $0
            classification.modifyForEach { $0.setThumbnailData(self.thumbnails[$0.countryCode + $0.phoneNumber]) }
            self.results.append(contentsOf: classification)
            self.resultSubject.onNext(self.results.sorted(by: { $0.name < $1.name }))
            self.progress = 1
        }).disposed(by: disposeBag)
    }
    
    private func sendRequest(forContacts contacts: [Contact]) -> Observable<Event<[YAPContact]>> {
        return repository.classifyContacts(contacts).share()
    }
}

extension String {
    
    var containsNonEnglishNumbers: Bool {
        return !isEmpty && range(of: "[^0-9]", options: .regularExpression) == nil
    }
    
    var english: String {
        return self.applyingTransform(StringTransform.toLatin, reverse: false) ?? self
    }
}

// Database setup
extension ContactsManager {
    
//    func setupFRC() {
//        entityHandler.delegate = self
//        try? entityHandler.fetchRequest()
//    }
    
//    func createYapContacts(from dbContacts: [CDContact]) {
//
//        let yapContacts = dbContacts.reduce(into: [YAPContact](), { (array, contact) in
//            var yapContact = YAPContact(with: contact)
//            yapContact.setThumbnailData(self.thumbnails[yapContact.countryCode + yapContact.phoneNumber ])
//            array.append(yapContact)
//        })
//
//        let dict = yapContacts.reduce(into: [:]) { counts, letter in
//            counts[letter.phoneNumber] = letter
//        }
//
//        let uniqueAaray = dict.keys.compactMap { Key in
//            return dict[Key]
//        }
//
//        self.resultSubject.onNext(uniqueAaray.sorted(by: { $0.name < $1.name }))
//    }
}

// MARK: Contact

public struct Contact: Codable {
    public let name: String
    public let mobileNo: String
    public let countryCode: String
    public let email: String?
    public let photoUrl: String?
    
    init(name: String, phoneNumber: String, countryCode: String, email: String?, photoUrl: String?) {
        self.name = name
        self.mobileNo = phoneNumber
        self.countryCode = countryCode
        self.email = email
        self.photoUrl = photoUrl
    }
    
//    init?(cdContact: CDContact) {
//        guard let phoneNumber = cdContact.phoneNumber else { return nil }
//        self.name = cdContact.name ?? ""
//        self.phoneNumber = phoneNumber
//        self.countryCode = cdContact.countryCode ?? ""
//        self.email = cdContact.email
//        self.photoUrl = cdContact.photoUrl
//    }
}

extension Contact: Hashable {
    
    public static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.mobileNo == rhs.mobileNo
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(mobileNo)
        
    }
}

extension ContactsManager {
    
    public func syncContactsInBackground() {
//        let cdContacts = entityHandler.fetchContacts() ?? []
//        let contacts = self.convertCDContacts(cdContacts: cdContacts)
//        let contactsSyncingRequest = self.sendRequest(forContacts: contacts)
        
//        contactsSyncingRequest.elements().subscribe(onNext: { [weak self] response in
//            self?.updateSyncedContacts(contacts: response)
//        }).disposed(by: disposeBag)
    }
    
//    private func convertCDContacts(cdContacts: [CDContact]) -> [Contact] {
//        var contacts: [Contact] = []
//        for cdContact in cdContacts {
//            if let contact = Contact(cdContact: cdContact) {
//                contacts.append(contact)
//            }
//        }
//        return contacts
//    }
    
    private func updateSyncedContacts(contacts: [YAPContact]) {
//        guard let cdContacts = entityHandler.fetchContacts() else { return }
//        for contact in contacts {
//            if let cdContact = cdContacts.filter({ $0.phoneNumber == contact.phoneNumber && $0.name == contact.name && $0.countryCode == contact.countryCode }).first {
//                if cdContact.isYapUser != contact.isYapUser {
//                    cdContact.isYapUser = contact.isYapUser
//                }
//            }
//        }
//        entityHandler.update()
    }
}
