//
//  AddBeneficiaryCellViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 15/03/2022.
//

import Foundation
import YAPComponents
import RxSwift

protocol AddBeneficiaryCellViewModelInput {
    
}

protocol AddBeneficiaryCellViewModelOutput {
    var name: Observable<String?> { get }
    var phoneNubmer: Observable<String?> { get }
    var badgeCount: Observable<Int> { get }
    var isYapUser: Observable<Bool> { get }
//    var invite: Observable<(YAPContact, String)> { get }
    func thumbnail(forIndexPath indexPath: IndexPath) -> (String?, UIImage?)
    var shimmering: Observable<Bool> { get }
    var invite: Observable<(Void)> { get }
    
    //var bankImage: Observable<ImageWithURL> { get }
    var bankImage: Observable<(String?, UIImage?)> { get }
}

protocol AddBeneficiaryCellViewModelType {
    var inputs: AddBeneficiaryCellViewModelInput { get }
    var outputs: AddBeneficiaryCellViewModelOutput { get }
}

class AddBeneficiaryCellViewModel: AddBeneficiaryCellViewModelType, AddBeneficiaryCellViewModelInput, AddBeneficiaryCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: AddBeneficiaryCellViewModelInput { return self }
    var outputs: AddBeneficiaryCellViewModelOutput { return self }
    var reusableIdentifier: String { return AddBeneficiaryCell.defaultIdentifier }
    let bank: BankDetail
    let isShimmering: Bool
    
  //  private let bankImageSubject: BehaviorSubject<(String?, UIImage?)>
    
    private let nameSubject = BehaviorSubject<String?>(value: nil)
    private let phoneNumberSubject = BehaviorSubject<String?>(value: nil)
    private let badgeCountSubject = BehaviorSubject<Int>(value: 1)
    private let isYapUserSubject = BehaviorSubject<Bool>(value: false)
    private let shimmeringSubject: BehaviorSubject<Bool>
    private let bankImageSubject = BehaviorSubject<(String?, UIImage?)>(value: (nil, nil))
    
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
    var invite: Observable<(Void)> { inviteSubject.asObservable() }
  //  var bankImage: Observable<ImageWithURL> { bankImageSubject.asObservable() }
    func thumbnail(forIndexPath indexPath: IndexPath) -> (String?, UIImage?) {
        (bank.bankLogoUrl, bank.thumbnail(forIndex: indexPath.row))
    }
    
    var bankImage: Observable<(String?, UIImage?)> { return bankImageSubject.asObservable() }
    
    // MARK: - Init
    init(_ bank: BankDetail) {
        self.bank = bank
        nameSubject.onNext(bank.bankName)
//        phoneNumberSubject.onNext(contact.formattedPhoneNumber)
//        isYapUserSubject.onNext(contact.isYapUser)
      //  bankImageSubject = BehaviorSubject(value: bank.bankLogoUrl)
        shimmeringSubject = BehaviorSubject(value: false)
        self.isShimmering = false
        
        bankImageSubject.onNext((bank.bankLogoUrl, bank.bankName.thumbnail))
    }
    
    init() {
//        contact =  YAPContact(name: "Dummy looooooooooooooong Name", phoneNumber: "Dummy long Nick", countryCode: "", email: nil, isYapUser: true, photoUrl: nil, yapAccountDetails: nil, thumbnailData: nil, index: 0)

//        nameSubject.onNext("Dummy looooooo")
//        phoneNumberSubject.onNext(contact.formattedPhoneNumber)
//        isYapUserSubject.onNext(contact.isYapUser)
        bank = BankDetail(bankLogoUrl: nil, bankName: "Dummy looooooooooooooong Name", accountNoMinLength: 0, accountNoMaxLength: 0, ibanMinLength: 0, ibanMaxLength: 0, consumerId: "adf", formatMessage: "abc")
        nameSubject.onNext(bank.bankName)
        shimmeringSubject = BehaviorSubject(value: true)
        isShimmering = true
    }
    
    private func thumbnail(name: String) -> UIImage? {
        let color = UIColor.randomColor()
        return name.initialsImage(color: color)
       // return thumbnailData != nil ? UIImage.init(data: thumbnailData!) : name.initialsImage(color: color)
    }
}

