//
//  AccountSelectionViewModel.swift
//  App
//
//  Created by Zain on 18/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//
/*
import RxSwift
//import Authentication

protocol AccountSelectionViewModelInput {
    var personalObserver: AnyObserver<Void> { get }
    var businessObserver: AnyObserver<Void> { get }
    var signInObserver: AnyObserver<Void> { get }
}

protocol AccountSelectionViewModelOutput {
    var personal: Observable<Void> { get }
    var business: Observable<Void> { get }
    var signIn: Observable<Void> { get }
}

protocol AccountSelectionViewModelType:ViewModelType, AccountSelectionViewModelInput, AccountSelectionViewModelOutput  {
    
    var inputs: AccountSelectionViewModelInput  { get }
    var outputs: AccountSelectionViewModelOutput{ get }
    
    var personalSubject:PublishSubject<Void>    { get }
    var businessSubject:PublishSubject<Void>    { get }
    var signInSubject:PublishSubject<Void>      { get }
    
}

extension AccountSelectionViewModelType {
    var inputs: AccountSelectionViewModelInput { return self }
    var outputs: AccountSelectionViewModelOutput { return self }
    
    // inputs
    var personalObserver: AnyObserver<Void> { return personalSubject.asObserver() }
    var businessObserver: AnyObserver<Void> { return businessSubject.asObserver() }
    var signInObserver: AnyObserver<Void> { return signInSubject.asObserver() }
    
    // outputs
    var personal: Observable<Void> { return personalSubject.asObservable() }
    var business: Observable<Void> { return businessSubject.asObservable() }
    var signIn: Observable<Void> { return signInSubject.asObservable() }
}

class AccountSelectionViewModel:ViewModel, AccountSelectionViewModelType {
    let personalSubject = PublishSubject<Void>()
    let businessSubject = PublishSubject<Void>()
    let signInSubject = PublishSubject<Void>()
}

*/