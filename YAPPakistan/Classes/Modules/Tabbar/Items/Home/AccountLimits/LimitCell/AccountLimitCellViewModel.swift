//
//  AccountLimitCellViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 12/05/2022.
//

import Foundation
import YAPComponents
import YAPCore
import RxSwift
import RxCocoa

protocol AccountLimitCellViewModelInput {
    
}

protocol AccountLimitCellViewModelOutput {
    var logo: Observable<ImageWithURL> { get }
    var title: Observable<String> { get }
}

protocol AccountLimitCellViewModelType {
    var inputs: AccountLimitCellViewModelInput { get }
    var outputs: AccountLimitCellViewModelOutput { get }
}

class AccountLimitCellViewModel: AccountLimitCellViewModelType, AccountLimitCellViewModelInput, AccountLimitCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    var reusableIdentifier: String  { AccountLimitCell.defaultIdentifier }
    
    // MARK: - Subjects
    fileprivate let logoSubject =  BehaviorSubject<ImageWithURL>(value: (nil, nil))
    fileprivate let titleSubject = BehaviorSubject<String>(value: "")
    
    // Inputs
    

    // Outputs
    var logo: Observable<ImageWithURL> { logoSubject.asObservable() }
    var title: Observable<String> { titleSubject.asObservable() }

    var inputs: AccountLimitCellViewModelInput { self }
    var outputs: AccountLimitCellViewModelOutput { self }

    // Properties
    private let disposeBag = DisposeBag()
    var viewModels: [ReusableTableViewCellViewModelType] = []
    
    init(_ accountLimits: AccountLimits) {
        logoSubject.onNext((accountLimits.logo, accountLimits.title.thumbnail))
        titleSubject.onNext(accountLimits.title)
        for (index,transactions) in accountLimits.transactionLimits.enumerated() {
            let transactionsVM = LimitTransactionCellViewModel(transactions)
            if index == accountLimits.transactionLimits.endIndex-1 {
                transactionsVM.isLastElement = true
            }
            self.viewModels.append(transactionsVM)
        }
    }
}

extension AccountLimitCellViewModel {
    
    public func cellViewModel(for indexPath: IndexPath) -> ReusableTableViewCellViewModelType {
        let viewModel = self.viewModels[indexPath.row]
        return viewModel
    }
    
    public var numberOfRows: Int {
        return self.viewModels.count
    }
}
