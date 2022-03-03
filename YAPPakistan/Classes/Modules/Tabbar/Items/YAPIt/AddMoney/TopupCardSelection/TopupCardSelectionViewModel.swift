//
//  TopupCardSelectionViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 09/02/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift
import RxDataSources

protocol TopupCardSelectionViewModelInputs {
    var addNewCardObserver: AnyObserver<Void> { get }
    var beneficiarySelectedObserver: AnyObserver<ExternalPaymentCard> { get }
    var refreshCardsObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
    var currentIndexObserver: AnyObserver<Int> { get }
    var selectObserver: AnyObserver<Void> { get }
    var itemSelectedObserver: AnyObserver<IndexPath> { get }
}

protocol TopupCardSelectionViewModelOutputs {
    var screenTitle: Observable<String> { get }
    var topupPaymentCardCellViewModels: Observable<[ReusableCollectionViewCellViewModelType]> { get }
    var addNewCard: Observable<Void> { get }
    var beneficiarySelected: Observable<ExternalPaymentCard> { get }
    var cardCount: Observable<String?> { get }
    var subHeading: Observable<String?> { get }
    var cardNickName: Observable<String?> { get }
    var openCardDetails: Observable<ExternalPaymentCard> { get }
    var addCardEnabled: Observable<Bool> { get }
    var error: Observable<String> { get }
    var cellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
    var back: Observable<Void> { get }
}

protocol TopupCardSelectionViewModelType {
    var inputs: TopupCardSelectionViewModelInputs { get }
    var outputs: TopupCardSelectionViewModelOutputs { get }
}

class TopupCardSelectionViewModel: TopupCardSelectionViewModelType, TopupCardSelectionViewModelInputs, TopupCardSelectionViewModelOutputs {
    
    // MARK: - Properties
    var inputs: TopupCardSelectionViewModelInputs { return self }
    var outputs: TopupCardSelectionViewModelOutputs { return self }
    
    private let screenTitleSubject = PublishSubject<String>()
    private let topupPaymentCardCellViewModelsSubject = BehaviorSubject<[ReusableCollectionViewCellViewModelType]>(value: [])
    private let addNewCardSubject = PublishSubject<Void>()
    private let beneficiarySelectedSubject = PublishSubject<ExternalPaymentCard>()
    private let refreshCardsSubject = PublishSubject<Void>()
    private let backSubject = PublishSubject<Void>()
    private let cardCountSubject = BehaviorSubject<String?>(value: nil)
    private let subHeadingSubject = BehaviorSubject<String?>(value: nil)
    private let cardNickNameSubject = BehaviorSubject<String?>(value: nil)
    private let openCardDetailsSubject = PublishSubject<ExternalPaymentCard>()
    private let currentIndex = BehaviorSubject<Int>(value: 0)
    private let selectSubject = PublishSubject<Void>()
    private let addCardEnabledSubject = BehaviorSubject<Bool>(value: false)
    private let errorSubject = PublishSubject<String>()
    private let itemSelectedSubject = PublishSubject<IndexPath>()
    private let cellViewModelsSubject = ReplaySubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>.create(bufferSize: 1)

    // MARK: - Inputs
    var addNewCardObserver: AnyObserver<Void> { return addNewCardSubject.asObserver() }
    var beneficiarySelectedObserver: AnyObserver<ExternalPaymentCard> { return beneficiarySelectedSubject.asObserver() }
    var refreshCardsObserver: AnyObserver<Void> { return refreshCardsSubject.asObserver() }
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    var currentIndexObserver: AnyObserver<Int> { return currentIndex.asObserver() }
    var itemSelectedObserver: AnyObserver<IndexPath> { itemSelectedSubject.asObserver() }

    // MARK: - Outputs
    var screenTitle: Observable<String> { screenTitleSubject.asObservable() }
    var topupPaymentCardCellViewModels: Observable<[ReusableCollectionViewCellViewModelType]> { return topupPaymentCardCellViewModelsSubject.asObservable() }
    var addNewCard: Observable<Void> { return addNewCardSubject.asObservable() }
    var beneficiarySelected: Observable<ExternalPaymentCard> { return beneficiarySelectedSubject.asObservable() }
    var cardCount: Observable<String?> { return cardCountSubject.asObservable() }
    var subHeading: Observable<String?> { return subHeadingSubject.asObservable() }
    var cardNickName: Observable<String?> { return cardNickNameSubject.asObservable() }
    var openCardDetails: Observable<ExternalPaymentCard> { return openCardDetailsSubject.asObservable() }
    var selectObserver: AnyObserver<Void> { return selectSubject.asObserver() }
    var addCardEnabled: Observable<Bool> { return addCardEnabledSubject.asObservable() }
    var error: Observable<String> { return errorSubject.asObservable() }
    public var cellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { cellViewModelsSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }

    private let disposeBag = DisposeBag()
    private let repository: Y2YRepositoryType
    private var beneficiaries = [ExternalPaymentCard]()
    // MARK: - Init
    
