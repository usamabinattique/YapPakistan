//
//  StatementWebViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 29/04/2022.
//

import Foundation
import RxSwift
import RxSwiftExt
import YAPComponents

protocol WebContentType {
    var url : URL? { get }
}

protocol StatementWebViewModelInputs {
    var emailObserver: AnyObserver<Void> { get }
}

protocol StatementWebViewModelOutputs {
    var url: URL? { get }
    var success: Observable<String> { get }
}

protocol StatementWebViewModelType {
    var inputs: StatementWebViewModelInputs { get }
    var outputs: StatementWebViewModelOutputs { get }
}


class StatementWebViewModel: StatementWebViewModelType, StatementWebViewModelInputs, StatementWebViewModelOutputs {
    
    var inputs: StatementWebViewModelInputs { return self }
    var outputs: StatementWebViewModelOutputs { return self }
    
    //MARK: -  Inputs
    var emailObserver: AnyObserver<Void> { return emailSubject.asObserver() }
    
    //MARK: - Outputs
    var url: URL?
    var success: Observable<String> { return successSubject.asObservable() }
    
    //MARK: - Properties
    private var emailSubject = PublishSubject<Void>()
    private var successSubject = PublishSubject<String>()
    
    private var model: WebContentType
    private var repository: TransactionsRepositoryType!
    fileprivate let disposeBag = DisposeBag()
    
    init(model: WebContentType, transactionsRepository: TransactionsRepositoryType) {
        self.model = model
        url = model.url
        self.repository = transactionsRepository
        emailStatement()
    }
    
}

//MARK: - APIs
private extension StatementWebViewModel {
    
    func emailStatement() {
        
        let request = emailSubject
            .do(onNext:{ _ in YAPProgressHud.showProgressHud() })
            .flatMap { [unowned self] _  -> Observable<Event<String?>> in
                return self.repository.emailStatement(request: model as! EmailStatement)
            }.do(onNext: {_ in YAPProgressHud.hideProgressHud() })
            .share()
        
        request.elements().subscribe(onNext: {[unowned self] _ in
            self.successSubject.onNext("A statement copy has been sent to your email.")
        }).disposed(by: disposeBag)
        
    }
    
}

