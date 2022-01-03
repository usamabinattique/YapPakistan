//
//  KYCQuestionsViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 06/10/2021.
//

import CardScanner
import Foundation
import RxSwift
import YAPComponents

struct KYCStrings {
    var title: String
    var subHeading: String
    var next: String
}

protocol KYCQuestionViewModelInput {
    var nextObserver: AnyObserver<Void> { get }
    var selectedItemObserver: AnyObserver<KYCQuestionCellViewModel> { get }
}

protocol KYCQuestionViewModelOutput {
    var optionViewModels: Observable<[KYCQuestionCellViewModel]> { get }
    var showError: Observable<String> { get }
    var isNextEnable: Observable<Bool> { get }
    var next: Observable<String> { get }
    var loader: Observable<Bool> { get }
    var strings: Observable<KYCStrings> { get }
}

protocol KYCQuestionViewModelType {
    var inputs: KYCQuestionViewModelInput { get }
    var outputs: KYCQuestionViewModelOutput { get }
}

class KYCQuestionViewModel: KYCQuestionViewModelInput, KYCQuestionViewModelOutput, KYCQuestionViewModelType {

    var optionViewModelsSubject = BehaviorSubject<[KYCQuestionCellViewModel]>(value: [])
    let showErrorSubject = PublishSubject<String>()
    var isNextEnableSubject = BehaviorSubject<Bool>(value: false)
    var nextSubject = PublishSubject<Void>()
    var successSubject = PublishSubject<String>()
    var loaderSubject = BehaviorSubject<Bool>(value: false)
    var selectedItemSubject = BehaviorSubject<KYCQuestionCellViewModel>(value: KYCQuestionCellViewModel(value: ""))
    var stringsSubject: BehaviorSubject<KYCStrings>

    var inputs: KYCQuestionViewModelInput { return self }
    var outputs: KYCQuestionViewModelOutput { return self }

    // MARK: Inputs
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var selectedItemObserver: AnyObserver<KYCQuestionCellViewModel> { selectedItemSubject.asObserver() }

    // MARK: Outputs
    var optionViewModels: Observable<[KYCQuestionCellViewModel]> { optionViewModelsSubject.asObservable() }
    var showError: Observable<String> { showErrorSubject.asObservable() }
    var isNextEnable: Observable<Bool> { isNextEnableSubject.asObservable() }
    var next: Observable<String> { successSubject.asObservable() }
    var loader: Observable<Bool> { loaderSubject.asObserver() }
    var strings: Observable<KYCStrings> { stringsSubject.asObservable() }

    // MARK: Properties
    var accountProvider: AccountProvider!
    let disposeBag = DisposeBag()
    private let cellViewModel: Observable<[KYCQuestionCellViewModel]>

    // MARK: Initialization

    init(accountProvider: AccountProvider,
         cellViewModel: Observable<[KYCQuestionCellViewModel]>,
         strings: KYCStrings) {

        self.accountProvider = accountProvider
        self.stringsSubject = BehaviorSubject<KYCStrings>(value: strings)
        self.cellViewModel = cellViewModel.share()

        self.cellViewModel
            .bind(to: optionViewModelsSubject)
            .disposed(by: disposeBag)

        self.cellViewModel.subscribe(onNext: { vms in
            let oss = vms.map({ $0.outputs.selected })

            oss.forEach { [unowned self] isSelected in
                isSelected.filter({ $0 })
                    .distinctUntilChanged()
                    .bind(to: self.isNextEnableSubject).disposed(by: self.disposeBag)
            }

        }).disposed(by: disposeBag)
        
    }
}