    init(repository: Y2YRepositoryType) {
        
        self.repository = repository
      
        let addCardCellViewModel = AddTopupPCCVCellViewModel()
        //addCardCellViewModel.outputs.addNewCard.bind(to: addNewCardSubject).disposed(by: disposeBag)
        
//        let fetchRequest = refreshCardsSubject
//            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
//            .flatMap{ repository.fetchPaymentGatewayBeneficiaries() }
//            .share()
        
        let fetchSubject = refreshCardsSubject.startWith(()).do(onNext: { _ in YAPProgressHud.showProgressHud() })

        let fetchRequest = fetchSubject
            .flatMap { repository.fetchPaymentGatewayBeneficiaries() } //fetchPaymentGatewayBeneficiries() }
            .share()
        
      //  let limitRequest = fetchSubject.share()
//            .flatMap { repository.fetchPaymentGatewayLimit() }
//            .share()
        
//        Observable.combineLatest(fetchRequest.map { _ in }, limitRequest.map { _ in }).subscribe(onNext: { _ in YAPProgressHud.hideProgressHud() }).disposed(by: disposeBag)
            
//        Observable.merge(fetchRequest.errors(), limitRequest.errors()).map { $0.localizedDescription }.bind(to: errorSubject).disposed(by: disposeBag)
        fetchRequest.map{ _ in }.subscribe(onNext: { _ in YAPProgressHud.hideProgressHud() }).disposed(by: disposeBag)
        fetchRequest.errors().map { $0.localizedDescription }.bind(to: errorSubject).disposed(by: disposeBag)
        
        fetchRequest.elements()
            .subscribe(onNext: { [weak self] beneficiaries in
                guard let `self` = self else { return }
                self.beneficiaries = beneficiaries
                var viewModels: [ReusableCollectionViewCellViewModelType] = beneficiaries.map { TopupPCCVCellViewModel($0) }
                viewModels.forEach { [unowned self] in
                    ($0 as? TopupPCCVCellViewModelType)?.outputs.openDetails.bind(to: self.openCardDetailsSubject).disposed(by: self.disposeBag) }
                viewModels.append(addCardCellViewModel)
               // self.topupPaymentCardCellViewModelsSubject.onNext(viewModels)
                self.cellViewModelsSubject.onNext([SectionModel(model: 0, items: viewModels)])
                self.currentIndex.onNext(0)
            })
            .disposed(by: disposeBag)
      
//        limitRequest.elements().map { $0.remaining > 0 }.bind(to: addCardEnabledSubject).disposed(by: disposeBag)
        let isCardEnabeld = ReplaySubject<Bool>.create(bufferSize: 1)
        isCardEnabeld.onNext(beneficiaries.count > 0)
        isCardEnabeld.bind(to: addCardEnabledSubject).disposed(by: disposeBag)
        
        let cardCount = fetchRequest.elements().map{ $0.count }.share()
        
        cardCount.map { $0 == 0 ? "screen_topup_card_selection_display_no_card_text_title".localized : "screen_topup_card_selection_display_card_text_title".localized }.bind(to: screenTitleSubject).disposed(by: disposeBag)
        
        cardCount.map { $0 == 0 ? "screen_topup_card_selection_display_text_heading_no_cards".localized : $0 == 1 ? "screen_topup_card_selection_display_text_heading_1_card".localized : String.init(format: "screen_topup_card_selection_display_text_heading_cards".localized, $0)}.bind(to: cardCountSubject).disposed(by: disposeBag)
        
        cardCount.map { $0 == 0 ? "screen_topup_card_selection_display_text_sub_heading_no_cards".localized : "screen_topup_card_selection_display_text_sub_heading_cards".localized }.bind(to: subHeadingSubject).disposed(by: disposeBag)
        
        cardCount.map{ $0 > 0 }.bind(to: addCardCellViewModel.inputs.cardAlreadyExistsObserver).disposed(by: disposeBag)
        
        backSubject.subscribe(onNext: { [unowned self] in
            self.addNewCardSubject.onCompleted()
            self.beneficiarySelectedSubject.onCompleted()
        }).disposed(by: disposeBag)
        
        currentIndex.map { [weak self] in $0 < self?.beneficiaries.count ?? 0 ? self?.beneficiaries[$0].nickName : nil }.bind(to: cardNickNameSubject).disposed(by: disposeBag)
        
        selectSubject.withLatestFrom(currentIndex).filter { [unowned self] in $0 < self.beneficiaries.count }.map { [unowned self] in self.beneficiaries[$0] }.bind(to: beneficiarySelectedSubject).disposed(by: disposeBag)
        
        Observable.combineLatest(itemSelectedSubject,cellViewModelsSubject).withUnretained(self).subscribe(onNext: { `self` , _arg0 in
            let (index, sectionModel) = _arg0
            var isAddCardModel = false
            for model in sectionModel {
                if (model.items.count - 1) == index.row {
                    isAddCardModel = true
                    self.addNewCardSubject.onNext(())
                }
                if !isAddCardModel {
                    if self.beneficiaries.count == (model.items.count - 1) && (index.row != model.items.count - 1 ) {
                        let selectedBenefeciary = self.beneficiaries[index.row]
                        self.beneficiarySelectedSubject.onNext(selectedBenefeciary)
                    }
                }
                break
            }
        }).disposed(by: disposeBag)
        

    }
}
    
