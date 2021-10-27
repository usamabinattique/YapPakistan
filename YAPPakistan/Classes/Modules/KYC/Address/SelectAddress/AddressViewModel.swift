//
//  AddressViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 19/10/2021.
//

import Foundation
import RxSwift

protocol AddressViewModelInput {
    var nextObserver: AnyObserver<Void> { get }
    var cityObserver: AnyObserver<Void> { get }
    var citySelectObserver: AnyObserver<String> { get }
    var backObserver: AnyObserver<Void> { get }
}

protocol AddressViewModelOutput {
    var next: Observable<Void> { get }
    var back: Observable<Void> { get }
    var city: Observable<Void> { get }
    var citySelected: Observable<String> { get }
    var languageStrings: Observable<AddressViewModel.LanguageStrings> { get }
}

protocol AddressViewModelType {
    var inputs: AddressViewModelInput { get }
    var outputs: AddressViewModelOutput { get }
}

class AddressViewModel: AddressViewModelType, AddressViewModelInput, AddressViewModelOutput {

    // MARK: Inputs
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    var cityObserver: AnyObserver<Void> { citySubject.asObserver() }
    var citySelectObserver: AnyObserver<String> { citySelectSubject.asObserver() }

    // MARK: Outputs
    var languageStrings: Observable<LanguageStrings> { return languageStringsSubject.asObservable() }
    var next: Observable<Void> { nextSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var city: Observable<Void> { citySubject.asObservable() }
    var citySelected: Observable<String> { citySelectSubject.asObserver() }

    // MARK: Subjects
    var languageStringsSubject: BehaviorSubject<LanguageStrings>!
    private var nextSubject = PublishSubject<Void>()
    private var backSubject = PublishSubject<Void>()
    private var citySubject = PublishSubject<Void>()
    private var citySelectSubject = PublishSubject<String>()

    var inputs: AddressViewModelInput { return self }
    var outputs: AddressViewModelOutput { return self }

    init() {
        languageSetup()
    }

    struct LanguageStrings {
        let title: String
        let subTitle: String
        let location: String
        let address: String
        let flatnumber: String
        let city: String
        let next: String
    }
}

fileprivate extension AddressViewModel {
    func languageSetup() {
        let strings = LanguageStrings(title: "screen_kyc_address_title".localized,
                                      subTitle: "screen_kyc_address_subtitle".localized,
                                      location: "screen_kyc_address_taplocation".localized,
                                      address: "screen_kyc_address_address".localized,
                                      flatnumber: "screen_kyc_address_flatbuilding".localized,
                                      city: "screen_kyc_address_city".localized,
                                      next: "common_button_next".localized)
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}
