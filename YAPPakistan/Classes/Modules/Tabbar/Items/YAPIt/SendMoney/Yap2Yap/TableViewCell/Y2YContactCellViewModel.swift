//
//  Y2YContactCellViewModel.swift
//  YAP
//
//  Created by Zain on 17/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import YAPComponents
import RxSwift

protocol Y2YContactCellViewModelInput {
    var inviteObserver: AnyObserver<Void> { get }
}

protocol Y2YContactCellViewModelOutput {
    var name: Observable<String?> { get }
    var phoneNubmer: Observable<String?> { get }
    var badgeCount: Observable<Int> { get }
    var isYapUser: Observable<Bool> { get }
//    var invite: Observable<(YAPContact, String)> { get }
    func thumbnail(forIndexPath indexPath: IndexPath) -> (String?, UIImage?)
    var shimmering: Observable<Bool> { get }
}

protocol Y2YContactCellViewModelType {
    var inputs: Y2YContactCellViewModelInput { get }
    var outputs: Y2YContactCellViewModelOutput { get }
}

class Y2YContactCellViewModel: Y2YContactCellViewModelType, Y2YContactCellViewModelInput, Y2YContactCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: Y2YContactCellViewModelInput { return self }
    var outputs: Y2YContactCellViewModelOutput { return self }
    var reusableIdentifier: String { return Y2YContactCell.defaultIdentifier }
    let contact: YAPContact
    let isShimmering: Bool
    
    private let nameSubject = BehaviorSubject<String?>(value: nil)
    private let phoneNumberSubject = BehaviorSubject<String?>(value: nil)
    private let badgeCountSubject = BehaviorSubject<Int>(value: 1)
    private let isYapUserSubject = BehaviorSubject<Bool>(value: false)
    private let shimmeringSubject: BehaviorSubject<Bool>
    
    private let inviteSubject = PublishSubject<Void>()
    
    // MARK: - Inputs
    var inviteObserver: AnyObserver<Void> { return inviteSubject.asObserver() }
    
    // MARK: - Outputs
    var name: Observable<String?> { return nameSubject.asObservable() }
    var phoneNubmer: Observable<String?> { return phoneNumberSubject.asObservable() }
    var badgeCount: Observable<Int> { return badgeCountSubject.asObservable() }
    var isYapUser: Observable<Bool> { return isYapUserSubject.asObservable() }
//    var invite: Observable<(YAPContact, String)> { inviteSubject.withLatestFrom(SessionManager.current.currentAccount.map{ $0?.customer.customerId }.unwrap()).map{ AppReferralManager.getReferralUrl(for: $0) ?? "" }.map{ [unowned self] in (self.contact, $0) }.asObservable() }
    var shimmering: Observable<Bool> { shimmeringSubject.asObservable() }
    
    func thumbnail(forIndexPath indexPath: IndexPath) -> (String?, UIImage?) {
        (contact.photoUrl, contact.thumbnail(forIndex: indexPath.row))
    }
    
    // MARK: - Init
    init(_ contact: YAPContact) {
        self.contact = contact
        nameSubject.onNext(contact.name)
        phoneNumberSubject.onNext(contact.formattedPhoneNumber)
        isYapUserSubject.onNext(contact.isYapUser)
        
        shimmeringSubject = BehaviorSubject(value: false)
        self.isShimmering = false
    }
    
    init() {
        contact = YAPContact(name: "Dummy looooooooooooooong Name", phoneNumber: "Dummy long Nick", countryCode: "", email: nil, isYapUser: true, photoUrl: nil, yapAccountDetails: nil, thumbnailData: nil, index: 0)
        
        nameSubject.onNext(contact.name)
        phoneNumberSubject.onNext(contact.formattedPhoneNumber)
        isYapUserSubject.onNext(contact.isYapUser)
        
        shimmeringSubject = BehaviorSubject(value: true)
        isShimmering = true
    }
}
