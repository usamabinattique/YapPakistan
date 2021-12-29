//
//  ReorderSuccessViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 27/12/2021.
//

import Foundation
import RxSwift

protocol ReorderSuccessViewModelInput {
    var backObserver: AnyObserver<Void> { get }
}

protocol ReorderSuccessViewModelOutput {
    typealias LanguageStrings = (title: String, typeYourName: String, next: String)
    var back: Observable<Void> { get }
    var languageStrings: Observable<LanguageStrings> { get }
}

protocol ReorderSuccessViewModelType {
    var inputs: ReorderSuccessViewModelInput { get }
    var outputs: ReorderSuccessViewModelOutput { get }
}

class ReorderSuccessViewModel: ReorderSuccessViewModelType,
                               ReorderSuccessViewModelInput,
                               ReorderSuccessViewModelOutput {
    
    var inputs: ReorderSuccessViewModelInput { return self }
    var outputs: ReorderSuccessViewModelOutput { return self }
    
    // MARK: Inputs
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    
    // MARK: Outputs
    var back: Observable<Void> { backSubject.asObservable() }
    var languageStrings: Observable<LanguageStrings> { languageStringsSubject.asObservable() }
    
    // MARK: Subjects
    private var backSubject = PublishSubject<Void>()
    private var languageStringsSubject: BehaviorSubject<LanguageStrings>!
    
    // MARK: Properties
    let disposeBag = DisposeBag()
    
    init() {
        languageSetup()
    }
}

fileprivate extension  ReorderSuccessViewModel {
    func languageSetup() {
        let strings = LanguageStrings(title: "Name your card",
                                      typeYourName: "Name your prime card",
                                      next: "Confirm")
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}

