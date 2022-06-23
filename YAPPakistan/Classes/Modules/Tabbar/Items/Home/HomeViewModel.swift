//
//  HomeViewModel.swift
//  YAP
//
//  Created by Wajahat Hassan on 26/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents
import YAPCore
import UIKit
import RxDataSources
import RxTheme

protocol HomeViewModelInputs {
    var resultObserver: AnyObserver<Void> { get }
    var logoutObserver: AnyObserver<Void> { get }
    var biometryChangeObserver: AnyObserver<Bool> { get }
    var completeVerificationObserver: AnyObserver<Void> { get }
    var viewDidAppearObserver: AnyObserver<Void> { get }
    var menuTapObserver: AnyObserver<Void> { get }
    var profileTapObserver: AnyObserver<Void> { get }
    
    var widgetsChangeObserver: AnyObserver<Void> { get }
    var selectedWidgetObserver: AnyObserver<WidgetCode?> { get }
    var searchTapObserver: AnyObserver<Void> { get }
    var didTapAnalytics: AnyObserver<Void> { get }
    var categoryChangedObserver: AnyObserver<Void> { get }
    var refreshObserver: AnyObserver<Void> { get }
    var increaseProgressViewHeightObserver: AnyObserver<Bool> {get}
    
    var transactionsObserver: AnyObserver<[SectionTransaction]> { get }
    var openFilterObserver: AnyObserver<TransactionFilter?> { get }
    var filterSelectedObserver: AnyObserver<TransactionFilter?> { get }
    var isBarGraphVisibleObserver: AnyObserver<Bool> { get }
    var selectedTransactionIndexObserver: AnyObserver<Int?> { get }
    var sectionDateObserver: AnyObserver<Date> {get}
    var progressViewTappedObserver: AnyObserver<Void> { get }
    
    var transactionDetailsObserver: AnyObserver<TransactionResponse> { get }
    var missingDocumentObserver: AnyObserver<Void> { get }
}

protocol HomeViewModelOutputs {
    var result: Observable<Void> { get }
    var logout: Observable<Void> { get }
    var biometry: Observable<Bool> { get }
    var biometrySupported: Observable<Bool> { get }
    var biometryTitle: Observable<String?> { get }
    var loading: Observable<Bool> { get }
    var error: Observable<String> { get }
    var showActivity: Observable<Bool> { get }
    var showAnalytics: Observable<Void> { get }
    var headingText: Observable<String> { get }
    var logOutButtonTitle: Observable<String> { get }
    var completeVerificationHidden: Observable<Bool> { get }
    var completeVerification: Observable<Bool> { get }
    var profilePic: Observable<(String?,UIImage?)> { get }
    var menuTap: Observable<Void> { get }
    var profileTap: Observable<Void> { get }
    
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var showCreditLimit: Observable<Void> { get }
    
    func getCreditLimitViewModel() -> CreditLimitCellViewModel
    
    var shimmering: Observable<Bool> { get }
    var transactionsViewModelObservable: TransactionsViewModel { get }
    
    var debitCard: Observable<PaymentCard?> { get }
    var debitCardOnboardingStageViewModel: Observable<PaymentCardInitiatoryStageViewModel?> { get }
    var viewDidAppear: Observable<Void> { get }
    var setPin: Observable<PaymentCard> { get }
    var trackCardDelivery: Observable<PaymentCard> { get }
    var additionalRequirements: Observable<Void> { get }
    var topUp: Observable<PaymentCard> { get }
    var balance: Observable<NSAttributedString?> { get }
    var resumeKYC: Observable<[DashboardTimelineModel]> { get }
    
    var hideWidgetsBar: Observable<Bool> { get }
    var canCallForWidgets: Observable<Void> { get }
    var checkParalaxHeight: Observable<Void> { get }
    var showLoader: Observable<Bool> { get }
    var dashboardWidgets: Observable<[DashboardWidgetsResponse]> { get }
    var noTransFound: Observable<String> { get }
    var addCreditInfo: Observable<Void> { get }
    var search: Observable<Void> { get }
    var categoryChanged: Observable<Void> { get }
    var refresh: Observable<Void> {  get }
    var selectedWidget: Observable<WidgetCode?> { get }
    var shrinkProgressView: Observable<Bool> { get }
    
