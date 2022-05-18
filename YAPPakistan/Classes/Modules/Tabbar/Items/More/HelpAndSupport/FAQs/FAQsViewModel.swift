//
//  FAQsViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 17/05/2022.
//

import Foundation
import RxSwift
import RxDataSources
import YAPComponents

protocol FAQsViewModelInput {
    var itemTappedObserver: AnyObserver<ReusableCollectionViewCellViewModelType> { get }
}

protocol FAQsViewModelOutput {
    var dataSource: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
    var tableViewDataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
}

protocol FAQsViewModelType {
    var inputs: FAQsViewModelInput { get }
    var outputs: FAQsViewModelOutput { get }
}

class FAQsViewModel: FAQsViewModelInput, FAQsViewModelOutput, FAQsViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var repository : AccountRepository!
    var inputs: FAQsViewModelInput { return self }
    var outputs: FAQsViewModelOutput { return self }
    var cellViewModels: [ReusableCollectionViewCellViewModelType] = [FAQMenuItemCollectionViewCellViewModel]()
    var allFaqs = [FAQsResponse]()
    var faqsTitles = [String]()
    
    // MARK: Outputs
    var dataSource: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    var tableViewDataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return tableViewDataSourceSubject.asObservable()}
    
    // MARK: Inputs
    var itemTappedObserver: AnyObserver<ReusableCollectionViewCellViewModelType> { return itemTappedSubject.asObserver() }
    
    // MARK: Subjects
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>(value: [])
    private let tableViewDataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let itemTappedSubject = PublishSubject<ReusableCollectionViewCellViewModelType>()
    
    init(repository : AccountRepository) {
        self.repository = repository
//        self.cellViewModels = [FAQMenuItemCollectionViewCellViewModel(title: "Awais", isSelected: false), FAQMenuItemCollectionViewCellViewModel(title: "Iqbal", isSelected: true)]
//        dataSourceSubject.onNext([SectionModel(model: 0, items: cellViewModels)])
        
        itemTappedSubject.subscribe(onNext: { viewModel in
            print(viewModel)
            guard let selectedModel = viewModel as? FAQMenuItemCollectionViewCellViewModel else {return}
            self.getClickedCell(model: selectedModel)
            
        }).disposed(by: disposeBag)
        
        
        
        getFAQs()
    }
    
    func getClickedCell(model: FAQMenuItemCollectionViewCellViewModel) {
        
        var title = ""
        model.titleSubject.subscribe(onNext: {
            title = $0 ?? ""
        }).disposed(by: disposeBag)
        
        self.cellViewModels.removeAll()
        for faqTitle in self.faqsTitles {
            var isSelected = false
            if faqTitle == title { isSelected = true }
            self.cellViewModels.append(FAQMenuItemCollectionViewCellViewModel(title: faqTitle, isSelected: isSelected))
        }
        self.showQuestions(categoryName: title)
        self.dataSourceSubject.onNext([SectionModel(model: 0, items: self.cellViewModels)])
    }
    
    private func showQuestions(categoryName : String) {
        var selectedQuestions = self.allFaqs
        selectedQuestions.removeAll { faq in
            if faq.title == categoryName { return false }
            else { return true }
        }
        
        var tableViewCells: [ReusableTableViewCellViewModelType] = [FAQsTableViewCellViewModel]()
        
        for question in selectedQuestions {
            tableViewCells.append(FAQsTableViewCellViewModel(faq: question))
        }
        
        //[FAQsTableViewCellViewModel(faq: FAQsResponse(title: "ABC", question: "Question1", answer: "Answer")), FAQsTableViewCellViewModel(faq: FAQsResponse(title: "ABC", question: "Question2", answer: "Answer")),FAQsTableViewCellViewModel(faq: FAQsResponse(title: "ABC", question: "Question3", answer: "Answer"))]
        self.tableViewDataSourceSubject.onNext([SectionModel(model: 0, items: tableViewCells)])
    }
    
    private func getFAQs() {
        YAPProgressHud.showProgressHud()
        let faqRequest = repository.fetchFAQs()
        faqRequest.elements().subscribe(onNext: { [unowned self] elemets in
            print(elemets)
            YAPProgressHud.hideProgressHud()
            self.allFaqs.removeAll()
            self.allFaqs = elemets
            
            var distinctFAQsTitles = [String]()
            for faq in self.allFaqs {
                if !distinctFAQsTitles.contains(faq.title) {
                    distinctFAQsTitles.append(faq.title)
                    self.faqsTitles.append(faq.title)
                }
            }
            
            var index = 0
            for faqTitle in distinctFAQsTitles {
                var isSelected = false
                if index == 0 { isSelected = true   }
                self.cellViewModels.append(FAQMenuItemCollectionViewCellViewModel(title: faqTitle, isSelected: isSelected))
                index = index + 1
            }
            
            self.showQuestions(categoryName: self.allFaqs.first?.title ?? "")
            self.dataSourceSubject.onNext([SectionModel(model: 0, items: self.cellViewModels)])
        }).disposed(by: disposeBag)
        faqRequest.errors().subscribe(onNext: { errorr in
            print(errorr)
            YAPProgressHud.hideProgressHud()
        }).disposed(by: disposeBag)
    }
}
