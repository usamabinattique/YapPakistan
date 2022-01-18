//
//  CardDetailViewModel.swift
//  ios-b2c-pk-components
//
//  Created by Sarmad on 26/11/2021.
//

import Foundation
import RxSwift

protocol CardDetailViewModelInputs {
    var backObserver: AnyObserver<Void> { get }
    var detailsObserver: AnyObserver<Void> { get }
    var freezObserver: AnyObserver<Void> { get }
    var limitObserver: AnyObserver<Void> { get }
    var newName: AnyObserver<String> { get }
    var optionsObserver: AnyObserver<Void> { get }
//    var filter: AnyObserver<TransactionFilter?> {get}
}

protocol CardDetailViewModelOutputs {
    var back: Observable<Void> { get }
    var details: Observable<PaymentCard> { get }
    var hidefreezCard: Observable<Bool> { get }
    var limit: Observable<PaymentCard> { get }
    var loader: Observable<Bool> { get }
    var options: Observable<Void> { get }
    var filter: Observable<TransactionFilter?> {get}
}

protocol CardDetailViewModelType {
    var inputs: CardDetailViewModelInputs { get }
    var outputs: CardDetailViewModelOutputs { get }
}

class CardDetailViewModel: CardDetailViewModelType, CardDetailViewModelInputs, CardDetailViewModelOutputs {

    var backSubject = PublishSubject<Void>()
    var detailsSubject = PublishSubject<Void>()
    var freezSubject = PublishSubject<Void>()
    var limitSubject = PublishSubject<Void>()
    var hidefreezCardSubject = BehaviorSubject<Bool>(value: true)
    var loaderSubject = BehaviorSubject<Bool>(value: false)
    var optionsSubject = PublishSubject<Void>()
    var newNameSubject = PublishSubject<String>()
    private let filterSubject = BehaviorSubject<TransactionFilter?>(value: nil)

    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    var detailsObserver: AnyObserver<Void> { detailsSubject.asObserver() }
    var freezObserver: AnyObserver<Void> { freezSubject.asObserver() }
    var limitObserver: AnyObserver<Void> { limitSubject.asObserver() }
    var optionsObserver: AnyObserver<Void> { optionsSubject.asObserver() }
    var newName: AnyObserver<String> { newNameSubject.asObserver() }
    var filterObserver: AnyObserver<TransactionFilter?> { filterSubject.asObserver() }

    var back: Observable<Void> { backSubject.asObservable() }
    var details: Observable<PaymentCard> { detailsSubject.map({ self.paymentCard }).unwrap().asObservable() }
    // var freez: Observable<Void> { freezSubject.asObservable() }
    var hidefreezCard: Observable<Bool> { hidefreezCardSubject.asObservable() }
    var limit: Observable<PaymentCard> { limitSubject.map({ self.paymentCard }).unwrap().asObservable() }
    var options: Observable<Void> { optionsSubject.asObservable() }
    var filter: Observable<TransactionFilter?> {filterSubject.asObservable()}
    var loader: Observable<Bool> { loaderSubject.asObservable() }

    var inputs: CardDetailViewModelInputs { self }
    var outputs: CardDetailViewModelOutputs { self }

    var paymentCard: PaymentCard?
    let repository: CardsRepositoryType
    var disposeBag = DisposeBag()

    init(paymentCard: PaymentCard?, repository: CardsRepositoryType) {
        self.paymentCard = paymentCard
        self.repository = repository
        self.hidefreezCardSubject.onNext(paymentCard?.blocked == false)
        let freez = self.freezSubject.withUnretained(self)
            .do(onNext: { `self`, _ in self.loaderSubject.onNext(true) })
            .flatMap { `self`, _ in
                self.repository.configFreezeUnfreezeCard(cardSerialNumber: paymentCard?.cardSerialNumber ?? "")
            }
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
            .share()

        freez.elements().withUnretained(self)
            .do(onNext: { `self`, _ in
                if let blocked = self.paymentCard?.blocked {
                    self.paymentCard?.blocked = !blocked
                }
            }).map { _ in self.paymentCard?.blocked == false }
            .bind(to: hidefreezCardSubject)
            .disposed(by: disposeBag)

        newNameSubject.withUnretained(self)
            .subscribe(onNext: { `self`, name in
                self.paymentCard?.cardName = name
            })
            .disposed(by: disposeBag)
    }
}
