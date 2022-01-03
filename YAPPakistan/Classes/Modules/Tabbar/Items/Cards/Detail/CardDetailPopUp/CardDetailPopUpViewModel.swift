//
//  CardDetailPopUpViewModel.swift
//  ios-b2c-pk-components
//
//  Created by Sarmad on 26/11/2021.
//

import Foundation
import RxSwift

protocol CardDetailPopUpViewModelInputs {
    var copyObserver: AnyObserver<Void> { get }
    var closeObserver: AnyObserver<Void> { get }
}

protocol CardDetailPopUpViewModelOutputs {
    typealias ResourcesType = CardDetailPopUpViewModel.ResourcesType
    var copy: Observable<Void> { get }
    var close: Observable<Void> { get }
    var loading: Observable<Bool> { get }
    var resources: Observable<ResourcesType> { get }
}

protocol CardDetailPopUpViewModelType {
    var inputs: CardDetailPopUpViewModelInputs { get }
    var outputs: CardDetailPopUpViewModelOutputs { get }
}

struct CardDetailPopUpViewModel: CardDetailPopUpViewModelType,
                                 CardDetailPopUpViewModelInputs,
                                 CardDetailPopUpViewModelOutputs {
    // Subjects
    var copySubject = PublishSubject<Void>()
    var closeSubject = PublishSubject<Void>()
    var loadingSubject = BehaviorSubject<Bool>(value: false)
    var resourcesSubject: BehaviorSubject<ResourcesType>

    // Inputs
    var copyObserver: AnyObserver<Void> { copySubject.asObserver() }
    var closeObserver: AnyObserver<Void> { closeSubject.asObserver() }

    // Outputs
    var copy: Observable<Void> { copySubject.asObservable() }
    var close: Observable<Void> { closeSubject.asObservable() }
    var resources: Observable<ResourcesType> { resourcesSubject.asObservable() }
    var loading: Observable<Bool> { loadingSubject.asObservable() }

    var inputs: CardDetailPopUpViewModelInputs { self }
    var outputs: CardDetailPopUpViewModelOutputs { self }

    // Properties
    private var repository: CardsRepositoryType
    private var paymentCard: PaymentCard
    private let disposeBag = DisposeBag()

    init(resources: ResourcesType,
         repository: CardsRepositoryType,
         paymentCard: PaymentCard) {
        self.resourcesSubject = BehaviorSubject(value: resources)
        self.repository = repository
        self.paymentCard = paymentCard

        self.loadingSubject.onNext(true)

        let cardDetail = Observable.just(())
            .flatMap { repository.getCardDetail(cardSerialNumber: paymentCard.cardSerialNumber ?? "") }
            .share()

        cardDetail.map({ _ in false }).bind(to: loadingSubject).disposed(by: disposeBag)

        let elements = cardDetail.elements()

        Observable.combineLatest(elements, Observable.just(()).withLatestFrom(resourcesSubject))
            .map { (detail, resources) -> ResourcesType in
                var resource = resources
                resource.numberLabel = detail?.cardToken ?? "-"
                resource.cvvLabel = detail?.cvv2 ?? "-"
                resource.dateLabel = detail?.expiry ?? "-"
                return resource
            }.bind(to: resourcesSubject).disposed(by: disposeBag)

        cardDetail.errors()
            .subscribe(onNext: { error in
                print(error.localizedDescription)
            }).disposed(by: disposeBag)
    }

    struct ResourcesType {
        let cardImage: String
        let closeImage: String
        let titleLabel: String
        let subTitleLabel: String
        let numberTitleLabel: String
        var numberLabel: String
        let dateTitleLabel: String
        var dateLabel: String
        let cvvTitleLabel: String
        var cvvLabel: String
        let copyButtonTitle: String
    }
}
