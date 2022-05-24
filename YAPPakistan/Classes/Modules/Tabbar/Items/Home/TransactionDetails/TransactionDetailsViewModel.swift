//
//  TransactionDetailsViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 23/05/2022.
//

import Foundation
import YAPComponents
import YAPCore
import RxSwift
import RxCocoa

protocol TransactionDetailsViewModelInput {
    var fetchDataObserver: AnyObserver<Void> { get }
    var closeObserver: AnyObserver<Void> { get }
}

protocol TransactionDetailsViewModelOutput {
    var error: Observable<String> { get }
    var reload: Observable<Void> { get }
    var close: Observable<Void> { get }
}

protocol TransactionDetailsViewModelType {
    var inputs: TransactionDetailsViewModelInput { get }
    var outputs: TransactionDetailsViewModelOutput { get }
}

class TransactionDetailsViewModel: TransactionDetailsViewModelType, TransactionDetailsViewModelInput, TransactionDetailsViewModelOutput {
    
    //MARK: Subjects
    private var fetchDataSubject = PublishSubject<Void>()
    private let errorSubject = PublishSubject<String>()
    private let reloadSubject = PublishSubject<Void>()
    private let closeSubject = PublishSubject<Void>()
    
    var inputs: TransactionDetailsViewModelInput { self }
    var outputs: TransactionDetailsViewModelOutput { self }
    
    //MARK: Inputs
    var fetchDataObserver: AnyObserver<Void> { fetchDataSubject.asObserver() }
    var closeObserver: AnyObserver<Void> { closeSubject.asObserver() }
    
    //MARK: Outputs
    var error: Observable<String> { errorSubject.asObservable() }
    var reload: Observable<Void> { reloadSubject }
    var close: Observable<Void> { closeSubject.asObservable() }
    
    //MARK: Properties
    private let disposeBag = DisposeBag()
    var viewModels: [ReusableTableViewCellViewModelType] = []
    
    
    init(repository: TransactionsRepositoryType) {
        
        let limitsRequest = fetchDataSubject
            .do(onNext: { YAPProgressHud.showProgressHud() })
            .flatMap { _ -> Observable<Event<[AccountLimits]?>> in
                return repository.getAccountLimits()
            }
            .share()
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
                
        limitsRequest.errors().subscribe(onNext:{ error in
            
        })
        .disposed(by: disposeBag)
                
        limitsRequest.elements()
            .subscribe(onNext:{ [weak self] limits in
                guard let limits = limits else { return }
                for model in limits {
                    print(model)
                    let cellVM = AccountLimitCellViewModel(model)
                    self?.viewModels.append(cellVM)
                }
                self?.reloadSubject.onNext(())
            })
            .disposed(by: disposeBag)
                
    }
}

extension TransactionDetailsViewModel {
    
    public func cellViewModel(for indexPath: IndexPath) -> ReusableTableViewCellViewModelType {
        let viewModel = self.viewModels[indexPath.row]
        return viewModel
    }
    
    public var numberOfRows: Int {
        return self.viewModels.count
    }
}