    var transactions: Observable<[SectionTransaction]> { get }
    var openFilter: Observable<TransactionFilter?> { get }
    
    var filterSelected: Observable<TransactionFilter?> { get }
    var selectedTransactionIndex: Observable<Int> { get }
    var progressViewTapped: Observable<Date> { get }
    var transactionDetails: Observable<TransactionResponse> { get }
    func getTimelineViewModel() -> DashboardTimelineViewModel
    var addTimelineViewModel: Observable<DashboardTimelineViewModel> { get }
    var missingDocument: Observable<Void> { get }
    var orderPhysicalCard: Observable<PaymentCard> { get }
}

protocol HomeViewModelType {
    var inputs: HomeViewModelInputs { get }
    var outputs: HomeViewModelOutputs { get }
}

class HomeViewModel: HomeViewModelType, HomeViewModelInputs, HomeViewModelOutputs {
    private let disposeBag = DisposeBag()

    private var resultSubject = PublishSubject<Void>()
    private var logoutSubject = PublishSubject<Void>()
    private var biometrySuject: BehaviorSubject<Bool>
    private var biometrySupportedSuject = BehaviorSubject<Bool>(value: false)
    private var biometryTitleSuject = BehaviorSubject<String?>(value: nil)
    private let errorSubject = PublishSubject<String>()
    private let loadingSubject = PublishSubject<Bool>()
    private var biometryChangeSuject = PublishSubject<Bool>()
    private let showActivitySubject = BehaviorSubject<Bool>(value: false)
    var showAnalytics: Observable<Void> {analyticsSubject}
    private let completeVerificationHiddenSubject = BehaviorSubject<Bool>(value: true)
    private let completeVerificationSubject = PublishSubject<Void>()
    private let completeVerificationResultSubject = PublishSubject<Bool>()
    private let profilePicSubject = ReplaySubject<(String?,UIImage?)>.create(bufferSize: 1)
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let showCreditLimitSubject = PublishSubject<Void>()
    private let shimmeringSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    private let cardsSubject = ReplaySubject<[PaymentCard]>.create(bufferSize: 1)
    private let debitCardOnboardingStageViewModelSubject = BehaviorSubject<PaymentCardInitiatoryStageViewModel?>(value: nil)
    private let viewDidAppearSubject = ReplaySubject<Void>.create(bufferSize: 1)
    private let setPinSubject = PublishSubject<PaymentCard>()
    private let trackCardDeliverySubject = PublishSubject<PaymentCard>()
    private let orderPhysicalCardSubject = PublishSubject<PaymentCard>()
    private let additionalRequirementsSubject = PublishSubject<Void>()
    private let topUpCardSubject = PublishSubject<PaymentCard>()
    private let balanceSubject = ReplaySubject<NSAttributedString?>.create(bufferSize: 1)
    private let resumeKYCSubject =  ReplaySubject<[DashboardTimelineModel]>.create(bufferSize: 1)
    private let canCallForWidgetsSubject = PublishSubject<Void>()
    private let widgetsChangeSubject = PublishSubject<Void>()
    private let paralaxHeightSubject = BehaviorSubject<Void>(value: ())
    private let showLoaderSubject = BehaviorSubject<Bool>(value: false)
    private var dashboardWidgetsSubject = ReplaySubject<[DashboardWidgetsResponse]>.create(bufferSize: 1)
    private let hideWidgetsSubject = BehaviorSubject<Bool>(value: false)
    private let selectedWidgetSubject = ReplaySubject<WidgetCode?>.create(bufferSize: 1) //BehaviorSubject<WidgetCode?>(value: nil)
    private let isCardActivatedSubject = BehaviorSubject<CardStatus?>(value: nil)
    private let noTransFoundSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let addCreditInfoSubject = ReplaySubject<Void>.create(bufferSize: 1)
    private let searchSubject = PublishSubject<Void>()
    private let analyticsSubject = PublishSubject<Void>()
    private let categoryChangedSubject = PublishSubject<Void>()
    private let refreshSubject = PublishSubject<Void>()
    private let menuTapSubject = PublishSubject<Void>()
    private let shrinkProgressViewSubject = BehaviorSubject<Bool>(value: false)
    private let increaseProgressViewHeightSubject = BehaviorSubject<Bool>(value: true)
    private let transactionsSubject = BehaviorSubject<[SectionTransaction]>(value: [])
    private let openFilterSubject = PublishSubject<TransactionFilter?>()
    private let filterSelectedSubject = PublishSubject<TransactionFilter?>()
    private let isBarGraphVisibleSubject = BehaviorSubject<Bool>(value: false)
    private let selectedTransactionIndexSubject = BehaviorSubject<Int?>(value: nil)
    private let sectionDateSubject = BehaviorSubject<Date>(value: Date())
    private let progressViewTappedSubject = PublishSubject<Void>()
    private let progressViewDateSubject = BehaviorSubject<Date>(value: Date())
    private let profileTapSubject = PublishSubject<Void>()
    private let addTimelineViewModelSubject = ReplaySubject<DashboardTimelineViewModel>.create(bufferSize: 1)
    private let showMissingDocumentSubject = PublishSubject<Void>()
    
