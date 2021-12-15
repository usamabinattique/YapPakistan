//
//  ChangeCardnameViewModel.swift
//  Adjust
//
//  Created by Sarmad on 12/12/2021.
//

import Foundation
import RxSwift

protocol ChangeCardNameViewModelInput {
    var nextObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
    var nameObserver: AnyObserver<String> { get }
}

protocol ChangeCardNameViewModelOutput {
    typealias LanguageStrings = (title: String, typeYourName: String, next: String)
    var name: Observable<String> { get }
    var next: Observable<String> { get }
    var back: Observable<Void> { get }
    var loading: Observable<Bool> { get }
    var error: Observable<String> { get }
    var languageStrings: Observable<LanguageStrings> { get }
}

protocol ChangeCardNameViewModelType {
    var inputs: ChangeCardNameViewModelInput { get }
    var outputs: ChangeCardNameViewModelOutput { get }
}

class ChangeCardNameViewModel: ChangeCardNameViewModelType,
                               ChangeCardNameViewModelInput,
                               ChangeCardNameViewModelOutput {

    var inputs: ChangeCardNameViewModelInput { return self }
    var outputs: ChangeCardNameViewModelOutput { return self }

    // MARK: Inputs
    var nameObserver: AnyObserver<String> { nameSubject.asObserver() }
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }

    // MARK: Outputs
    var name: Observable<String> { nameSubject.asObservable() }
    var next: Observable<String> { nextResultSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var loading: Observable<Bool> { loadingSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var languageStrings: Observable<LanguageStrings> { languageStringsSubject.asObservable() }

    // MARK: Subjects
    private var nameSubject = BehaviorSubject<String>(value: "")
    private var nextSubject = PublishSubject<Void>()
    private var backSubject = PublishSubject<Void>()
    private var nextResultSubject = PublishSubject<String>()
    private var loadingSubject = BehaviorSubject<Bool>(value: false)
    private var errorSubject = PublishSubject<String>()
    private var languageStringsSubject: BehaviorSubject<LanguageStrings>!

    // MARK: Properties
    let serialNumber: String
    let disposeBag = DisposeBag()
    let repository: CardsRepositoryType

    init(serialNumber: String, currentName: String, repository: CardsRepositoryType) {
        self.serialNumber = serialNumber
        self.nameSubject.onNext(currentName)
        self.repository = repository

        languageSetup()

        nameSubject
            .distinctUntilChanged()
            .map({ $0.count > 26 ? String($0.prefix(26)): $0 }).withUnretained(self)
            .subscribe(onNext: { `self`, value in self.updateName(name: value) })
            .disposed(by: disposeBag)

        let result = nextSubject
            .withLatestFrom(nameSubject).withUnretained(self)
            .do(onNext: { `self`, _ in self.loadingSubject.onNext(true) })
            .map{ `self`, newName in (self.repository, newName, self.serialNumber) }
            .flatMapLatest({ $0.setCardName(cardName: $1, cardSerialNumber: $2) })
            .do(onNext: { [weak self] _ in self?.loadingSubject.onNext(false) })
            .share()

        result.elements().withLatestFrom(nameSubject)
            .bind(to: nextResultSubject)
            .disposed(by: disposeBag)

        result.errors().map{ $0.localizedDescription }
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
    }
}

fileprivate extension  ChangeCardNameViewModel {
    func updateName(name: String) {
        DispatchQueue.main.async { self.nameSubject.onNext(name) }
    }

    func languageSetup() {
        let strings = LanguageStrings(title: "Name your card",
                                      typeYourName: "Name your prime card",
                                      next: "Confirm")
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}
