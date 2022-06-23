//
//  CNICBlockCaseErrorViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 23/06/2022.
//

import Foundation
import RxSwift
import RxRelay

protocol CNICBlockCaseErrorViewModelInputs {
    var backObserver: AnyObserver<Void> { get }
    var gotoDashboardObserver: AnyObserver<Void> { get }
}

protocol CNICBlockCaseErrorViewModelOutputs {
    var back: Observable<Void> { get }
    var gotoDashboard: Observable<Void> { get }
    var errorTitle : Observable<String> { get }
    var errorDescription: Observable<String> { get }
}

protocol CNICBlockCaseErrorViewModelType {
    var inputs: CNICBlockCaseErrorViewModelInputs { get }
    var outputs: CNICBlockCaseErrorViewModelOutputs { get }
}

class CNICBlockCaseErrorViewModel: CNICBlockCaseErrorViewModelType, CNICBlockCaseErrorViewModelInputs, CNICBlockCaseErrorViewModelOutputs {

    var inputs: CNICBlockCaseErrorViewModelInputs { return self }
    var outputs: CNICBlockCaseErrorViewModelOutputs { return self }

    // MARK: Inputs
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    var gotoDashboardObserver: AnyObserver<Void> { return gotoDashboardSubject.asObserver() }

    // MARK: Outputs
    var back: Observable<Void> { backSubject.asObservable() }
    var gotoDashboard: Observable<Void> { return gotoDashboardSubject.asObservable() }
    var errorTitle : Observable<String> { return errorTitleSubject.asObservable() }
    var errorDescription: Observable<String> { return errorDescriptionSubject.asObservable() }
    
    // MARK: Subjects
    private var languageStringsSubject: BehaviorSubject<LanguageStrings>!
    private var backSubject = PublishSubject<Void>()
    private var gotoDashboardSubject = PublishSubject<Void>()
    private var errorTitleSubject = BehaviorSubject<String>(value: "")
    private var errorDescriptionSubject = BehaviorSubject<String>(value: "")
    
    private var cnicBlockCase : CNICBlockCase!

    init(cnicBlockCase : CNICBlockCase) {
        self.cnicBlockCase = cnicBlockCase
        
        self.errorTitleSubject.onNext(self.cnicBlockCase.errorTitle)
        self.errorDescriptionSubject.onNext(self.cnicBlockCase.errorDescription)
    }

    struct LanguageStrings {
        let title: String
        let subTitle: String
        let cinc: String
        let goToDashboard: String
    }
}
