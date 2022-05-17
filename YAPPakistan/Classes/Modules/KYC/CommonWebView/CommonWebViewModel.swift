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
import RxCocoa

protocol CommonWebViewModelInput {
    var confirmObserver: AnyObserver<CommonWebViewM> { get }
    var closeObserver: AnyObserver<Void> { get }
    var navigationActionObserver: AnyObserver<WKNavigationAction>{ get }
    var completionObserver: AnyObserver<Void> { get }
    var alertTopupObserver: AnyObserver<ExternalPaymentCard> { get }
    var alertTopupDashboardObserver: AnyObserver<Void> { get }
}

protocol CommonWebViewModelOutput {
    var close: Observable<Void> { get }
    var confirm: Observable<CommonWebViewM> { get }
    var error: Observable<String> { get }
    var navigationAction: Observable<WKNavigationAction> { get }
    var complete: Observable<Void> { get }
    var html: Observable<String> { get }
    var webUrl: Observable<String> { get }
    var cardAddedAlert: Observable<ExternalPaymentCard> { get }
    var showTopup: Observable<ExternalPaymentCard> { get }
    var showTopupDashboard: Observable<Void> { get }
}

protocol CommonWebViewModelType {
    var inputs: CommonWebViewModelInput { get }
    var outputs: CommonWebViewModelOutput { get }
}

class CommonWebViewModel:CommonWebViewModelInput, CommonWebViewModelOutput, CommonWebViewModelType {
    
    private let confirmSubject = ReplaySubject<CommonWebViewM>.create(bufferSize: 1)
    private let closeSubject = PublishSubject<Void>()
    private let showCardAddedAlertSubject = PublishSubject<ExternalPaymentCard>()
    private let navigationActionSubject = ReplaySubject<WKNavigationAction>.create(bufferSize: 1)
    private let fetchExternalBeneficiarySubject = PublishSubject<Void>()
    private let errorSubject = PublishSubject<String>()
    private let completionSubject = PublishSubject<Void>()
    private let htmlSubject = BehaviorSubject<String>(value: "")
    private let webUrlSubject = BehaviorSubject<String>(value: "")
    private var alertTopupSubject = PublishSubject<ExternalPaymentCard>()
    private var alertTopupDashboardSubject = PublishSubject<Void>()
    private var showTopupFlowSubject = PublishSubject<ExternalPaymentCard>()
    private var showTopupDashboardFlowSubject = PublishSubject<Void>()
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let repository: CardsRepositoryType!
    private let webType: CommonWebType
    
    //MARK: Inputs
    var confirmObserver: AnyObserver<CommonWebViewM> { confirmSubject.asObserver() }
    var closeObserver: AnyObserver<Void> { closeSubject.asObserver() }
    var navigationActionObserver: AnyObserver<WKNavigationAction>{ navigationActionSubject.asObserver() }
    var completionObserver: AnyObserver<Void> { completionSubject.asObserver() }
    var alertTopupObserver: AnyObserver<ExternalPaymentCard> { alertTopupSubject.asObserver() }
    var alertTopupDashboardObserver: AnyObserver<Void> { alertTopupDashboardSubject.asObserver() }
    
    //MARK: Outputs
    var close: Observable<Void> { closeSubject.asObservable() }
    var confirm: Observable<CommonWebViewM> { confirmSubject.asObservable() }
    var navigationAction: Observable<WKNavigationAction> { navigationActionSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var complete: Observable<Void> { completionSubject.asObservable() }
    var html: Observable<String> { return htmlSubject.asObservable() }
    var webUrl: Observable<String> { return webUrlSubject.asObservable() }
    var cardAddedAlert: Observable<ExternalPaymentCard> { return showCardAddedAlertSubject.asObservable() }
    var showTopup: Observable<ExternalPaymentCard> { showTopupFlowSubject.asObservable() }
    var showTopupDashboard: Observable<Void> { showTopupDashboardFlowSubject.asObservable() }
    
    var inputs: CommonWebViewModelInput { return self }
    var outputs: CommonWebViewModelOutput { return self }
    
    init(commonWebType: CommonWebType, repository: CardsRepositoryType, html: String) {
        self.repository = repository
        self.webType = commonWebType
        if html.hasPrefix("https://pk") {
            self.webUrlSubject.onNext(html)
        } else {
            self.htmlSubject.onNext(html)
        }
        
        navigationActionSubject.subscribe(onNext: { [weak self] navigationAction in
            guard let `self` = self else { return }
            if let url = navigationAction.request.url {
                if let model: CommonWebViewM = self.getParams(url: navigationAction.request.url!) {
                    if url.absoluteString.contains("yap-app://load") {
                        self.processModel(model: model)
                        self.fetchExternalBeneficiarySubject.onNext(())
                    }
                } else if url.absoluteString.contains("transactions") {
                    self.completionSubject.onNext(())
                }
            }
        }).disposed(by: disposeBag)
        
        //Bind the alert actions
        alertTopupSubject.bind(to: showTopupFlowSubject).disposed(by: disposeBag)
        alertTopupDashboardSubject.bind(to: showTopupDashboardFlowSubject).disposed(by: disposeBag)
        
    }
    
    private func processModel(model: CommonWebViewM) {
        
        if let error = model.errors, error.length > 0 {
            errorSubject.onNext(error)
            return
        }
        
        if let saveCard = model.saveCardDetails, saveCard == true || self.webType == .topUpAddCardWeb {
            
            let cardsRequest = fetchExternalBeneficiarySubject
                .do(onNext: { _ in YAPProgressHud.showProgressHud() })
                    .flatMap{ [weak self] () -> Observable<Event<ExternalPaymentCard?>> in
                        if self?.webType == .onBoardingAddCardWeb {
                            return (self?.repository.addOnboardingExternalCardBeneficiary(alias: model.nickName ?? "", color: model.color ?? "", sessionId: model.sessionID ?? "", cardNumber: model.cardNumber ?? ""))!
                        } else {
                            return (self?.repository.addTopupExternalCardBeneficiary(alias: model.nickName ?? "", color: model.color ?? "", sessionId: model.sessionID ?? "", cardNumber: model.cardNumber ?? ""))!
                        }
                    }
                    .share()
            
            cardsRequest.subscribe(onNext: { _ in
                YAPProgressHud.hideProgressHud()
            }).disposed(by: disposeBag)
            
            cardsRequest.elements().withUnretained(self)
                .subscribe(onNext:{ `self` ,paymentCardObj in
                    if self.webType == .onBoardingOTPWeb {
                        self.confirmSubject.onNext(model)
                    } else if self.webType == .topUpAddCardWeb {
                        guard let paymentCard = paymentCardObj else { return }
                        self.showCardAddedAlertSubject.onNext(paymentCard)
                    } else if self.webType == .onBoardingAddCardWeb {
                        self.confirmSubject.onNext(model)
                    }
                })
                .disposed(by: disposeBag)
            
            cardsRequest.errors()
                .subscribe(onNext:{ [weak self] error in
                    self?.errorSubject.onNext(error.localizedDescription)
                })
                .disposed(by: disposeBag)
        } else {
            self.confirmSubject.onNext(model)
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
