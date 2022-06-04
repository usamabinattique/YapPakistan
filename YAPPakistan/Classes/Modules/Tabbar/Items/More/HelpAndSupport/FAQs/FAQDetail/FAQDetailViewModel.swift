//
//  FAQDetailViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 18/05/2022.
//

import Foundation
import RxSwift
import RxDataSources
import YAPComponents

protocol FAQDetailViewModelInput {
    var backObserver: AnyObserver<Void> { get }
    var searchObserver: AnyObserver<Void> { get }
}

protocol FAQDetailViewModelOutput {
    var title: Observable<String?> { get }
    var question: Observable<String?> { get }
    var answer: Observable<String?> { get }
    var back: Observable<Void> { get }
    var search: Observable<Void> { get }
}

protocol FAQDetailViewModelType {
    var inputs: FAQDetailViewModelInput { get }
    var outputs: FAQDetailViewModelOutput { get }
}

class FAQDetailViewModel: FAQDetailViewModelInput, FAQDetailViewModelOutput, FAQDetailViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: FAQDetailViewModelInput { return self }
    var outputs: FAQDetailViewModelOutput { return self }
    private var faq : FAQsResponse?
    
    // MARK: Outputs
    var title: Observable<String?> { return titleSubject.asObservable() }
    var question: Observable<String?> { return questionSubject.asObservable() }
    var answer: Observable<String?> { return answerSubject.asObservable() }
    var back: Observable<Void> { return backSubject.asObservable() }
    var search: Observable<Void> { return searchSubject.asObservable() }
    
    // MARK: Inputs
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    var searchObserver: AnyObserver<Void> { return searchSubject.asObserver() }
    
    // MARK: Subjects
    private let titleSubject = BehaviorSubject<String?>(value: "") //Beha<String?>()
    private let questionSubject = BehaviorSubject<String?>(value: "")
    private let answerSubject = BehaviorSubject<String?>(value: "")
    private let backSubject = PublishSubject<Void>()
    private let searchSubject = PublishSubject<Void>()
    
    init(faq: FAQsResponse) {
        self.faq = faq
        
        titleSubject.onNext(faq.title)
        questionSubject.onNext(faq.question)
        answerSubject.onNext(faq.answer)
    }
}
