//
//  CardsViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import Foundation
import YAPComponents
import RxSwift

typealias DeliveryStatus = PaymentCard.DeliveryStatus

extension PaymentCard.DeliveryStatus {
    var message: String {
        switch self {
        case .ordered: return "Your card is ordered"
        case .shipped: return "Your primary card is shipped"
        case .delivered: return "Create a PIN to start using your card"
        default: return "Complete verification to get your card"
//        case .ordering: return "Complete verification to get your card"
//        case .ordered: return "This card is on the way"
//        case .shipping, .booked: return "Your primary card is on its way"
//        case .shipped: return "Create a PIN to start using your card"
        }
    }
}

protocol CardsViewModelInputs {
    var viewDidAppear: AnyObserver<Void> { get }
    var eyeInfoObserver: AnyObserver<Void> { get }
    var detailsObservers: AnyObserver<Void> { get }
    var unfreezObserver: AnyObserver<Void> { get }
    var orderNewObserver: AnyObserver<Void> { get }
}

protocol CardsViewModelOutputs {
    // typealias CardResult = (cardSerial: String?, deliveryStatus: DeliveryStatus)
    var eyeInfo: Observable<PaymentCard> { get }
    // var deliveryDetails: Observable<PaymentCard?> { get }
    var cardDetails: Observable<PaymentCard?> { get }
    var loader: Observable<Bool> { get }
    var error: Observable<String> { get }
    var hideLetsDoIt: Observable<Bool> { get }
    var isForSetPinFlow: Observable<Bool> { get }
    var localizedStrings: Observable<CardsViewModel.LocalizedStrings> { get }
    var isUserBlocked: Observable<Bool> { get }
    var isCardBLocked: Observable<Bool> { get }
    var orderNew: Observable<PaymentCard?> { get }
}

protocol CardsViewModelType {
    var inputs: CardsViewModelInputs { get }
    var outputs: CardsViewModelOutputs { get }
}

