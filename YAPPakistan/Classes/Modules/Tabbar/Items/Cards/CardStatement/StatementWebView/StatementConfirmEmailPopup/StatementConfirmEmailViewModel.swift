//
//  StatementConfirmEmailViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 08/05/2022.
//

import Foundation
import YAPComponents
import YAPCore
import RxSwift
import RxCocoa

protocol StatementConfirmEmailViewModelInput {
    var editEmailObserver: AnyObserver<Void> { get }
    var sendObserver: AnyObserver<Void> { get }
}

protocol StatementConfirmEmailViewModelOutput {
    var currentEmail: Observable<String> { get }
    var editEmail: Observable<Void> { get }
    var send: Observable<Void> { get }
}

protocol StatementConfirmEmailViewModelType {
    var inputs: StatementConfirmEmailViewModelInput { get }
    var outputs: StatementConfirmEmailViewModelOutput { get }
}

class StatementConfirmEmailViewModel: StatementConfirmEmailViewModelType, StatementConfirmEmailViewModelInput, StatementConfirmEmailViewModelOutput {
    
    //MARK: Subjects
    var currentEmailSubject = BehaviorSubject<String>(value: "")
    var editEmailSubject = PublishSubject<Void>()
    var sendEmailSubject = PublishSubject<Void>()
    var sendSubject = PublishSubject<Void>()
    
    //MARK: Inputs
    var editEmailObserver: AnyObserver<Void> { editEmailSubject.asObserver() }
    var sendObserver: AnyObserver<Void> { sendEmailSubject.asObserver() }
    
    //MARK: Outputs
    var currentEmail: Observable<String> { currentEmailSubject.asObservable() }
    var editEmail: Observable<Void> { editEmailSubject.asObservable() }
    var send: Observable<Void> { sendSubject.asObservable() }
    
    var inputs: StatementConfirmEmailViewModelInput { self }
    var outputs: StatementConfirmEmailViewModelOutput { self }
    
    //MARK: Properties
    let disposeBag = DisposeBag()
    
    
    init(accountProvider: AccountProvider, repository: TransactionsRepositoryType, statementModel: WebContentType) {
        guard let account = accountProvider.currentAccountValue.value else { return }
        print(account.customer.email)
        currentEmailSubject.onNext(account.customer.email)
        
        let emailRequest = sendEmailSubject.do(onNext:{ YAPProgressHud.showProgressHud() })
                .flatMap({ _ -> Observable<Event<String?>> in
                    return repository.emailStatement(request: statementModel as! EmailStatement)
                })
                .share()
        emailRequest.errors()
            .subscribe(onNext:{ error in
                YAPProgressHud.hideProgressHud()
                print(error.localizedDescription)
            }).disposed(by: disposeBag)
        
        emailRequest.elements()
            .subscribe(onNext:{ [weak self] _ in
                YAPProgressHud.hideProgressHud()
                print("statement sent successfully")
                //YAPToast.show("Statement sent successfully, please check your email")
                self?.sendSubject.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
}
