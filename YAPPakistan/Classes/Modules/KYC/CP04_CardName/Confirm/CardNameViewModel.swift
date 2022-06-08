//
//  CardNameViewModel.swift
//  Adjust
//
//  Created by Sarmad on 18/10/2021.
//

import Foundation
import RxSwift

protocol CardNameViewModelInput {
    var nextObserver: AnyObserver<Void> { get }
    var editObserver: AnyObserver<Void> { get }
    var nameObserver: AnyObserver<String> { get }
    var backObserver: AnyObserver<Void> { get }
}

protocol CardNameViewModelOutput {
    var name: Observable<String> { get }
    var cardImage: Observable<String> { get }
    var next: Observable<Void> { get }
    var edit: Observable<Void> { get }
    var back: Observable<Void> { get }
    var loading: Observable<Bool> { get }
    var showError: Observable<String> { get }
    var languageStrings: Observable<CardNameViewModel.LanguageStrings> { get }
    var editNameForEditNameScreen: Observable<String> { get }
}

protocol CardNameViewModelType {
    var inputs: CardNameViewModelInput { get }
    var outputs: CardNameViewModelOutput { get }
}

class CardNameViewModel: CardNameViewModelType, CardNameViewModelInput, CardNameViewModelOutput {

    var inputs: CardNameViewModelInput { return self }
    var outputs: CardNameViewModelOutput { return self }

    // MARK: Inputs
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    var editObserver: AnyObserver<Void> { editSubject.asObserver() }
    var nameObserver: AnyObserver<String> { nameSubject.asObserver() }

    // MARK: Outputs
    var name: Observable<String> { return nameSubject.asObservable() }
    var cardImage: Observable<String> { cardImageSubject.asObservable() }
    var languageStrings: Observable<LanguageStrings> { return languageStringsSubject.asObservable() }
    var next: Observable<Void> { nextSuccessSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var edit: Observable<Void> { editSubject.asObservable() }
    var showError: Observable<String> { showErrorSubject.asObservable() }
    var loading: Observable<Bool> { loadingSubject.asObservable() }
    var editNameForEditNameScreen: Observable<String> { editNameForEditNameScreenSubject.asObservable() }

    // MARK: Subjects
    var languageStringsSubject: BehaviorSubject<LanguageStrings>!
    private var nameSubject = BehaviorSubject<String>(value: "")
    private var cardImageSubject = BehaviorSubject<String>(value: "")
    private var nextSubject = PublishSubject<Void>()
    private var nextSuccessSubject = PublishSubject<Void>()
    private var backSubject = PublishSubject<Void>()
    private var editSubject = PublishSubject<Void>()
    var showErrorSubject = PublishSubject<String>()
    private var loadingSubject = BehaviorSubject<Bool>(value: false)
    private let editNameForEditNameScreenSubject = ReplaySubject<String>.create(bufferSize: 1)
    
    // MARK: Properties
    private let disposeBag = DisposeBag()
    private let kycRepository: KYCRepositoryType
    private let accountProvider: AccountProvider

    init(kycRepository: KYCRepositoryType, accountProvider: AccountProvider, schemeObj: KYCCardsSchemeM) {

        self.kycRepository = kycRepository
        self.accountProvider = accountProvider
        if schemeObj.scheme == .Mastercard {
            cardImageSubject.onNext("image_payment_card_white")
        } else {
            cardImageSubject.onNext("image_payment_card_white_paypak")
        }

        languageSetup()

        self.accountProvider.currentAccount.unwrap()
            .map({ $0.cnicName ?? $0.customer.firstName + " " + $0.customer.lastName })
            .bind(to: nameSubject)
            .disposed(by: disposeBag)
        
        self.accountProvider.currentAccount.unwrap()
            .map({ $0.cnicName ?? $0.customer.firstName + " " + $0.customer.lastName })
            .bind(to: editNameForEditNameScreenSubject)
            .disposed(by: disposeBag)

        let setResult = self.nextSubject.withLatestFrom(nameSubject).withUnretained(self)
            .do(onNext: { `self`, _ in self.loadingSubject.onNext(true) })
            .flatMap({ `self`, name in self.kycRepository.setCardName(cardName: name) })
            .share()

        let refreshAccountRequest = setResult.elements()
            .flatMap { [unowned self] _ in self.accountProvider.refreshAccount() }
            .do(onNext: { [weak self] _ in self?.loadingSubject.onNext(false) })
            .share()

        refreshAccountRequest
            .bind(to: nextSuccessSubject)
            .disposed(by: disposeBag)

        setResult.errors()
            .do(onNext: { [weak self] _ in self?.loadingSubject.onNext(false) })
            .map { $0.localizedDescription }
            .bind(to: showErrorSubject)
            .disposed(by: disposeBag)
    }

    struct LanguageStrings {
        let title: String
        let subTitle: String
        let isThis: String
        let tips: String
        let thisIsFine: String
        let editName: String
    }
}

fileprivate extension CardNameViewModel {
    func languageSetup() {
        let strings = LanguageStrings(title: "screen_kyc_card_title".localized,
                                      subTitle: "screen_kyc_card_subtitle".localized,
                                      isThis: "screen_kyc_card_is_it".localized,
                                      tips: "screen_kyc_card_tip".localized,
                                      thisIsFine: "screen_kyc_card_thisisfine".localized,
                                      editName: "screen_kyc_card_editname".localized)
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}
