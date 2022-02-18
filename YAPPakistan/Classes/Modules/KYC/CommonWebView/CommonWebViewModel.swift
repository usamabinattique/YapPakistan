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
    var error: Observable<String> { get }
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
    private let fetchExternalBeneficiarySubject = PublishSubject<Void>()
    private let errorSubject = PublishSubject<String>()
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let repository: CardsRepositoryType!
    
    //MARK: Inputs
    var confirmObserver: AnyObserver<Void> { confirmSubject.asObserver() }
    var closeObserver: AnyObserver<Void> { closeSubject.asObserver() }
    var navigationActionObserver: AnyObserver<WKNavigationAction>{ navigationActionSubject.asObserver() }
    
    //MARK: Outputs
    var close: Observable<Void> { closeSubject.asObservable() }
    var confirm: Observable<Void> { confirmSubject.asObservable() }
    var navigationAction: Observable<WKNavigationAction> { navigationActionSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    
    var inputs: CommonWebViewModelInput { return self }
    var outputs: CommonWebViewModelOutput { return self }
    
    init(container: KYCFeatureContainer, repository: CardsRepositoryType) {
        self.repository = repository
        navigationActionSubject.subscribe(onNext: { [weak self] navigationAction in
            guard let `self` = self else { return }
            if let url = navigationAction.request.url {
                if let model: CommonWebViewM = self.getParams(url: navigationAction.request.url!) {
                    if url.absoluteString.contains("yap-app://load") {
                        self.processModel(model: model)
                        self.fetchExternalBeneficiarySubject.onNext(())
                    }
                }
            }
        }).disposed(by: disposeBag)
    }
    
    private func processModel(model: CommonWebViewM) {
        
        if let error = model.errors, error.length > 0 {
            errorSubject.onNext(error)
            return
        }
        
        if let saveCard = model.saveCardDetails, saveCard == true {
            
            let cardsRequest = fetchExternalBeneficiarySubject
                .do(onNext: { _ in YAPProgressHud.showProgressHud() })
                    .flatMap{ [weak self] () -> Observable<Event<ExternalPaymentCard?>> in
                        return (self?.repository.externalCardBeneficiary(alias: model.nickName ?? "", color: model.color ?? "", sessionId: model.sessionID ?? "", cardNumber: model.cardNumber ?? ""))!
                    }
                    .share()
            
            cardsRequest.subscribe(onNext: { _ in
                YAPProgressHud.hideProgressHud()
            }).disposed(by: disposeBag)
            
            cardsRequest.elements()
                .subscribe(onNext:{ [weak self] paymentCardObj in
                    self?.confirmSubject.onNext(())
                })
                .disposed(by: disposeBag)
            
            cardsRequest.errors()
                .subscribe(onNext:{ [weak self] error in
                    self?.errorSubject.onNext(error.localizedDescription)
                })
                .disposed(by: disposeBag)
        }
    }
    
}

extension CommonWebViewModel {
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
