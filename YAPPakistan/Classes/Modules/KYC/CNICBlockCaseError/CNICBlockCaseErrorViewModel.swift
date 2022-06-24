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
    var actionButtonObserver: AnyObserver<Void> { get }
    var gotoDashboardObserver: AnyObserver<Void> { get }
}

protocol CNICBlockCaseErrorViewModelOutputs {
    var actionButton: Observable<CNICBlockCase?> { get }
    var blockCaseActionsState: Observable<CNICBlockCase> { get }
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
    var actionButtonObserver: AnyObserver<Void> { actionButtonSubject.asObserver() }
    var gotoDashboardObserver: AnyObserver<Void> { return gotoDashboardSubject.asObserver() }

    // MARK: Outputs
    var actionButton: Observable<CNICBlockCase?> { actionButtonOutputSubject.asObservable() }
    var gotoDashboard: Observable<Void> { return gotoDashboardSubject.asObservable() }
    var errorTitle : Observable<String> { return errorTitleSubject.asObservable() }
    var errorDescription: Observable<String> { return errorDescriptionSubject.asObservable() }
    var blockCaseActionsState: Observable<CNICBlockCase> { return setActionStateSubject.asObservable() }
    
    // MARK: Subjects
    private var languageStringsSubject: BehaviorSubject<LanguageStrings>!
    private var actionButtonSubject = PublishSubject<Void>()
    private var actionButtonOutputSubject = BehaviorSubject<CNICBlockCase?>(value: nil)
    private var gotoDashboardSubject = PublishSubject<Void>()
    private var errorTitleSubject = BehaviorSubject<String>(value: "")
    private var errorDescriptionSubject = BehaviorSubject<String>(value: "")
    private var setActionStateSubject = BehaviorSubject<CNICBlockCase>(value: .cnicAlreadyUsed)
    
    private var cnicBlockCase : CNICBlockCase!
    private let disposeBag = DisposeBag()

    init(cnicBlockCase : CNICBlockCase) {
        self.cnicBlockCase = cnicBlockCase
        
        self.errorTitleSubject.onNext(self.cnicBlockCase.errorTitle)
        self.errorDescriptionSubject.onNext(self.cnicBlockCase.errorDescription)
        
        self.setActionStateSubject.onNext(self.cnicBlockCase)
        
        self.actionButtonSubject.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.actionButtonOutputSubject.onNext(self.cnicBlockCase)
        }).disposed(by: disposeBag)
    }

    struct LanguageStrings {
        let title: String
        let subTitle: String
        let cinc: String
        let goToDashboard: String
    }
}
