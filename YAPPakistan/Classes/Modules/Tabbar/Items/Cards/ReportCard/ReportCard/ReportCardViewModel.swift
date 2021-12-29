//
//  ReportCardViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 26/12/2021.
//

import Foundation
import RxSwift
import RxDataSources
import YAPComponents

public typealias UIAlertControlTemplate = (title: String, message: String, defaultButtonTitle: String, secondaryButtonTitle: String)

protocol ReportCardViewModelInputs {
    var selectedCardBlockOption: AnyObserver<PaymentCardBlockOption> { get }
    var blockButtonTapObserver: AnyObserver<Void> { get }
    var paymentCardBlockConfirmedObserver: AnyObserver<Void> { get }
    var closeObserver: AnyObserver<Void> { get }
}

protocol ReportCardViewModelOutputs {
    var title: Observable<String> { get }
    var cardPlan: Observable<String> { get }
    var panNumber: Observable<String?> { get }
    var note: Observable<String> { get }
    var footNote: Observable<String?> { get }
    var cardBlockOptionsTitle: Observable<String> { get }
    var cardBlockOptions: Observable<[OptionPickerItem<PaymentCardBlockOption>]> { get }
    var blockButtonTitle: Observable<String> { get }
    var isBlockButtonEnabled: Observable<Bool> { get }
    var blockButtonTap: Observable<Void> { get }
    var blockConfirmationAlert: Observable<UIAlertControlTemplate> { get }
    var error: Observable<Error> { get }
    var next: Observable<Void> { get }
    var close: Observable<Void> { get }
    var complete: Observable<Void> { get }
    var isRunning: Observable<Bool> { get }
}

protocol ReportCardViewModelType{
    var inputs : ReportCardViewModelInputs { get }
    var outputs: ReportCardViewModelOutputs { get }
}

class ReportCardViewModel : ReportCardViewModelInputs, ReportCardViewModelOutputs, ReportCardViewModelType {

    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: ReportCardViewModelInputs { return self }
    var outputs: ReportCardViewModelOutputs { return self }
    let repository: CardsRepositoryType
    
    private let paymentCardSubject: BehaviorSubject<PaymentCard>!
    private let cardBlockOptionsSubject: BehaviorSubject<[OptionPickerItem<PaymentCardBlockOption>]>!
    private let selectedCardBlockOptionSubject = PublishSubject<PaymentCardBlockOption>()
    private let isBlockButtonEnabledSubject = BehaviorSubject(value: false)
    private let blockButtonTapSubject = PublishSubject<Void>()
    private let paymentCardBlockConfirmedSubject = PublishSubject<Void>()
    private let errorSubject = PublishSubject<Error>()
    private let nextSubject = PublishSubject<Void>()
    private let closeSubject = PublishSubject<Void>()
    private let completeSubject = PublishSubject<Void>()
    private let footNoteSubject = BehaviorSubject<String?>(value: String.init(format: "screen_report_card_display_text_block_footnote".localized, "+971 600 55 1214"))

    // MARK: - Inputs
    var selectedCardBlockOption: AnyObserver<PaymentCardBlockOption> { return selectedCardBlockOptionSubject.asObserver() }
    var blockButtonTapObserver: AnyObserver<Void> { return blockButtonTapSubject.asObserver() }
    var paymentCardBlockConfirmedObserver: AnyObserver<Void> { return paymentCardBlockConfirmedSubject.asObserver() }
    var closeObserver: AnyObserver<Void> { return closeSubject.asObserver() }
    
