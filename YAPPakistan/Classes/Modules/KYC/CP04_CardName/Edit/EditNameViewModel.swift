//
//  EditNameViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 18/10/2021.
//

import Foundation
import RxSwift

protocol EditNameViewModelInput {
    var nextObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
    var nameObserver: AnyObserver<String> { get }
}

protocol EditNameViewModelOutput {
    var name: Observable<String> { get }
    var cardName: Observable<String> { get }
    var charCount: Observable<String> { get }
    var next: Observable<String> { get }
    var back: Observable<Void> { get }
    var languageStrings: Observable<EditNameViewModel.LanguageStrings> { get }
    var cellViewModels: Observable<[NameLettersSequenceSelectionCellViewModel]> { get }
}

protocol EditNameViewModelType {
    var inputs: EditNameViewModelInput { get }
    var outputs: EditNameViewModelOutput { get }
}

class EditNameViewModel: EditNameViewModelType, EditNameViewModelInput, EditNameViewModelOutput {

    var inputs: EditNameViewModelInput { return self }
    var outputs: EditNameViewModelOutput { return self }

    // MARK: Inputs
    var nameObserver: AnyObserver<String> { nameInputSubject.asObserver() }
    var nextObserver: AnyObserver<Void> { nextWillSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }

    // MARK: Outputs
    var name: Observable<String> { nameSubject.asObservable() }
    var cardName: Observable<String> { cardNameSubject.asObservable() }
    var charCount: Observable<String> { charCountSubject.asObserver() }
    var next: Observable<String> { nextSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var languageStrings: Observable<LanguageStrings> { languageStringsSubject.asObservable() }
    var cellViewModels: Observable<[NameLettersSequenceSelectionCellViewModel]> { cellViewModelsSubject.asObservable() }

    // MARK: Subjects
    private var nameInputSubject = PublishSubject<String>()
    private var nameSubject = PublishSubject<String>()
    private var cardNameSubject = PublishSubject<String>()
    private var charCountSubject = PublishSubject<String>()
    private var nextWillSubject = PublishSubject<Void>()
    private var nextSubject = PublishSubject<String>()
    private var backSubject = PublishSubject<Void>()
    private var languageStringsSubject: BehaviorSubject<LanguageStrings>!
    private let cellViewModelsSubject = ReplaySubject<[NameLettersSequenceSelectionCellViewModel]>.create(bufferSize: 1)

    // MARK: Properties
    let disposeBag = DisposeBag()

    init() {
        languageSetup()

        let limitString = nameInputSubject
            .distinctUntilChanged()
            .map({ $0.count > 26 ? String($0.prefix(26)) : $0 })
            .share()

        limitString.bind(to: nameSubject).disposed(by: disposeBag)
        limitString
            .map { "\($0.count)/26" }
            .bind(to: charCountSubject).disposed(by: disposeBag)
        
        limitString
            .map({ $0.count == 0 ? "--": $0 })
            .bind(to: cardNameSubject).disposed(by: disposeBag)

        nextWillSubject
            .withLatestFrom(nameInputSubject)
            .bind(to: nextSubject)
            .disposed(by: disposeBag)
        
        let name = "Sayyid Muhamad Alawi AlMa"
        let nameSequenceTypes = [NameSequence(name: name),NameSequence(name: name.firstAndLastLetters),NameSequence(name: name.firstCharacterAndLastLetter)]
        let cellVMs = nameSequenceTypes.map { type  in
            return NameLettersSequenceSelectionCellViewModel(type:type)
        }
        cellViewModelsSubject.onNext(cellVMs)
    }

    struct LanguageStrings {
        let title: String
        let subTitle: String
        let typeYourName: String
        let tips: String
        let next: String
    }
}

fileprivate extension EditNameViewModel {
    func languageSetup() {
        let strings = LanguageStrings(title: "screen_kyc_card_edit_title".localized,
                                      subTitle: "screen_kyc_card_subtitle".localized,
                                      typeYourName: "screen_kyc_card_typeyourname".localized,
                                      tips: "screen_kyc_card_tip".localized,
                                      next: "common_button_next".localized)
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}
