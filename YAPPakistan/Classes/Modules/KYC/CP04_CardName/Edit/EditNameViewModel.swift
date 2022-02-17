//
//  EditNameViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 18/10/2021.
//

import Foundation
import RxSwift
import RxDataSources

protocol EditNameViewModelInput {
    var nextObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
    var nameObserver: AnyObserver<String> { get }
    var selectedNameSequence: AnyObserver<Int> {get}
}

protocol EditNameViewModelOutput {
    var name: Observable<String> { get }
    var cardName: Observable<String> { get }
    var charCount: Observable<String> { get }
    var next: Observable<String> { get }
    var back: Observable<Void> { get }
    var languageStrings: Observable<EditNameViewModel.LanguageStrings> { get }
  //  var cellViewModels: Observable<[NameLettersSequenceSelectionCellViewModel]> { get }
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
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
    var selectedNameSequence: AnyObserver<Int> { selectedNameSequenceSubject.asObserver() }

    // MARK: Outputs
    var name: Observable<String> { nameSubject.asObservable() }
    var cardName: Observable<String> { cardNameSubject.asObservable() }
    var charCount: Observable<String> { charCountSubject.asObserver() }
    var next: Observable<String> { nextSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var languageStrings: Observable<LanguageStrings> { languageStringsSubject.asObservable() }
    //var cellViewModels: Observable<[NameLettersSequenceSelectionCellViewModel]> { cellViewModelsSubject.asObservable() }
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { cellViewModelsSubject.asObservable() }

    // MARK: Subjects
    private var nameInputSubject = PublishSubject<String>()
    private var nameSubject = PublishSubject<String>()
    private var cardNameSubject = ReplaySubject<String>.create(bufferSize: 1)
    private var charCountSubject = ReplaySubject<String>.create(bufferSize: 1)
    private var nextWillSubject = PublishSubject<Void>()
    private var nextSubject = PublishSubject<String>()
    private var backSubject = PublishSubject<Void>()
    private let selectedNameSequenceSubject = PublishSubject<Int>()
    private var languageStringsSubject: BehaviorSubject<LanguageStrings>!
   // private let cellViewModelsSubject = ReplaySubject<[NameLettersSequenceSelectionCellViewModel]>.create(bufferSize: 1)
    private let cellViewModelsSubject = ReplaySubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>.create(bufferSize: 1)

    // MARK: Properties
    let disposeBag = DisposeBag()
    private var nameSequenceTypes = [NameSequence]()
    
    //TODO: send userCNICName from api
    init(name userCNICName: String) { //= "Sayyid Muhamad Alawi AlMa") {
        let name =  userCNICName.count > 26 ? String(userCNICName.prefix(26)) : userCNICName //"Sayyid Muhamad Alawi AlMa"
        languageSetup()

     /*   let limitString = nameInputSubject
            .distinctUntilChanged()
            .map({ $0.count > 26 ? String($0.prefix(26)) : $0 })
            .share()

        limitString.bind(to: nameSubject).disposed(by: disposeBag)
        limitString
            .map { "\($0.count)/26" }
            .bind(to: charCountSubject).disposed(by: disposeBag) */
        
        let limitString = cardNameSubject
            .map({ $0.count > 26 ? String($0.prefix(26)) : $0 })
            .share()

        limitString.bind(to: nameSubject).disposed(by: disposeBag)
        limitString
            .map { "\($0.count)/26" }
            .bind(to: charCountSubject).disposed(by: disposeBag)
        
//        limitString
//            .map({ $0.count == 0 ? "--": $0 })
//            .bind(to: cardNameSubject).disposed(by: disposeBag)

        nextWillSubject
            .withLatestFrom(cardNameSubject)
            .bind(to: nextSubject)
            .disposed(by: disposeBag)
        
        let nameSequence = NameSequence(name: name)
        var nameSequenceTypes = nameSequence.nameSequenceArray.map{ NameSequence(name: $0)  }
        
       // var nameSequenceTypes = [NameSequence(name: name),NameSequence(name: name.firstAndLastLetters),NameSequence(name: name.firstCharacterAndLastLetter)]
        // default name is selected
        nameSequenceTypes[0].isChecked = true
        self.nameSequenceTypes = nameSequenceTypes
        let cellVMs = nameSequenceTypes.map {  type -> NameLettersSequenceSelectionCellViewModel  in
            return NameLettersSequenceSelectionCellViewModel(type)
        }
        
        selectedNameSequenceSubject.subscribe(onNext: { [weak self] index in
            guard let `self` = self,  cellVMs.count > index else { return }
            var newVms = [NameLettersSequenceSelectionCellViewModel]()
            for (i,_) in cellVMs.enumerated() {
                var vm : NameLettersSequenceSelectionCellViewModel
                if i == index {
                    var type = self.nameSequenceTypes[index]
                    type.isChecked = true //!type.isChecked
                    self.nameSequenceTypes[i] = type
                } else {
                    self.nameSequenceTypes[i].isChecked = false
                }
                vm = NameLettersSequenceSelectionCellViewModel(self.nameSequenceTypes[i])
                newVms.append(vm)
            }
            self.cellViewModelsSubject.onNext([SectionModel(model: 0, items: newVms)])
            self.cardNameSubject.onNext(nameSequenceTypes[index].nameFormatted ?? "")
        }).disposed(by: disposeBag)
        cardNameSubject.onNext(name)
        cellViewModelsSubject.onNext([SectionModel(model: 0, items: cellVMs)])
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
