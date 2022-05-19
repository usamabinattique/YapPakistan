//
//  SearchFAQsViewModel.swift
//  Adjust
//
//  Created by Awais on 18/05/2022.
//

import Foundation
import RxSwift
import RxDataSources
import YAPComponents

protocol SearchFAQsViewModelInput {
    var textObserver: AnyObserver<String?> { get }
    var cancelObserver: AnyObserver<Void> { get }
    var tableViewItemTapped: AnyObserver<ReusableTableViewCellViewModelType> { get }
}

protocol SearchFAQsViewModelOutput {
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var error: Observable<String>{ get }
    var showFAQDetail: Observable<FAQsResponse> { get }
    var cancel: Observable<Void>{ get }
}

protocol SearchFAQsViewModelType {
    var inputs: SearchFAQsViewModelInput { get }
    var outputs: SearchFAQsViewModelOutput { get }
}

class SearchFAQsViewModel: SearchFAQsViewModelType, SearchFAQsViewModelInput, SearchFAQsViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: SearchFAQsViewModelInput { return self }
    var outputs: SearchFAQsViewModelOutput { return self }
    
    private let showFAQDetailsSubject = PublishSubject<FAQsResponse>()
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    var tableViewCells: [ReusableTableViewCellViewModelType] = [FAQsTableViewCellViewModel]()
    private let textSubject = PublishSubject<String?>()
    private let cancelSubject = PublishSubject<Void>()
    private let tableViewItemTappedSubject = PublishSubject<ReusableTableViewCellViewModelType>()
    private let errorSubject = PublishSubject<String>()
    
    // MARK: - Inputs
    var tableViewItemTapped: AnyObserver<ReusableTableViewCellViewModelType> { return tableViewItemTappedSubject.asObserver() }
    var textObserver: AnyObserver<String?> { return textSubject.asObserver() }
    var cancelObserver: AnyObserver<Void> { return cancelSubject.asObserver() }
    
    
    // MARK: - Outputs
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var cancel: Observable<Void> { cancelSubject.asObservable() }
    var showFAQDetail: Observable<FAQsResponse> { return showFAQDetailsSubject.asObservable() }
    
    private var faqs = [FAQsResponse]()
    
    // MARK: - Init
    init(faqs: [FAQsResponse]) {
        
        self.faqs = faqs
        self.prepareCellViewModels()
        self.reloadTableViewCells()
        search()
        
        tableViewItemTappedSubject.subscribe(onNext: { [unowned self] item in
            guard let selectedItem = item as? FAQsTableViewCellViewModel else { return }
            self.getTappedFAQ(viewModel: selectedItem)
        }).disposed(by: disposeBag)
    }
    
    func getTappedFAQ(viewModel: FAQsTableViewCellViewModel) {
        var question = ""
        viewModel.question.subscribe(onNext: { [unowned self] questionString in
            question = questionString ?? ""
        }).disposed(by: disposeBag)
        
        var faqs = self.faqs
        faqs.removeAll { faq in
            if faq.question == question { return false }
            else { return true }
        }
        self.showFAQDetailsSubject.onNext(faqs.first!)
    }
    
    func prepareCellViewModels() {
        self.tableViewCells.removeAll()
        for faq in self.faqs {
            tableViewCells.append(FAQsTableViewCellViewModel(faq: faq))
        }
    }
    
    func reloadTableViewCells() {
        self.dataSourceSubject.onNext([SectionModel(model: 0, items: tableViewCells)])
    }
}

// MARK: Search

private extension SearchFAQsViewModel {
    func search() {
        textSubject.subscribe(onNext: { searchText in
            print("Searched Text: \(searchText)")
            self.faqs = self.faqs.sorted(by: { $0.question.contains(searchText ?? "") && !$1.question.contains(searchText ?? "") })
            self.prepareCellViewModels()
             self.reloadTableViewCells()
        }).disposed(by: disposeBag)
    }
}