    private var transactionDetailsSubject = PublishSubject<TransactionResponse>()
    
    private var numberOfShownWidgets = 0
    private var cardStatus: CardStatus = .inActive

    var inputs: HomeViewModelInputs { return self }
    var outputs: HomeViewModelOutputs { return self }

    // MARK: Inputs

    var resultObserver: AnyObserver<Void> { resultSubject.asObserver() }
    var logoutObserver: AnyObserver<Void> { logoutSubject.asObserver() }
    var biometryChangeObserver: AnyObserver<Bool> { biometryChangeSuject.asObserver() }
    var completeVerificationObserver: AnyObserver<Void> { completeVerificationSubject.asObserver() }
    var viewDidAppearObserver: AnyObserver<Void> { return viewDidAppearSubject.asObserver() }
    var widgetsChangeObserver: AnyObserver<Void> { widgetsChangeSubject.asObserver() }
    var selectedWidgetObserver: AnyObserver<WidgetCode?> {selectedWidgetSubject.asObserver()}
    var searchTapObserver: AnyObserver<Void> { searchSubject.asObserver() }
    var didTapAnalytics: AnyObserver<Void> { analyticsSubject.asObserver() }
    var categoryChangedObserver: AnyObserver<Void> { categoryChangedSubject.asObserver() }
    var refreshObserver: AnyObserver<Void> { refreshSubject.asObserver() }
    var menuTapObserver: AnyObserver<Void> { return menuTapSubject.asObserver() }
    var increaseProgressViewHeightObserver: AnyObserver<Bool> {increaseProgressViewHeightSubject.asObserver()}
    
    var transactionsObserver: AnyObserver<[SectionTransaction]> { return transactionsSubject.asObserver() }
    var openFilterObserver: AnyObserver<TransactionFilter?> { return openFilterSubject.asObserver() }
    var filterSelectedObserver: AnyObserver<TransactionFilter?> { return filterSelectedSubject.asObserver() }
    var isBarGraphVisibleObserver: AnyObserver<Bool> { isBarGraphVisibleSubject.asObserver() }
    var selectedTransactionIndexObserver: AnyObserver<Int?> { return selectedTransactionIndexSubject.asObserver() }
    var sectionDateObserver: AnyObserver<Date> { sectionDateSubject.asObserver() }
    var progressViewTappedObserver: AnyObserver<Void> { progressViewTappedSubject.asObserver() }
    var profileTapObserver: AnyObserver<Void> { profileTapSubject.asObserver() }
    
    var transactionDetailsObserver: AnyObserver<TransactionResponse> { transactionDetailsSubject.asObserver() }
    var missingDocumentObserver: AnyObserver<Void> { showMissingDocumentSubject.asObserver() }
    
    // MARK: Outputs

