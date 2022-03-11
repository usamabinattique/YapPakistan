//
//  TopUpCardDetailsViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 03/03/2022.
//

import Foundation
import RxSwift
import YAPComponents
import YAPCore

protocol TopUpCardDetailsViewModelInputs {
    var removeCardTapObserver: AnyObserver<Void> { get }
    var removeCardConfirmTapObserver: AnyObserver<Void> { get }
    var cardRemovedObserver: AnyObserver<Void> { get }
    var closeObserver: AnyObserver<ResultType<Void>> { get }
}

protocol TopUpCardDetailsViewModelOutputs {
    var title: Observable<String> { get }
    var cardImage: Observable<UIImage?> { get }
    var cardNicknamePlaceholder: Observable<String> { get }
    var cardNickname: Observable<String> { get }
    var cardNumberPlaceholder: Observable<String> { get }
    var cardNumber: Observable<String> { get }
    var cardTypePlaceholder: Observable<String> { get }
    var cardType: Observable<String> { get }
    var expiryPlaceholder: Observable<String> { get }
    var expiry: Observable<String> { get }
    var isExpired: Observable<Bool> { get }
    var removeCardTitle: Observable<String> { get }
    var removeCardTap: Observable<Void> { get }
    var removeCardConfirmationMessage: Observable<String> { get }
    var removeCardConfirmationDefaultButtonTitle: Observable<String> { get }
    var removeCardConfirmationSecondaryButtonTitle: Observable<String> { get }
    var close: Observable<ResultType<Void>> { get }
    var cardRemoved: Observable<Void> { get }
    var cardRemovedAlert: Observable<String> { get }
    var error: Observable<Error> { get }
    var isRunning: Observable<Bool> { get }
}

protocol TopUpCardDetailsViewModelType {
    var inputs: TopUpCardDetailsViewModelInputs { get }
    var outputs: TopUpCardDetailsViewModelOutputs { get }
}

class TopUpCardDetailsViewModel: TopUpCardDetailsViewModelType, TopUpCardDetailsViewModelInputs, TopUpCardDetailsViewModelOutputs {

    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: TopUpCardDetailsViewModelInputs { return self }
    var outputs: TopUpCardDetailsViewModelOutputs { return self }

    private let externalPaymentCardSubject: BehaviorSubject<ExternalPaymentCard>!
    private let removeCardTapSubject = PublishSubject<Void>()
    private let removeCardConfirmTapSubject = PublishSubject<Void>()
    private let closeSubject = PublishSubject<ResultType<Void>>()
    private let cardRemovedSubject = PublishSubject<Void>()
    private let errorSubject = PublishSubject<Error>()
    private let isExpiredSubject = BehaviorSubject<Bool>(value: false)

    var externalPaymentCard: Observable<ExternalPaymentCard> { return externalPaymentCardSubject.asObservable() }

    // MARK: - Inputs
    var removeCardTapObserver: AnyObserver<Void> { return removeCardTapSubject.asObserver() }
    var removeCardConfirmTapObserver: AnyObserver<Void> { return removeCardConfirmTapSubject.asObserver() }
    var cardRemovedObserver: AnyObserver<Void> { return cardRemovedSubject.asObserver() }
    var closeObserver: AnyObserver<ResultType<Void>> { return closeSubject.asObserver() }

    // MARK: - Outputs
    var title: Observable<String> { return Observable.of( "screen_topup_card_details_display_text_title".localized) }
    var cardImage: Observable<UIImage?> { return externalPaymentCard.map { $0.cardImage() } }
    var cardNicknamePlaceholder: Observable<String> { return Observable.of( "screen_topup_card_details_display_text_placeholder_card_nickname".localized) }
    var cardNickname: Observable<String> { return externalPaymentCard.map { $0.nickName } }
    var cardNumberPlaceholder: Observable<String> { return Observable.of( "screen_topup_card_details_display_text_placeholder_card_number".localized) }
    var cardNumber: Observable<String> { return externalPaymentCard.map { "*" + $0.last4Digits } }
    var cardTypePlaceholder: Observable<String> { return Observable.of( "screen_topup_card_details_display_text_placeholder_card_type".localized) }
    var cardType: Observable<String> { return externalPaymentCard.map { $0.type.scheme ?? $0.name } }
    var expiryPlaceholder: Observable<String> { return Observable.of( "screen_topup_card_details_display_text_placeholder_expiry".localized) }
    var expiry: Observable<String> {
        return externalPaymentCard.map {
            "\($0.expiry.subString(0, length: 2))/20\($0.expiry.subString(2, length: 4))"
        }
    }
    var isExpired: Observable<Bool> { isExpiredSubject.asObservable() }
    var removeCardTitle: Observable<String> { return Observable.of( "screen_topup_card_details_button_remove_card".localized) }
    var removeCardTap: Observable<Void> { return removeCardTapSubject.asObservable() }
    var removeCardConfirmationMessage: Observable<String> { return removeCardTap.map { _ in  "screen_topup_card_details_display_text_remove_card_confirmation".localized } }
    var removeCardConfirmationDefaultButtonTitle: Observable<String> { return Observable.of( "screen_topup_card_details_display_text_remove_card_confirmation_remove".localized) }
    var removeCardConfirmationSecondaryButtonTitle: Observable<String> { return Observable.of( "common_button_cancel".localized) }
    var error: Observable<Error> { return errorSubject.asObservable() }
    var close: Observable<ResultType<Void>> { return closeSubject }
    var cardRemoved: Observable<Void> { return cardRemovedSubject.asObservable() }
    var cardRemovedAlert: Observable<String> { return cardRemoved.map { _ in  "screen_topup_card_details_button_remove_card_message".localized } }
    var isRunning: Observable<Bool> {
           return Observable.from([
               removeCardConfirmTapSubject.map { _ in true },
               cardRemovedSubject.map { _ in false },
               errorSubject.map { _ in false }
           ]).merge()
       }

    // MARK: - Init
    
    init(externalCard: ExternalPaymentCard,
         repository: CardsRepositoryType) {
        self.externalPaymentCardSubject = BehaviorSubject(value: externalCard)

        isExpiredSubject.onNext(externalCard.checkIfCardExpired())
        bindRemoveCard(repository: repository)
        
        
    }

    fileprivate func bindRemoveCard(repository: CardsRepositoryType) {
        let request = removeCardConfirmTapSubject
            .withLatestFrom(externalPaymentCard)
            .map { String($0.id) }
            .flatMap { id in repository.deletePaymentGatewayBeneficiary(id: id) }
            .share(replay: 1, scope: .whileConnected)

        request.elements().map { _ in () }.bind(to: cardRemovedObserver).disposed(by: disposeBag)
        request.errors().bind(to: errorSubject).disposed(by: disposeBag)
    }
}