class CardsViewModel: CardsViewModelType,
                      CardsViewModelInputs,
                      CardsViewModelOutputs {

    var inputs: CardsViewModelInputs { self }
    var outputs: CardsViewModelOutputs { self }

    // MARK: Inputs
    var eyeInfoObserver: AnyObserver<Void> { eyeInfoDidTapSubject.asObserver() }
    var detailsObservers: AnyObserver<Void> { detailsDidTapSubject.asObserver() }
    var viewDidAppear: AnyObserver<Void> { viewDidAppearSubject.asObserver() }
    var unfreezObserver: AnyObserver<Void> { unfreezSubject.asObserver() }
    var orderNewObserver: AnyObserver<Void> { orderNewSubject.asObserver() }

    // MARK: Outputs
    var eyeInfo: Observable<PaymentCard> {
        eyeInfoDidTapSubject.withLatestFrom(cardDetailsSubject).unwrap().asObservable()
    }
    var cardDetails: Observable<PaymentCard?> { detailsDidTapSubject.withLatestFrom(cardDetailsSubject).asObservable() }
    var loader: Observable<Bool> { loaderSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var hideLetsDoIt: Observable<Bool> { hideLetsDoItSubject.asObservable() }
    var localizedStrings: Observable<LocalizedStrings> { localizedStringsSubject.asObservable() }
    var isForSetPinFlow: Observable<Bool> { setPinSubject.asObservable() }
    var isUserBlocked: Observable<Bool> { isUserBlockedSubject.asObservable() }

    var orderNew: Observable<PaymentCard?> { orderNewSubject.withLatestFrom(cardDetailsSubject).asObservable() }
    var isCardBLocked: Observable<Bool> { isCardBLockedSubject.asObservable() }

    // MARK: Subjects
    var unfreezSubject = PublishSubject<Void>()
    var eyeInfoDidTapSubject = PublishSubject<Void>()
    var detailsDidTapSubject = PublishSubject<Void>()
    var viewDidAppearSubject = PublishSubject<Void>()

    var cardDetailsSubject = BehaviorSubject<PaymentCard?>(value: nil)

    var loaderSubject = BehaviorSubject(value: false)
    var errorSubject = PublishSubject<String>()
    var hideLetsDoItSubject = BehaviorSubject(value: true)
    var setPinSubject = BehaviorSubject(value: false)
    var localizedStringsSubject = PublishSubject<LocalizedStrings>()
    var isUserBlockedSubject = PublishSubject<Bool>()
    var isCardBLockedSubject = BehaviorSubject<Bool>(value: false)
    var orderNewSubject = PublishSubject<Void>()

    // MARK: - Properties
    private var accountProvider: AccountProvider!
    private var cardsRepository: CardsRepositoryType!
    // fileprivate var deliveryStatus: DeliveryStatus!
    // fileprivate var cardSerial: String!
    // fileprivate var isPinSetValue: Bool = false

    let disposeBag = DisposeBag()

    // MARK: - Init
    init(accountProvider: AccountProvider, cardsRepository: CardsRepositoryType) {
        self.accountProvider = accountProvider
        self.cardsRepository = cardsRepository

        let completionStatus = self.isProfileCompleted()
        self.resolveIfIncompleted(completionStatus)
        self.resolveIfCompleted(completionStatus)

        let unfreez = unfreezSubject.withLatestFrom(cardDetailsSubject).withUnretained(self)
            .do(onNext: { `self`, _ in self.loaderSubject.onNext(true) })
            .flatMap {`self`, card  in
                self.cardsRepository.configFreezeUnfreezeCard(cardSerialNumber: card?.cardSerialNumber ?? "")
            }
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
            .share()

        unfreez.elements().withLatestFrom(cardDetailsSubject).map { card -> PaymentCard? in
            var cardOut = card
            if let blocked = card?.blocked {
                cardOut?.blocked = !blocked
            }
            return cardOut
        }.bind(to: cardDetailsSubject)
        .disposed(by: disposeBag)

        unfreez.errors().map({ $0.localizedDescription }).bind(to: errorSubject).disposed(by: disposeBag)
    }

    func isProfileCompleted() -> Observable<Bool> {
        return viewDidAppearSubject.withLatestFrom(accountProvider.currentAccount)
            .map {
                ($0?.accountStatus?.stepValue ?? 0) >= AccountStatus.addressCaptured.stepValue && $0?.isSecretQuestionVerified == true }
            .share()
    }

    func resolveIfIncompleted(_ completionStatus: Observable<Bool>) {
        completionStatus.filter{ !$0 }.map{ _ in DeliveryStatus.ordered }.withUnretained(self)
            // .do(onNext: { $0.0.deliveryStatus = $0.1 })
            .map { $0.0.makeLocalizableStrings(PaymentCard.mock) }
            .bind(to: localizedStringsSubject)
            .disposed(by: disposeBag)
    }

    func resolveIfCompleted(_ completionStatus: Observable<Bool>) {
        let cardsFetched = completionStatus.filter{ $0 }.withUnretained(self)
            .do(onNext: { `self`, _ in self.loaderSubject.onNext(true) })
                .flatMap { $0.0.cardsRepository.getCards() }
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
            .share()

        let cardElements = cardsFetched.elements().map({ $0?.first }).share()
        cardElements.bind(to: cardDetailsSubject).disposed(by: disposeBag)

        cardDetailsSubject.map({ $0?.blocked }).unwrap()
            .bind(to: isUserBlockedSubject).disposed(by: disposeBag)

        cardDetailsSubject
            .map { obj -> PaymentCard in
                guard let paymentObj = obj else { return PaymentCard.mock }
                return paymentObj
            }.withUnretained(self)
            .map{ `self`, cardObj in
                self.makeLocalizableStrings(cardObj)
            }
            .bind(to: localizedStringsSubject)
            .disposed(by: disposeBag)

        cardDetailsSubject
            .map { $0?.status == .hotlisted || $0?.status == .expired }
            .bind(to: isCardBLockedSubject).disposed(by: disposeBag)

        cardDetailsSubject.map { $0?.pinCreated == true }
            .bind(to: setPinSubject).disposed(by: disposeBag)
//      detailsResultSubject.subscribe {
//      print($0)
//      }.disposed(by: disposeBag)

        cardsFetched.errors().map({ $0.localizedDescription }).bind(to: errorSubject).disposed(by: disposeBag)
    }
}

// MARK: - Helpers
extension CardsViewModel {
    struct LocalizedStrings {
        var titleView: String = ""
        var titleCard: String = ""
        var subTitle: String = ""
        var seeDetail: String = ""
        var count: String = ""
    }
    
    fileprivate func makeLocalizableStrings(_ paymentCard: PaymentCard) -> LocalizedStrings {
        
        return LocalizedStrings(titleView: "Your cards",
                                titleCard: paymentCard.cardName ?? "",
                                subTitle: (paymentCard.deliveryStatus ?? .ordered).rawValue,
                                seeDetail: "See details",
                                count: "1 of 1")
    }
}
