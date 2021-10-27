//
//  CountryViewModel.swift
//  Pods
//
//  Created by Sarmad on 20/10/2021.
//

import CardScanner
import Foundation
import RxSwift
import YAPComponents

protocol CityListViewModelInput {
    var backObserver: AnyObserver<Void> { get }
    var searchObserver: AnyObserver<String?> { get }
    var selectedItemObserver: AnyObserver<LabelCellViewModel> { get }
}

protocol CityListViewModelOutput {
    var cellViewModels: Observable<[LabelCellViewModel]> { get }
    var showError: Observable<String> { get }
    var next: Observable<String> { get }
    var back: Observable<Void> { get }
    var loader: Observable<Bool> { get }
    var strings: Observable<CityListViewModel.LanguageStrings> { get }
}

protocol CityListViewModelType {
    var inputs: CityListViewModelInput { get }
    var outputs: CityListViewModelOutput { get }
}

class CityListViewModel: CityListViewModelInput, CityListViewModelOutput, CityListViewModelType {

    var inputs: CityListViewModelInput { return self }
    var outputs: CityListViewModelOutput { return self }

    // MARK: Inputs
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    var searchObserver: AnyObserver<String?> { searchSubject.asObserver() }
    var selectedItemObserver: AnyObserver<LabelCellViewModel> { selectedItemSubject.asObserver() }

    // MARK: Outputs
    var cellViewModels: Observable<[LabelCellViewModel]> { cellViewModelsSubject.asObservable() }
    var showError: Observable<String> { showErrorSubject.asObservable() }
    var next: Observable<String> { nextSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObserver() }
    var loader: Observable<Bool> { loaderSubject.asObserver() }
    var strings: Observable<LanguageStrings> { stringsSubject.asObservable() }

    // MARK: Subjects
    var cellViewModelsSubject = BehaviorSubject<[LabelCellViewModel]>(value: [])
    let showErrorSubject = PublishSubject<String>()
    var isNextEnableSubject = BehaviorSubject<Bool>(value: false)
    var nextSubject = PublishSubject<String>()
    var backSubject = PublishSubject<Void>()
    var loaderSubject = BehaviorSubject<Bool>(value: false)
    var searchSubject = PublishSubject<String?>()
    var selectedItemSubject = PublishSubject<LabelCellViewModel>()
    var stringsSubject: BehaviorSubject<LanguageStrings>!

    // MARK: Properties
    let disposeBag = DisposeBag()
    private let kycRepository: KYCRepositoryType
    private var citiesRequest: Observable<Event<[Cities]>>!

    // MARK: Initialization

    init(kycRepository: KYCRepositoryType) {

        self.kycRepository = kycRepository

        languageSetup()

        loaderSubject.on(.next(true))

        selectedItemSubject
            .flatMap({ $0.outputs.value })
            .bind(to: nextSubject)
            .disposed(by: disposeBag)

        citiesRequest = kycRepository
            .getCities()
            .do(onNext: { [unowned self] _ in self.loaderSubject.onNext(false) })
            .share()

        Observable.combineLatest(searchSubject, citiesRequest.elements())
            .map { query, cities -> [Cities] in
                if query?.count ?? 0 == 0 {
                    return cities
                } else {
                    return cities.filter({ ($0.name ?? "").contains(query ?? "") })
                }
            }
            .map({ $0.map{ LabelCellViewModel(value: $0.name ?? "" ) } })
            .bind(to: cellViewModelsSubject)
            .disposed(by: disposeBag)

            citiesRequest.errors()
            .subscribe { errlr in
                print(errlr.localizedDescription)
            } onError: { error in
                print(error.localizedDescription)
            } onCompleted: {
                print("completed")
            } onDisposed: {
                print("disposed")
            }
            .disposed(by: disposeBag)
    }

    struct LanguageStrings {
        let title: String
        let searchPlaceholder: String
    }

    fileprivate func languageSetup() {
        let strings = LanguageStrings(title: "".localized,
                                      searchPlaceholder: "".localized)
        self.stringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }

}
