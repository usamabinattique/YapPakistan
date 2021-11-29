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
        case .ordering: return "Complete verification to get your card"
        case .ordered: return "This card is on the way"
        case .shipping, .booked: return "Your primary card is on its way"
        case .shipped: return "Your primary card is shipped"
        }
    }
}

protocol CardsViewModelInputs {
    var viewDidAppear: AnyObserver<Void> { get }
    var eyeInfoObserver: AnyObserver<Void> { get }
    var detailsObservers: AnyObserver<Void> { get }
}

protocol CardsViewModelOutputs {
    typealias CardResult = (cardSerial: String?, deliveryStatus: DeliveryStatus)
    var eyeInfo: Observable<Void> { get }
    var details: Observable<CardResult> { get }
    var cardDetails: Observable<CardResult> { get }
    var loader: Observable<Bool> { get }
    var error: Observable<String> { get }
    var hideLetsDoIt: Observable<Bool> { get }
    var isPinSet: Observable<Bool> { get }
    var localizedStrings: Observable<CardsViewModel.LocalizedStrings> { get }
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
    var eyeInfoObserver: AnyObserver<Void> { eyeInfoSubject.asObserver() }
    var detailsObservers: AnyObserver<Void> { detailsSubject.asObserver() }
    var viewDidAppear: AnyObserver<Void> { viewDidAppearSubject.asObserver() }

    // MARK: Outputs
    var eyeInfo: Observable<Void> { eyeInfoSubject.asObserver() }
    var details: Observable<CardResult> { detailsResultSubject.asObservable() }
    var cardDetails: Observable<CardResult> { cardDetailsResultSubject.asObserver() }
    var loader: Observable<Bool> { loaderSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var hideLetsDoIt: Observable<Bool> { hideLetsDoItSubject.asObservable() }
    var isPinSet: Observable<Bool> { isPinSetSubject.asObservable() }
    var localizedStrings: Observable<LocalizedStrings> { localizedStringsSubject.asObservable() }

    // MARK: Subjects
    var eyeInfoSubject = PublishSubject<Void>()
    var viewDidAppearSubject = PublishSubject<Void>()
    var detailsSubject = PublishSubject<Void>()
    var detailsResultSubject = PublishSubject<CardResult>()
    var cardDetailsResultSubject = PublishSubject<CardResult>()
    var loaderSubject = BehaviorSubject(value: false)
    var errorSubject = PublishSubject<String>()
    var hideLetsDoItSubject = BehaviorSubject(value: true)
    var isPinSetSubject = BehaviorSubject(value: false)
    var localizedStringsSubject = PublishSubject<LocalizedStrings>()

    // MARK: - Properties
    private var accountProvider: AccountProvider!
    private var cardsRepository: CardsRepositoryType!
    fileprivate var deliveryStatus: DeliveryStatus!
    fileprivate var cardSerial: String!
    fileprivate var isPinSetValue: Bool = false

    let disposeBag = DisposeBag()

    // MARK: - Init
    init(accountProvider: AccountProvider, cardsRepository: CardsRepositoryType) {
        self.accountProvider = accountProvider
        self.cardsRepository = cardsRepository

        let completionStatus = self.isProfileCompleted()
        self.resolveIfIncompleted(completionStatus)
        self.resolveIfCompleted(completionStatus)
    }

    func isProfileCompleted() -> Observable<Bool> {
        return viewDidAppearSubject.withLatestFrom(accountProvider.currentAccount)
            .map { ($0?.accountStatus?.stepValue ?? 0) >= AccountStatus.addressCaptured.stepValue && $0?.isSecretQuestionVerified == true }
            .share()
    }

    func resolveIfIncompleted(_ completionStatus: Observable<Bool>) {
        completionStatus.filter{ !$0 }.map{ _ in DeliveryStatus.ordering }.withUnretained(self)
            .do(onNext: { $0.0.deliveryStatus = $0.1 })
            .map { $0.0.makeLocalizableStrings($0.1) }
            .bind(to: localizedStringsSubject)
            .disposed(by: disposeBag)
    }

    func resolveIfCompleted(_ completionStatus: Observable<Bool>) {
        let cardsFetched = completionStatus.filter{ $0 }.withUnretained(self)
            .do(onNext: { `self`, _ in self.loaderSubject.onNext(true) })
            .flatMap { $0.0.cardsRepository.getCards() }
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
            .share()

        let cardElements = cardsFetched.elements().share()
        cardElements.map({ $0?.first }).withUnretained(self)
            .do(onNext: {
                $0.0.deliveryStatus = $0.1?.deliveryStatus ?? .ordering
                $0.0.cardSerial = $0.1?.cardSerialNumber
            })
            .map{ $0.1?.deliveryStatus ?? .ordered }.withUnretained(self)
            .map{ `self`, status in self.makeLocalizableStrings(status) }
            .bind(to: localizedStringsSubject)
            .disposed(by: disposeBag)

        detailsSubject.withUnretained(self).filter({ !$0.0.isPinSetValue })
            .map{ `self`, _ in (self.cardSerial, self.deliveryStatus ?? .shipping) }
            .bind(to: detailsResultSubject).disposed(by: disposeBag)

        detailsSubject.withUnretained(self).filter({ $0.0.isPinSetValue })
            .map{ `self`, _ in (self.cardSerial, self.deliveryStatus ?? .shipping) }
            .bind(to: cardDetailsResultSubject).disposed(by: disposeBag)

        cardElements.map { $0?.first?.deliveryStatus != .shipped }
            .bind(to: hideLetsDoItSubject).disposed(by: disposeBag)

        cardElements.map { $0?.first?.pinCreated == true }
            .do(onNext: {[weak self] value in self?.isPinSetValue = value })
            .bind(to: isPinSetSubject).disposed(by: disposeBag)

        //detailsResultSubject.subscribe {
        //    print($0)
        //}.disposed(by: disposeBag)

        cardsFetched.errors()
            .subscribe(onNext: { error in
                print(error)
            })
            .disposed(by: disposeBag)
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

    fileprivate func makeLocalizableStrings(_ status: DeliveryStatus?) -> LocalizedStrings {
        guard let message = status?.message else { return LocalizedStrings() }
        return LocalizedStrings(titleView: "Your cards",
                                titleCard: "Primary Card",
                                subTitle: message,
                                seeDetail: "See details",
                                count: "1 of 1")
    }
}