    var result: Observable<Void> { resultSubject.asObservable() }
    var logout: Observable<Void> { logoutSubject.asObservable() }
    var biometry: Observable<Bool> { biometrySuject.asObservable() }
    var loading: Observable<Bool> { loadingSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var biometrySupported: Observable<Bool> { biometrySupportedSuject.asObservable() }
    var biometryTitle: Observable<String?> { biometryTitleSuject.asObservable() }
    var showActivity: Observable<Bool> { showActivitySubject.asObservable() }
    var headingText: Observable<String> { Observable.of("screen_light_dashboard_display_text_heading_text".localized) }
    var logOutButtonTitle: Observable<String> { Observable.of("screen_light_dashboard_button_logout".localized) }
    var completeVerificationHidden: Observable<Bool> { completeVerificationHiddenSubject.asObservable() }
    var completeVerification: Observable<Bool> { completeVerificationResultSubject.asObserver() }
    var profilePic: Observable<(String?,UIImage?)> { profilePicSubject.asObservable() }
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    var showCreditLimit: Observable<Void> { showCreditLimitSubject.asObservable() }
    var shimmering: Observable<Bool> { shimmeringSubject.asObservable() }
    var transactionsViewModelObservable: TransactionsViewModel { transactionsViewModel }
    var menuTap: Observable<Void> { return menuTapSubject.asObservable() }
    var profileTap: Observable<Void> { profileTapSubject.asObservable() }
    
    var debitCard: Observable<PaymentCard?> { cardsSubject.map { $0.filter { $0.cardType == .debit }.first } }
    var debitCardOnboardingStageViewModel: Observable<PaymentCardInitiatoryStageViewModel?> { debitCardOnboardingStageViewModelSubject.skip(1) }
    var viewDidAppear: Observable<Void> { return viewDidAppearSubject.share(replay: 1, scope: .whileConnected) }
    var setPin: Observable<PaymentCard> { return setPinSubject.asObservable() }
    var trackCardDelivery: Observable<PaymentCard> { trackCardDeliverySubject }
    var additionalRequirements: Observable<Void> { additionalRequirementsSubject.asObservable() }
    var topUp: Observable<PaymentCard> { topUpCardSubject }
    var balance: Observable<NSAttributedString?> { balanceSubject.asObservable() }
    var resumeKYC: Observable<[DashboardTimelineModel]> { resumeKYCSubject.asObservable() }
    var hideWidgetsBar: Observable<Bool> { hideWidgetsSubject.asObservable() }
    var canCallForWidgets: Observable<Void> { canCallForWidgetsSubject.asObservable() }
    var checkParalaxHeight: Observable<Void> { paralaxHeightSubject.asObservable() }
    var showLoader: Observable<Bool> { showLoaderSubject.asObservable() }
    var dashboardWidgets: Observable<[DashboardWidgetsResponse]> { dashboardWidgetsSubject.asObservable() }
    var noTransFound: Observable<String> { noTransFoundSubject.asObservable() }
    var addCreditInfo: Observable<Void> { addCreditInfoSubject.asObservable() }
    var search: Observable<Void> { searchSubject.asObservable() }
    var categoryChanged: Observable<Void> { categoryChangedSubject.asObservable() }
    var refresh: Observable<Void> { refreshSubject.asObservable() }
    var selectedWidget: Observable<WidgetCode?> { selectedWidgetSubject.skip(1).asObservable() }
    var shrinkProgressView: Observable<Bool> { shrinkProgressViewSubject }
    
    var transactions: Observable<[SectionTransaction]> { return transactionsSubject.asObservable() }
    var openFilter: Observable<TransactionFilter?> { return openFilterSubject.asObservable() }
    var filterSelected: Observable<TransactionFilter?> { return filterSelectedSubject.asObservable() }
    var selectedTransactionIndex: Observable<Int> { return selectedTransactionIndexSubject.unwrap().distinctUntilChanged() }
    var progressViewTapped: Observable<Date> { progressViewDateSubject }
    var transactionDetails: Observable<TransactionResponse> { transactionDetailsSubject.asObservable() }
    var addTimelineViewModel: Observable<DashboardTimelineViewModel> { addTimelineViewModelSubject.asObservable() }
    var missingDocument: Observable<Void> { showMissingDocumentSubject.asObservable() }
    var orderPhysicalCard: Observable<PaymentCard> { orderPhysicalCardSubject.asObservable() }

    // MARK: Init

    var accountProvider: AccountProvider!
    var biometricsManager: BiometricsManagerType!
    var notificationManager: NotificationManagerType!
    var credentialStore: CredentialsStoreType!
    var repository: LoginRepository!
    var cardsRepository: CardsRepositoryType
    private var transactionsViewModel: TransactionsViewModel
    private var transactionDataProvider: DebitCardTransactionsProvider
    private var dashboardStatusActionDisposeBag: DisposeBag!
    private var themeService: ThemeService<AppTheme>!
    private var transactionRepository: TransactionsRepositoryType
    var currentSectionDate = Date()
    private var isViewDidAppear = false

    init(accountProvider: AccountProvider,
         biometricsManager: BiometricsManagerType,
         notificationManager: NotificationManagerType,
         credentialStore: CredentialsStoreType,
         repository: LoginRepository, cardsRepository: CardsRepositoryType, transactionDataProvider: DebitCardTransactionsProvider, transactionRepository: TransactionsRepositoryType ,themeService: ThemeService<AppTheme>) {
        self.transactionRepository = transactionRepository
        self.themeService = themeService
        self.accountProvider = accountProvider
        self.biometricsManager = biometricsManager
        self.notificationManager = notificationManager
        self.credentialStore = credentialStore
        self.repository = repository
        self.cardsRepository = cardsRepository
        self.biometrySuject = BehaviorSubject(value: biometricsManager.isBiometryEnabled(for: ""))
        self.biometrySupportedSuject = BehaviorSubject(value: false)
        self.transactionDataProvider = transactionDataProvider
        self.transactionsViewModel = TransactionsViewModel(transactionDataProvider: transactionDataProvider, repository: transactionRepository, themService: themeService)
        
        
        shimmeringSubject.bind(to: transactionsViewModel.showShimmeringObserver).disposed(by: disposeBag)
        //
        // FIXME: Enable this after implementing biometrics.
        //      self.biometrySupportedSuject = BehaviorSubject(value: biometricsManager.isBiometrySupported)
        //
        self.biometryTitleSuject = BehaviorSubject(value: biometricsManager.deviceBiometryType.title)
        
        accountProvider.currentAccount.unwrap()
            .map{ ($0.accountStatus?.stepValue ?? 0) >= AccountStatus.addressCaptured.stepValue }            .bind(to: completeVerificationHiddenSubject)
            .disposed(by: disposeBag)

        completeVerificationSubject.withLatestFrom(accountProvider.currentAccount).unwrap()
            .map({ ($0.accountStatus?.stepValue ?? 100) < AccountStatus.addressCaptured.stepValue })
            .bind(to: completeVerificationResultSubject)
            .disposed(by: disposeBag)
        
        additionalRequirementsSubject.withLatestFrom(accountProvider.currentAccount).unwrap()
            .map({ ($0.accountStatus?.stepValue ?? 100) < AccountStatus.addressCaptured.stepValue })
            .bind(to: completeVerificationResultSubject)
            .disposed(by: disposeBag)
        

        viewDidAppearSubject.subscribe(onNext: { [weak self] _ in
            accountProvider.refreshAccount()
            self?.getWidgets(repository: cardsRepository)
            self?.getCustomerAccountBalance()
        }).disposed(by: disposeBag)
        
        profilePicSubject.onNext((accountProvider.currentAccountValue.value?.customer.imageURL?.absoluteString, accountProvider.currentAccountValue.value?.customer.fullName?.thumbnail ))
        
//        accountProvider.currentAccount.unwrap().map{ !$0.isFirstCredit }.map{ _ in return () }.bind(to: addCreditInfoSubject).disposed(by: disposeBag)
        
        increaseProgressViewHeightSubject.subscribe(onNext: { [unowned self] increaseSize in
            increaseSize ? shrinkProgressViewSubject.onNext(false) :
                shrinkProgressViewSubject.onNext(true)
        }).disposed(by: disposeBag)
        
        //TODO: uncomment following
   /*     generateCellViewModels()
        getCustomerAccountBalance()
        getWidgets(repository: cardsRepository)
        getCards() */
        
        generateCellViewModels()
        getWidgets(repository: cardsRepository)
        verifyUserStatus()
       
        
        refreshSubject.subscribe(onNext: { [weak self] _ in
            self?.getCustomerAccountBalance()
//            self?.getCards()
            self?.transactionsViewModel.inputs.refreshObserver.onNext(())
        }).disposed(by: disposeBag)
        
        sectionDateSubject
            .subscribe(onNext: {[weak self] in
                self?.currentSectionDate = $0
            }).disposed(by: disposeBag)
        progressViewTappedSubject.subscribe(onNext: {[unowned self] in
            progressViewDateSubject.onNext(currentSectionDate)
            self.didTapAnalytics.onNext(())
        }).disposed(by: disposeBag)
        
    }
    
    func generateCellViewModels() {
        var viewModels: [ReusableTableViewCellViewModelType] = []
        let limitVM = CreditLimitCellViewModel(12)
        limitVM.outputs.info.bind(to: showCreditLimitSubject).disposed(by: disposeBag)
        viewModels.append(limitVM)
        dataSourceSubject.onNext([SectionModel(model: 0, items: viewModels)])
    }
    
    func getCreditLimitViewModel() -> CreditLimitCellViewModel {
        let limitVM = CreditLimitCellViewModel(accountProvider.currentAccountValue.value?.firstCreditLimit ?? 0)
        limitVM.outputs.info.bind(to: showCreditLimitSubject).disposed(by: disposeBag)
        return limitVM
    }
    
    private func verifyUserStatus() {
        accountProvider.fetchAccounts().elements().subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            if let account = $0.first {
                self.generateCellViewModels()
                if account.accountStatus == .onboarded || account.accountStatus == .secretQuestionPending || account.accountStatus == .selfiePending
                   /* || account.accountStatus == .cardNamePending || account.accountStatus == .addressPending || account.accountStatus == .cardSchemePending || account.accountStatus == .cardSchemeExternalCardPending */ {
                    if account.parnterBankStatus == .signUpPending && account.accountStatus == .kycPending && account.isAmendment == false {
                        // verification required
                        let vm = DashboardTimelineViewModel(DashboardTimelineModel(title: "Account Progress", leftIcon: UIImage.init(named: "icon_profile_primary_dark", in: .yapPakistan)?.asTemplate, btnTitle: "In Process", isBtnEnabled: true))
                        vm.outputs.btn.bind(to: self.showMissingDocumentSubject).disposed(by: self.disposeBag)
                        self.addTimelineViewModelSubject.onNext(vm)
                    } else if account.parnterBankStatus == .signUpPending && account.accountStatus == .kycPending && account.isAmendment == true {
                        // verification required
                        let vm = DashboardTimelineViewModel(DashboardTimelineModel(title: "Account Progress", leftIcon: UIImage.init(named: "icon_profile_primary_dark", in: .yapPakistan)?.asTemplate, btnTitle: "Re-upload", isBtnEnabled: true))
                        vm.outputs.btn.bind(to: self.showMissingDocumentSubject).disposed(by: self.disposeBag)
                        self.addTimelineViewModelSubject.onNext(vm)
                    }
                    else if account.parnterBankStatus == .signUpPending  {
                        let vm = DashboardTimelineViewModel(DashboardTimelineModel(title: "Account Progress", leftIcon: UIImage.init(named: "icon_profile_primary_dark", in: .yapPakistan)?.asTemplate, btnTitle: "Tap to continue", isBtnEnabled: true))
                        vm.outputs.btn.map{ true }.bind(to: self.completeVerificationResultSubject).disposed(by: self.disposeBag)
                        self.addTimelineViewModelSubject.onNext(vm)
                        
                    } else {
                        // show transactions
                        self.getCustomerAccountBalance()
                        self.getCards(account: account, isShowTransactions: true)
                    }
                    
                } else {
                    // show transactions
                    self.getCustomerAccountBalance()
                    self.getCards(account: account, isShowTransactions: true)
                }
                
            }
        }).disposed(by: disposeBag)
    }
}

