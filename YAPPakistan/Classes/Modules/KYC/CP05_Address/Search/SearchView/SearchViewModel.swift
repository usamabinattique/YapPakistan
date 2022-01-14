//
//  SearchViewModel.swift
//  YAP
//
//  Created by Zain on 10/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents

protocol SearchViewModelInput {
    var textObserver: AnyObserver<String?> { get }
    var cancelObserver: AnyObserver<Void> { get }
    var refreshObserver: AnyObserver<Void> { get }
}

protocol SearchViewModelOutput {
    var cellViewModels: Observable<[SearchCellViewModel]> { get }
    var cancel: Observable<Void>{ get }
    var error: Observable<String>{ get }
}

protocol SearchViewModelType {
    var inputs: SearchViewModelInput { get }
    var outputs: SearchViewModelOutput { get }
}

class SearchViewModel: SearchViewModelType, SearchViewModelInput, SearchViewModelOutput {

    var inputs: SearchViewModelInput { return self }
    var outputs: SearchViewModelOutput { return self }

    // MARK: - Inputs
    var textObserver: AnyObserver<String?> { textSubject.asObserver() }
    var cancelObserver: AnyObserver<Void> { cancelSubject.asObserver() }
    var refreshObserver: AnyObserver<Void> { refreshSubject.asObserver() }

    // MARK: - Outputs
    var cellViewModels: Observable<[SearchCellViewModel]> { cellViewModelsSubject.asObserver() }
    var cancel: Observable<Void> { cancelSubject.asObserver() }
    var error: Observable<String> { errorSubject.asObserver() }

    // MARK: - Subjects
    var textSubject = PublishSubject<String?>()
    var refreshSubject = PublishSubject<Void>()
    var cellViewModelsSubject = PublishSubject<[SearchCellViewModel]>()
    var cancelSubject = PublishSubject<Void>()
    var errorSubject = PublishSubject<String>()

    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    // private let repository : SendMoneyRepositoryType!
    
    // MARK: - Init
    init() {
        search()
        refresh()
    }
}

// MARK: Search

private extension SearchViewModel {
    func search() {
        let queryText = textSubject
            .debounce(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .userInteractive))
            .unwrap()
            .flatMapLatest { queryString in
                return Observable.just(queryString)
            }.materialize()

        //queryText.elements().withUnretained(self)

    }
}

// MARK: Refresh beneficiary list

private extension SearchViewModel {
    func refresh() {
//        let refreshRequest = refreshSubject
//            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
//            .flatMap{ [unowned self] _ in self.repository.fetchBeneficiaries() }
//            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
//            .share()
//
//        refreshRequest.errors()
//            .map{ $0.localizedDescription }
//            .bind(to: errorSubject)
//            .disposed(by: disposeBag)
//
//        refreshRequest.elements()
//            .map { $0.enumerated().map { SendMoneyBeneficiary($0.1, index: $0.0) } }
//            .do(onNext: { [weak self] in self?.allBeneficiaries = $0 })
//            .withLatestFrom(textSubject)
//            .bind(to: textSubject)
//            .disposed(by: disposeBag)
    }
}
