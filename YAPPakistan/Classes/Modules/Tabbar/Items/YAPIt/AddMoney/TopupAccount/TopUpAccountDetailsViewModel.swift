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
    var shareInfo: Observable<String> { shareSubject.asObservable() }
    var close: Observable<Void> { closeSubject.asObservable() } 
    
    // MARK: - Init
    init(accountProvider: AccountProvider) {
        
        let account = accountProvider.currentAccount
        
        let value = account.unwrap().map {
            String.init(format: "Pay to: %@\nIBAN: %@\nBank name: %@\nBank address: %@\nAccount number: %@\nSWIFT/BIC: %@", $0.customer.fullName ?? "", $0.formattedIBAN ?? "", $0.bank.name, $0.bank.address, $0.accountNumber ?? "", $0.bank.swiftCode) }
        value.bind(to: shareSubject)
            .disposed(by: disposeBag)
        
        let tableViewButtonCellViewModel = TableViewButtonCellViewModel(title: "Share", background: .light)
        tableViewButtonCellViewModel.outputs.button
            .subscribe(onNext:{ [weak self] _ in
                guard let `self` = self else { return }
                let value = account.unwrap().map {
                    String.init(format: "Pay to: %@\nIBAN: %@\nBank name: %@\nBank address: %@\nAccount number: %@\nSWIFT/BIC: %@", $0.customer.fullName ?? "", $0.formattedIBAN ?? "", $0.bank.name, $0.bank.address, $0.accountNumber ?? "", $0.bank.swiftCode) }
                value.bind(to: self.shareSubject).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
        account.map{ account -> [ReusableTableViewCellViewModelType] in
            [TopUpAccountDetailsUserCellViewModel(userImage: (account?.customer.imageURL?.absoluteString, (account?.customer.fullName ?? "").initialsImage(color: UIColor(hexString: "5E35B1") ?? .purple/*primary*/))),
             TopUpAccountDetailsCellViewModel(type: .accountName, details: account?.customer.fullName ?? ""),
             TopUpAccountDetailsCellViewModel(type: .iban, details: account?.iban ?? ""),
             TopUpAccountDetailsCellViewModel(type: .bankName, details: account?.bank.name ?? ""),
             TopUpAccountDetailsCellViewModel(type: .bankAddress, details: account?.bank.address ?? ""),
             TopUpAccountDetailsCellViewModel(type: .accountNumber, details: account?.accountNumber ?? ""),
             TopUpAccountDetailsCellViewModel(type: .swiftCode, details: account?.bank.swiftCode ?? ""),
             tableViewButtonCellViewModel] }
            .map{ [SectionModel(model: 0, items: $0)] }
            .bind(to: dataSourceSubject)
            .disposed(by: disposeBag)
        
    }
}