extension HomeViewModel {
    fileprivate func getCustomerAccountBalance() {
        let accountBalanceRequest = transactionRepository.fetchCustomerAccountBalance().share()
        
        accountBalanceRequest.elements().subscribe(onNext: { [weak self] balance in
            let text = balance.formattedBalance(showCurrencyCode: false, shortFormat: true)
            let attributedString = NSMutableAttributedString(string: text)
            guard let decimal = text.components(separatedBy: ".").last else { return }
            attributedString.addAttribute(.font, value: UIFont.large, range: NSRange(location: text.count-decimal.count, length: decimal.count))
            self?.balanceSubject.onNext(attributedString)
            self?.transactionsViewModel.latestBalance = "\(balance.amount)"
        }).disposed(by: disposeBag)
        
        
    }
    
    func getCards(account: Account, isShowTransactions: Bool = false) {
        shimmeringSubject.onNext(true)
        let cardsRequest = cardsRepository.getCards().share()
        
        cardsRequest.errors().map { $0.localizedDescription }.subscribe(onNext: { [weak self] in
            print("error \($0)")
            self?.shimmeringSubject.onNext(false)
//            self?.errorSubject.onNext($0)
        }).disposed(by: disposeBag)
        
        cardsRequest.elements().subscribe(onNext:{ [weak self] list in
            print("success cards")
            self?.shimmeringSubject.onNext(false)
            self?.cardsSubject.onNext(list ?? [])
           
            self?.checkCardStatus(card: list?.first ?? .mock, account: account)
            if isShowTransactions {
                self?.callFetchTransactions(card: list?.first)
            }
        }).disposed(by: disposeBag)
        
        cardsSubject.subscribe(onNext: {[weak self] in
            let status = $0.filter{ $0.cardType == .debit }.first?.status
            self?.isCardActivatedSubject.onNext(status)
        }).disposed(by: disposeBag)
        
        isCardActivatedSubject
            .distinctUntilChanged()
            .subscribe(onNext: {[weak self] cardStatus in
                guard let self = self else { return }
                if cardStatus == .active {
                    self.canCallForWidgetsSubject.onNext(())
                }
            }).disposed(by: disposeBag)
    }
    