    // MARK: - Outputs
    var title: Observable<String> { return Observable.of( "screen_report_card_display_text_title".localized) }
    var cardPlan: Observable<String> { return paymentCardSubject.map { $0.cardType == .debit ? "common_disply_text_card_name_primary_silver".localized : $0.physical ? "common_display_text_physical_card".localized : "common_display_text_virtual_card".localized } }
    var panNumber: Observable<String?> { return paymentCardSubject.map { $0.maskedCardNo } }
    var note: Observable<String> { return Observable.of( "screen_report_card_display_text_block_note".localized) }
    var footNote: Observable<String?> { return footNoteSubject.asObservable() }
    var cardBlockOptionsTitle: Observable<String> { return Observable.of( "screen_report_card_display_text_block_card_title".localized) }
    var cardBlockOptions: Observable<[OptionPickerItem<PaymentCardBlockOption>]> { return cardBlockOptionsSubject.asObservable() }
    var blockButtonTitle: Observable<String> { return Observable.of( "screen_report_card_button_block_report".localized) }
    var isBlockButtonEnabled: Observable<Bool> { return isBlockButtonEnabledSubject.asObservable() }
    var blockButtonTap: Observable<Void> { return blockButtonTapSubject.asObservable() }
    var blockConfirmationAlert: Observable<UIAlertControlTemplate> { return blockButtonTap.map { _ in ( "screen_report_card_display_text_block_alert_title".localized,  "screen_report_card_display_text_block_alert_message".localized,  "common_button_confirm".localized,  "common_button_cancel".localized) } }
    var error: Observable<Error> { return errorSubject.asObservable() }
    var next: Observable<Void> { return nextSubject.asObservable() }
    var close: Observable<Void> { return closeSubject.asObservable() }
    var complete: Observable<Void> { return completeSubject.asObservable() }
    var isRunning: Observable<Bool> {
        return Observable.from([
            paymentCardBlockConfirmedSubject.map { _ in true },
            errorSubject.map { _ in false },
            completeSubject.map { _ in false },
            nextSubject.map { _ in false }
            ]).merge()
    }
    
    // MARK: - Init
    init(paymentCard: PaymentCard,
         paymentCardBlockOptionFactory: () -> [OptionPickerItem<PaymentCardBlockOption>] = CardBlockOptionsFactory.createCardBlockOptions,
         cardsRepository: CardsRepositoryType) {
        paymentCardSubject = BehaviorSubject(value: paymentCard)
        cardBlockOptionsSubject = BehaviorSubject(value: paymentCardBlockOptionFactory())
        self.repository = cardsRepository
        fetchData()
        bindReportButtonEnabled()
        bindBlockPaymentCardOnConfirmation()
    }
    
    func bindReportButtonEnabled() {
        selectedCardBlockOptionSubject.map { _ in true }.bind(to: isBlockButtonEnabledSubject).disposed(by: disposeBag)
    }
    
    func bindBlockPaymentCardOnConfirmation() {
        let apiParams = Observable.combineLatest(paymentCardSubject, selectedCardBlockOptionSubject)
        
        let apiCall = paymentCardBlockConfirmedSubject
            .withLatestFrom(apiParams)
            .flatMap { params in self.repository.closeCard(cardSerialNumber: params.0.cardSerialNumber!, reason: params.1.rawValue) }.share(replay: 1, scope: .whileConnected)

        apiCall.errors().bind(to: errorSubject).disposed(by: disposeBag)

        let success = apiCall.elements().share(replay: 1, scope: .whileConnected)
        let physicalCardReorder = success.withLatestFrom(paymentCardSubject).filter { $0.physical }.map { _ in () }
        let virtualCardReorder = success.withLatestFrom(paymentCardSubject).filter { !$0.physical }.map { _ in () }

//        physicalCardReorder.do(onNext: { _ in SessionManager.current.refreshCards() }).bind(to: nextSubject).disposed(by: disposeBag)
//        virtualCardReorder.do(onNext: { _ in SessionManager.current.refreshCards() }).bind(to: completeSubject).disposed(by: disposeBag)
    }
}

private extension ReportCardViewModel {
    func fetchData() {
        YAPProgressHud.showProgressHud()
        let request = self.repository.getHelpLineNumber().do(onNext: { _ in YAPProgressHud.hideProgressHud() }).share()
        request.elements().unwrap().map{ String.init(format: "screen_report_card_display_text_block_footnote".localized, $0) }.bind(to: footNoteSubject).disposed(by: disposeBag)
    }
}
