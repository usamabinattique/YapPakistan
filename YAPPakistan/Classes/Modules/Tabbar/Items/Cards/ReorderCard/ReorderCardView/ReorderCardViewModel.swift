//
//  ReorderCardViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 25/12/2021.
//

import Foundation
import RxSwift

protocol ReorderCardViewModelInput {
    var nextObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
    var editAddressObserver: AnyObserver<Void> { get }
}

protocol ReorderCardViewModelOutput {
    typealias LanguageStrings = (title: String, typeYourName: String, next: String)
    var next: Observable<Void> { get }
    var back: Observable<Void> { get }
    var editAddress: Observable<Void> { get }
    var loading: Observable<Bool> { get }
    var error: Observable<String> { get }
    var languageStrings: Observable<LanguageStrings> { get }
}

protocol ReorderCardViewModelType {
    var inputs: ReorderCardViewModelInput { get }
    var outputs: ReorderCardViewModelOutput { get }
}

class ReorderCardViewModel: ReorderCardViewModelType,
                            ReorderCardViewModelInput,
                            ReorderCardViewModelOutput {
    
    var inputs: ReorderCardViewModelInput { return self }
    var outputs: ReorderCardViewModelOutput { return self }
    
    // MARK: Inputs
    var editAddressObserver: AnyObserver<Void> { editAddressSubject.asObserver() }
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    
    // MARK: Outputs
    var next: Observable<Void> { nextSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var editAddress: Observable<Void> { editAddressSubject.asObservable() }
    var loading: Observable<Bool> { loadingSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var languageStrings: Observable<LanguageStrings> { languageStringsSubject.asObservable() }
    
    // MARK: Subjects
    private var nextSubject = PublishSubject<Void>()
    private var backSubject = PublishSubject<Void>()
    private var editAddressSubject = PublishSubject<Void>()
    private var nextResultSubject = PublishSubject<String>()
    private var loadingSubject = BehaviorSubject<Bool>(value: false)
    private var errorSubject = PublishSubject<String>()
    private var languageStringsSubject: BehaviorSubject<LanguageStrings>!
    
    // MARK: Properties
    let serialNumber: String
    let disposeBag = DisposeBag()
    let repository: CardsRepositoryType
    
    init(serialNumber: String, repository: CardsRepositoryType) {
        self.serialNumber = serialNumber
        self.repository = repository
        
        languageSetup()
        
//        nameSubject
//            .distinctUntilChanged()
//            .map({ $0.count > 26 ? String($0.prefix(26)): $0 }).withUnretained(self)
//            .subscribe(onNext: { `self`, value in self.updateName(name: value) })
//            .disposed(by: disposeBag)
        
//        let result = nextSubject
//            .withLatestFrom(nameSubject).withUnretained(self)
//            .do(onNext: { `self`, _ in self.loadingSubject.onNext(true) })
//            .map{ `self`, newName in (self.repository, newName, self.serialNumber) }
//            .flatMapLatest({ $0.setCardName(cardName: $1, cardSerialNumber: $2) })
//            .do(onNext: { [weak self] _ in self?.loadingSubject.onNext(false) })
//            .share()
        
//        result.elements().withLatestFrom(nameSubject)
//            .bind(to: nextResultSubject)
//            .disposed(by: disposeBag)
//
//        result.errors().map{ $0.localizedDescription }
//            .bind(to: errorSubject)
//            .disposed(by: disposeBag)
    }
}

fileprivate extension  ReorderCardViewModel {
    
    func languageSetup() {
        let strings = LanguageStrings(title: "Name your card",
                                      typeYourName: "Name your prime card",
                                      next: "Confirm")
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}