    private func checkCardStatus(card: PaymentCard, account: Account) {
        if (account.parnterBankStatus == .activated || account.parnterBankStatus == .physicalCardSuccess ) && (card.deliveryStatus == .delivered && card.deliveryStatus != .failed) &&  card.pinCreated == false {
            // track card version
            let vm = DashboardTimelineViewModel(DashboardTimelineModel(title: "Track your card", leftIcon: UIImage.init(named: "icon_order_card", in: .yapPakistan)?.asTemplate, btnTitle: "Track now", isBtnEnabled: true))
            vm.outputs.btn.map{ card }.bind(to: trackCardDeliverySubject).disposed(by: self.disposeBag)
            self.addTimelineViewModelSubject.onNext(vm)
        } else if (account.parnterBankStatus == .activated || account.parnterBankStatus == .physicalCardSuccess) && (card.status == .active || card.status == .inActive) && (card.deliveryStatus == .delivered) && card.pinCreated  == false {
            // set pin
            self.setPinSubject.onNext(card)
        } else if (account.parnterBankStatus == .activated || account.parnterBankStatus == .physicalCardPending) && card.status == nil && (card.deliveryStatus == nil || card.deliveryStatus == .notCreated ) && card.pinCreated == nil {
            // order physical card
            let vm = DashboardTimelineViewModel(DashboardTimelineModel(title: "Order your physical YAP card", leftIcon: UIImage.init(named: "icon_order_card", in: .yapPakistan)?.asTemplate, btnTitle: "Order now", isBtnEnabled: true))
            vm.outputs.btn.map{ card }.bind(to: orderPhysicalCardSubject).disposed(by: self.disposeBag)
            self.addTimelineViewModelSubject.onNext(vm)
        }
    }
    
