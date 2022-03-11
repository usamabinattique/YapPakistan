//
//  YAPAlertViewModel.swift
//  YAPKit
//
//  Created by Zain on 04/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

protocol YAPAlertViewModelInput {
    var primaryActionObserver: AnyObserver<Void> { get }
    var cancelActionObserver: AnyObserver<Void> { get }
    var urlObserver: AnyObserver<String> { get }
    var closeObserver: AnyObserver<Void> { get }
    var showCloseObserver: AnyObserver<Bool> { get }
}

protocol YAPAlertViewModelOutput {
    var icon: Observable<UIImage?> { get }
    var text: Observable<NSAttributedString?> { get }
    var primaryButtonTitle: Observable<String?> { get }
    var cancelButtonTitle: Observable<String?> { get }
    
    var primaryAction: Observable<Void> { get }
    var cancelAction: Observable<Void> { get }
    var close: Observable<Void> { get }
    var urlSelected: Observable<String> { get }
    var showsCloseButton: Observable<Bool> { get }
}

protocol YAPAlertViewModelType {
    var inputs: YAPAlertViewModelInput { get }
    var outputs: YAPAlertViewModelOutput { get }
}

class YAPAlertViewModel: YAPAlertViewModelType, YAPAlertViewModelInput, YAPAlertViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: YAPAlertViewModelInput { return self }
    var outputs: YAPAlertViewModelOutput { return self }
    
    private let iconSubject = BehaviorSubject<UIImage?>(value: nil)
    private let textSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    private let primaryButtonTitleSubject = BehaviorSubject<String?>(value: nil)
    private let cancelButtonTitleSubject = BehaviorSubject<String?>(value: nil)
    private let closeSubject = PublishSubject<Void>()
    private let primaryActionObserverSubject = PublishSubject<Void>()
    private let primaryActionSubject = PublishSubject<Void>()
    private let cancelActionObserverSubject = PublishSubject<Void>()
    private let cancelActionSubject = PublishSubject<Void>()
    private let urlObserverSubject = PublishSubject<String>()
    private let urlSubject = PublishSubject<String>()
    private let showsCloseButtonSubject: BehaviorSubject<Bool>
    
    // MARK: - Inputs
    var primaryActionObserver: AnyObserver<Void> { return primaryActionObserverSubject.asObserver() }
    var cancelActionObserver: AnyObserver<Void> { return cancelActionObserverSubject.asObserver() }
    var urlObserver: AnyObserver<String> { return urlObserverSubject.asObserver() }
    var closeObserver: AnyObserver<Void> { closeSubject.asObserver() }
    var showCloseObserver: AnyObserver<Bool> { showsCloseButtonSubject.asObserver() }
    
    // MARK: - Outputs
    var icon: Observable<UIImage?> { return iconSubject.asObservable() }
    var text: Observable<NSAttributedString?> { return textSubject.asObservable() }
    var primaryButtonTitle: Observable<String?> { return primaryButtonTitleSubject.asObservable() }
    var cancelButtonTitle: Observable<String?> { return cancelButtonTitleSubject.asObservable() }
    var close: Observable<Void> { closeSubject.asObservable() }
    var primaryAction: Observable<Void> { return primaryActionSubject.asObservable() }
    var cancelAction: Observable<Void> { return cancelActionSubject.asObservable() }
    var urlSelected: Observable<String> { return urlSubject.asObservable() }
    var showsCloseButton: Observable<Bool> { showsCloseButtonSubject.asObservable() }
    
    weak var delegate: YAPAlertViewModelDelegete?
    
    // MARK: - Init
    init(icon: UIImage?, text: NSAttributedString?, primaryActionTitle: String?, cancelTitle: String?, showsCloseButton: Bool = false) {
        showsCloseButtonSubject = BehaviorSubject(value: showsCloseButton)
        iconSubject.onNext(icon)
        textSubject.onNext(text)
        primaryButtonTitleSubject.onNext(primaryActionTitle)
        cancelButtonTitleSubject.onNext(cancelTitle)
        
        primaryActionObserverSubject.subscribe(onNext: { [unowned self] in
            self.delegate?.yapAlertViewModelDidTapOnPrimaryButton(self)
            self.primaryActionSubject.onNext(())
            self.disposeAll()
        }).disposed(by: disposeBag)
        
        cancelActionObserverSubject.subscribe(onNext: { [unowned self] in
            self.delegate?.yapAlertViewModelDidTapOnCancelButton(self)
            self.cancelActionSubject.onNext(())
            self.disposeAll()
        }).disposed(by: disposeBag)
        
        urlObserverSubject.subscribe(onNext: { [unowned self] in
            self.delegate?.yapAlertViewModel(self, didTapOnLink: $0)
            self.urlSubject.onNext($0)
            self.disposeAll()
        }).disposed(by: disposeBag)
    }
    
    private func disposeAll() {
        primaryActionSubject.onCompleted()
        cancelActionSubject.onCompleted()
        urlSubject.onCompleted()
    }
}

protocol YAPAlertViewModelDelegete: NSObject {
    func yapAlertViewModelDidTapOnPrimaryButton(_ yapAlertViewModel: YAPAlertViewModel)
    func yapAlertViewModelDidTapOnCancelButton(_ yapAlertViewModel: YAPAlertViewModel)
    func yapAlertViewModel(_ yapAlertViewModel: YAPAlertViewModel, didTapOnLink link: String)
}
