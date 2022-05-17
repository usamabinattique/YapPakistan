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
    
    // MARK: Outputs
    var dataSource: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    
    // MARK: Inputs
    var itemTappedObserver: AnyObserver<ReusableCollectionViewCellViewModelType> { return itemTappedSubject.asObserver() }
    
    // MARK: Subjects
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>(value: [])
    private let itemTappedSubject = PublishSubject<ReusableCollectionViewCellViewModelType>()
    
    init(repository : AccountRepository) {
        self.repository = repository
//        self.cellViewModels = [FAQMenuItemCollectionViewCellViewModel(title: "Awais", isSelected: false), FAQMenuItemCollectionViewCellViewModel(title: "Iqbal", isSelected: true)]
//        dataSourceSubject.onNext([SectionModel(model: 0, items: cellViewModels)])
        
        itemTappedSubject.subscribe(onNext: { viewModel in
            print(viewModel)
        }).disposed(by: disposeBag)
        
        getFAQs()
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
                }
            }
            
            for faqTitle in distinctFAQsTitles {
                self.cellViewModels.append(FAQMenuItemCollectionViewCellViewModel(title: faqTitle, isSelected: false))
            }
            
            self.dataSourceSubject.onNext([SectionModel(model: 0, items: self.cellViewModels)])
            
        }).disposed(by: disposeBag)
        faqRequest.errors().subscribe(onNext: { errorr in
            print(errorr)
            YAPProgressHud.hideProgressHud()
        }).disposed(by: disposeBag)
    }
}