    fileprivate func callFetchTransactions(card: PaymentCard?) {
        self.shimmeringSubject.onNext(true)
        let request = self.transactionDataProvider.fetchTransactions().share()
        
        let params = Observable.combineLatest(request.elements().map { $0.content },
                                              debitCard.unwrap(),
                                              accountProvider.currentAccount.unwrap())//accountProvider.currentAccount.unwrap())
            .share(replay: 1, scope: .whileConnected)
        
        request.elements().withUnretained(self).subscribe(onNext: { `self`, respon in
            self.shimmeringSubject.onNext(false)
            self.transactionsViewModel.pageInfo = respon
            if (self.transactionsViewModel.transactionsObj.isEmpty  && !(respon.content?.isEmpty ?? false) ) {
                print("response is \(respon.content?.count ?? 0)")
                self.debitCardOnboardingStageViewModelSubject.onCompleted()
                self.transactionsViewModel.transactionsObj = respon.content ?? []
                self.transactionsViewModel.updateContent()
            }
            
        }).disposed(by: disposeBag)

        
        // Transactions are zero, show debit card timeline
        params
            .filter { ($0.0?.count ?? 0) == 0 }
            .map { PaymentCardInitiatoryStageViewModel(paymentCard: $0.1, account: $0.2) }
            .do(onNext: { [weak self] in
                self?.shimmeringSubject.onNext(false)
                self?.dashobarStatusActions(viewModel: $0)
            })
            .bind(to: debitCardOnboardingStageViewModelSubject)
            .disposed(by: disposeBag)
        
        // Transactions are not zero, hide debit card timeline
            params.take(1)
            .filter { ($0.0?.count ?? 0) > 0 }
            .subscribe(onNext: { [weak self] res in
                self?.shimmeringSubject.onNext(false)
                // set transactions if they are empty
               /* if (self?.transactionsViewModel.transactionsObj.isEmpty ?? false ) {
                    self?.transactionsViewModel.transactionsObj = res.0 ?? []
                    self?.transactionsViewModel.updateContent()
                }*/
                self?.debitCardOnboardingStageViewModelSubject.onCompleted()
                
            }).disposed(by: disposeBag)
    }
    
