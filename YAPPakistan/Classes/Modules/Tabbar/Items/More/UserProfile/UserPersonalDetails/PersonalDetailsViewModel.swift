//
//  PersonalDetailsViewModel.swift
//  YAP
//
//  Created by Muhammad Hassan on 03/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents


protocol PersonalDetailsViewModelInputs {
    var refreshObserver: AnyObserver<Void> { get }
    var editPhoneTapObserver: AnyObserver<Void> { get }
    var editEmailTapObserver: AnyObserver<Void> { get }
    var editAddressTapObserver: AnyObserver<Void> { get }
    var emiratesIDStatusObserver: AnyObserver<UserProfileViewModel.EmiratesIDStatus> { get }
    var updateEmiratesIDTapObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
    var addressUpdatedObserver: AnyObserver<Void> { get }
}

protocol PersonalDetailsViewModelOutputs {
    var title: Observable<String> { get }
    var fullName: Observable<String> { get }
    var phone: Observable<String> { get }
    var editPhoneTap: Observable<Void> { get }
    var email: Observable<String> { get }
    var editEmailTap: Observable<Void> { get }
    var address: Observable<String> { get }
    var editAddressTap: Observable<Void> { get }
    var emiratesIDStatus: Observable<UserProfileViewModel.EmiratesIDStatus> { get }
    var updateEmiratesIDTap: Observable<Void> { get }
    var isValidCnic: Observable<Bool> { get }
    var error: Observable<Error> { get }
    var back: Observable<Void> { get }
    var showBlockedOTPError: Observable<String>{ get }
}

protocol PersonalDetailsViewModelType {
    var inputs: PersonalDetailsViewModelInputs { get }
    var outputs: PersonalDetailsViewModelOutputs { get }
}

class PersonalDetailsViewModel: PersonalDetailsViewModelType, PersonalDetailsViewModelInputs, PersonalDetailsViewModelOutputs {

    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: PersonalDetailsViewModelInputs { return self }
    var outputs: PersonalDetailsViewModelOutputs { return self }
    var accountRepository : AccountRepositoryType

    private let customer: Observable<Customer>
    private let refreshSubject = PublishSubject<Void>()
    private var emiratesIDStatusSubject = BehaviorSubject<UserProfileViewModel.EmiratesIDStatus>(value: .none)
    private let editPhoneTapSubject = PublishSubject<Void>()
    private let editEmailTapSubject = PublishSubject<Void>()
    private let editAddressTapSubject = PublishSubject<Void>()
    private let updateEmiratesIDTapSubject = PublishSubject<Void>()
    private let blockedOTPErrorMessageSubject = PublishSubject<String>()
    private let errorSubject = PublishSubject<Error>()
    private let backSubject = PublishSubject<Void>()
    private let addressUpdatedSubject = BehaviorSubject<Void>(value: ())
    private let isValidCnicSubject =  PublishSubject<Bool>()
    
    private let fullNameSubject = PublishSubject<String>()
    private let phoneSubject = PublishSubject<String>()
    private let emailSubject = PublishSubject<String>()
    private let addressSubject = PublishSubject<String>()


    // MARK: - Inputs
    var refreshObserver: AnyObserver<Void> { return refreshSubject.asObserver() }
    var editPhoneTapObserver: AnyObserver<Void> { return editPhoneTapSubject.asObserver() }
    var editEmailTapObserver: AnyObserver<Void> { return editEmailTapSubject.asObserver() }
    var editAddressTapObserver: AnyObserver<Void> { return editAddressTapSubject.asObserver() }
    var emiratesIDStatusObserver: AnyObserver<UserProfileViewModel.EmiratesIDStatus> { return emiratesIDStatusSubject.asObserver() }
    var updateEmiratesIDTapObserver: AnyObserver<Void> { return updateEmiratesIDTapSubject.asObserver() }
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    var addressUpdatedObserver: AnyObserver<Void> { return addressUpdatedSubject.asObserver() }

    // MARK: - Outputs
    var title: Observable<String> { return Observable.of( "screen_personal_details_display_text_personal_details_title".localized) }
    var fullName: Observable<String> { fullNameSubject.asObservable() }
    var phone: Observable<String> { phoneSubject.asObservable() }
    var editPhoneTap: Observable<Void> { return editPhoneTapSubject.asObservable() }
    var email: Observable<String> { emailSubject.asObservable() }
    var editEmailTap: Observable<Void> { return editEmailTapSubject.asObservable() }
    var address: Observable<String> { addressSubject.asObservable() }
    var editAddressTap: Observable<Void> { return editAddressTapSubject.asObservable() }
    var emiratesIDStatus: Observable<UserProfileViewModel.EmiratesIDStatus> { return emiratesIDStatusSubject.asObservable() }
    var updateEmiratesIDTap: Observable<Void> { return updateEmiratesIDTapSubject.asObservable() }
    var isValidCnic: Observable<Bool> { isValidCnicSubject.asObservable() }
    var error: Observable<Error> { return errorSubject.asObservable() }
    var back: Observable<Void> { return backSubject.asObservable() }
    
    var showBlockedOTPError: Observable<String>{ blockedOTPErrorMessageSubject.asObservable() }
    // MARK: - Init
    init(_ customer: Observable<Customer>, accountRepository: AccountRepositoryType) {
        self.accountRepository = accountRepository
        
        self.customer = customer
        fetchCustomer()

        //emiratesIDStatusSubject = BehaviorSubject(value: emiratesIDStatus)

//        let request = addressUpdatedSubject.flatMap { profileRepository.getLastLocation() }.do(onNext: { _ in YAPProgressHud.hideProgressHud() }).share(replay: 1, scope: .whileConnected)
//
//        request.elements().unwrap().map { [$0.address1, $0.address2, $0.city].compactMap{ $0 }.joined(separator: ", ") }.bind(to: addressSubject).disposed(by: disposeBag)
//        request.errors().bind(to: errorSubject).disposed(by: disposeBag)
        
    }
    
    
    func fetchCustomer() {
        
        let fetchPersonalDetail = refreshSubject
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .flatMap { self.accountRepository.fetchCustomerPersonalDetails() }
            .share()
        
        fetchPersonalDetail
            .subscribe(onNext:{ _ in YAPProgressHud.hideProgressHud() })
            .disposed(by: disposeBag)
        
        fetchPersonalDetail.errors()
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
        
        fetchPersonalDetail.elements()
            .subscribe(onNext: { [unowned self] data in
                self.fullNameSubject.onNext(data.fullName)
                self.phoneSubject.onNext(data.phoneNumber)
                self.emailSubject.onNext(data.email)
                self.addressSubject.onNext(data.address)
                self.isValidCnicSubject.onNext(data.cnicExpired)
            })
            .disposed(by: disposeBag)
    }
}
