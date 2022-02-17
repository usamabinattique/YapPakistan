//
//  CommonWebViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 14/02/2022.
//

import Foundation
import WebKit
import YAPComponents
import YAPCore
import RxSwift

protocol CommonWebViewModelInput {
    var confirmObserver: AnyObserver<Void> { get }
    var closeObserver: AnyObserver<Void> { get }
    var navigationActionObserver: AnyObserver<WKNavigationAction>{ get }
}

protocol CommonWebViewModelOutput {
    var close: Observable<Void> { get }
    var confirm: Observable<Void> { get }
    var navigationAction: Observable<WKNavigationAction> { get }
}

protocol CommonWebViewModelType {
    var inputs: CommonWebViewModelInput { get }
    var outputs: CommonWebViewModelOutput { get }
}

class CommonWebViewModel:CommonWebViewModelInput, CommonWebViewModelOutput, CommonWebViewModelType {
    
    private let confirmSubject = PublishSubject<Void>()
    private let closeSubject = PublishSubject<Void>()
    private let navigationActionSubject = ReplaySubject<WKNavigationAction>.create(bufferSize: 1)
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    //MARK: Inputs
    var confirmObserver: AnyObserver<Void> { confirmSubject.asObserver() }
    var closeObserver: AnyObserver<Void> { closeSubject.asObserver() }
    var navigationActionObserver: AnyObserver<WKNavigationAction>{ navigationActionSubject.asObserver() }
    
    //MARK: Outputs
    var close: Observable<Void> { closeSubject.asObservable() }
    var confirm: Observable<Void> { confirmSubject.asObservable() }
    var navigationAction: Observable<WKNavigationAction> { navigationActionSubject.asObservable() }
    
    var inputs: CommonWebViewModelInput { return self }
    var outputs: CommonWebViewModelOutput { return self }
    
    init(container: KYCFeatureContainer) {
        let token = container.session.authorizationHeaders["Authorization"]
        navigationActionSubject.subscribe(onNext: { [weak self] navigationAction in
            guard let `self` = self else { return }
            if let host = navigationAction.request.url?.host {
                if let model: CommonWebViewM = self.getParams(url: navigationAction.request.url!) {
                
                    print(model.nickName!)
                    print(model.dictionary)
                }
                print(host)
                if host.contains("yap.co") {
    //                viewModel.inputs.completeObserver.onNext(())
    //                viewModel.inputs.completeObserver.onCompleted()
                }
            }
        }).disposed(by: disposeBag)

    }
    
    private func getParams(url: URL) -> CommonWebViewM? {
        do {
            if let componenets = url.toQueryItems()?.toDictionary() {
                return try CommonWebViewM(from: componenets)
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}
