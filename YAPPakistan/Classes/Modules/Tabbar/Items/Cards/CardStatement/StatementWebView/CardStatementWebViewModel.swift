//
//  CardStatementWebViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 07/05/2022.
//

import Foundation
import WebKit
import YAPComponents
import YAPCore
import RxSwift
import RxCocoa

protocol CardStatementWebViewModelInput {
    var backObserver: AnyObserver<Void> { get }
    var emailButtonObserver: AnyObserver<Void> { get }
}

protocol CardStatementWebViewModelOutput {
    var back: Observable<Void> { get }
    var error: Observable<String> { get }
    var webUrl: Observable<String> { get }
    var emailButton: Observable<Void> { get }
}

protocol CardStatementWebViewModelType {
    var inputs: CardStatementWebViewModelInput { get }
    var outputs: CardStatementWebViewModelOutput { get }
}

class CardStatementWebViewModel: CardStatementWebViewModelInput, CardStatementWebViewModelOutput, CardStatementWebViewModelType {
    
    private let backSubject = PublishSubject<Void>()
    private let errorSubject = PublishSubject<String>()
    private let webUrlSubject = BehaviorSubject<String>(value: "")
    private let emailButtonSubject = PublishSubject<Void>()
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let repository: StatementsRepositoryType!
    
    //MARK: Inputs
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    var emailButtonObserver: AnyObserver<Void> { emailButtonSubject.asObserver() }
    
    //MARK: Outputs
    var back: Observable<Void> { backSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var webUrl: Observable<String> { return webUrlSubject.asObservable() }
    var emailButton: Observable<Void> { emailButtonSubject.asObservable() }
    
    var inputs: CardStatementWebViewModelInput { return self }
    var outputs: CardStatementWebViewModelOutput { return self }
    
    init(repository: StatementsRepositoryType, url: String) {
        self.repository = repository
        self.webUrlSubject.onNext(url)
        
        
    }
}

