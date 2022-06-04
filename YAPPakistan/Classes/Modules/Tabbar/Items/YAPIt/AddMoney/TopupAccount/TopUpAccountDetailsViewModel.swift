//
//  TopUpAccountDetailsViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 29/03/2022.
//

import Foundation
import YAPComponents
import RxSwift
import RxDataSources

protocol TopUpAccountDetailsViewModelInput {
    var shareObserver: AnyObserver<String> { get }
    var closeObserver: AnyObserver<Void> { get }
}

protocol TopUpAccountDetailsViewModelOutput {
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var shareInfo: Observable<String> { get }
    var close: Observable<Void> { get }
}

protocol TopUpAccountDetailsViewModelType {
    var inputs: TopUpAccountDetailsViewModelInput { get }
    var outputs: TopUpAccountDetailsViewModelOutput { get }
}

class TopUpAccountDetailsViewModel: TopUpAccountDetailsViewModelType, TopUpAccountDetailsViewModelInput, TopUpAccountDetailsViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: TopUpAccountDetailsViewModelInput { return self }
    var outputs: TopUpAccountDetailsViewModelOutput { return self }
    
    var accountProvider: AccountProvider!
    
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let shareSubject = PublishSubject<String>()
    private let closeSubject = PublishSubject<Void>()
    
    // MARK: - Inputs
    var shareObserver: AnyObserver<String> { shareSubject.asObserver() }
    var closeObserver: AnyObserver<Void> { closeSubject.asObserver() }
    
    // MARK: - Outputs
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { dataSourceSubject.asObservable() }
    var shareInfo: Observable<String> {
        
        shareSubject.withLatestFrom(self.accountProvider.currentAccount.unwrap()).map({
            String.init(format: "Account title: %@\nIBAN: %@\nAccount number: %@", $0.customer.fullName ?? "", $0.formattedIBAN ?? "", $0.accountNumber ?? "")
        })
    }
    var close: Observable<Void> { closeSubject.asObservable() }
    
    // MARK: - Init
    init(accountProvider: AccountProvider) {
        
        self.accountProvider = accountProvider
        
        let account = self.accountProvider.currentAccount
        account.map{ account -> [ReusableTableViewCellViewModelType] in
            [TopUpAccountDetailsUserCellViewModel(userImage: (account?.customer.imageURL?.absoluteString, (account?.customer.fullName ?? "").initialsImage(color: UIColor(hexString: "5E35B1") ?? .purple/*primary*/))),
             TopUpAccountDetailsCellViewModel(type: .accountName, details: account?.customer.fullName ?? ""),
             TopUpAccountDetailsCellViewModel(type: .iban, details: account?.iban ?? ""),
             TopUpAccountDetailsCellViewModel(type: .accountNumber, details: account?.accountNumber ?? "")] }
        .map{ [SectionModel(model: 0, items: $0)] }
        .bind(to: dataSourceSubject)
        .disposed(by: disposeBag)
        
    }
}