    func dashobarStatusActions(viewModel: PaymentCardInitiatoryStageViewModel) {
        dashboardStatusActionDisposeBag = DisposeBag()
        viewModel.actionTap
            .filter { $0 == .setPIN }
            .withLatestFrom(debitCard.unwrap())
            .bind(to: setPinSubject)
            .disposed(by: dashboardStatusActionDisposeBag)
        
        viewModel.actionTap
            .filter { $0 == .shipping }
            .withLatestFrom(debitCard.unwrap())
            .bind(to: trackCardDeliverySubject)
            .disposed(by: dashboardStatusActionDisposeBag)
        
        viewModel.actionTap
            .filter { $0 == .additionalRequirement }
            .map{ _ in }
            .bind(to: additionalRequirementsSubject)
            .disposed(by: dashboardStatusActionDisposeBag)
        /*
        viewModel.actionTap
            .filter { $0 == .topUp }
            .withLatestFrom(debitCard.unwrap())
            .bind(to: topUpCardSubject)
            .disposed(by: dashboardStatusActionDisposeBag) */
        
        viewModel.actionTap
            .filter { $0 == .topUp }
            .map{ _ in .mock }
            .bind(to: topUpCardSubject)
            .disposed(by: dashboardStatusActionDisposeBag)
    }
    
   /* private func dashboardTimelineStatus(accountStatus: AccountStatus) {
        
        var vms = [DashboardTimelineModel]()
        if accountStatus == .addressCaptured {
            let vm = DashboardTimelineModel(title: "Complete your didTapAnalyticsication", description: "We need some additional information", leftIcon: UIImage.init(named: "timeline_account_verification", in: .yapPakistan), isSeparator: true, isSeparatorVague: false, isProgress: false, progressStatus: "", isWholeContainerVague: false, btnTitle: "Complete your registration", isBtnHidden: false)
            vms.append(vm)
        }
        self.resumeKYCSubject.onNext(vms)
    } */
    
    func getTimelineViewModel() -> DashboardTimelineViewModel {
        return DashboardTimelineViewModel(DashboardTimelineModel(title: "view_payment_card_onboarding_stage_account_verification_label_title".localized,  btnTitle: "Re-upload now", isBtnEnabled: true))
    }
}

// MARK: - Widgets

extension HomeViewModel {
    
    func getWidgets(repository: CardsRepositoryType) {
        
        self.showLoaderSubject.onNext(true)
        let request = repository.getDashboardWidgets().share()
        
        request.elements()
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.showLoaderSubject.onNext(false)
                self.dashboardWidgetsSubject.onNext($0)
                let dataToBeShown = $0.filter {$0.status ?? false}
                self.numberOfShownWidgets = dataToBeShown.count
                self.widgetVisibility()
        }).disposed(by: disposeBag)
        
        request
            .errors()
            .do(onNext: { [weak self] _ in
            self?.showLoaderSubject.onNext(false)
                
            })
            .map{$0.localizedDescription}
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
    }
    
    func widgetVisibility() {
        //if (cardStatus == .active) && (self.numberOfShownWidgets > 0) && !(YAPUserDefaults.isWidgetsBarHidden()) {
        if  (self.numberOfShownWidgets > 0) && !(YAPUserDefaults.isWidgetsBarHidden()) {
            self.hideWidgetsSubject.onNext(false)
        }
        else {
            self.hideWidgetsSubject.onNext(true)
        } 
    }
}
