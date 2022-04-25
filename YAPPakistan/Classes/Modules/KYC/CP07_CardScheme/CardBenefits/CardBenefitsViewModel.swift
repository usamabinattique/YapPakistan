//
//  CardBenefitsViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 04/02/2022.
//

import Foundation
import RxSwift
import RxCocoa
import YAPComponents
import RxDataSources

protocol CardBenefitsViewModelInput {
    var backObserver: AnyObserver<Void> { get }
    var nextObserver: AnyObserver<Void> { get }
    var cardSchemeMObserver: AnyObserver<KYCCardsSchemeM> { get }
    var fetchBenefitsObserver: AnyObserver<Void> { get }
}

protocol CardBenefitsViewModelOutput {
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var heading: Observable<String?> { get }
    var coverImage: Observable<String?> { get }
    var buttonTitle: Observable<String?> { get }
    var isNextButtonEnabled: Observable<Bool> { get }
    var next: Observable<Void> { get }
    var back: Observable<Void> { get }
    var error: Observable<String> { get }
}

protocol CardBenefitsViewModelType{
    var inputs: CardBenefitsViewModelInput { get }
    var outputs: CardBenefitsViewModelOutput { get }
}


class CardBenefitsViewModel: CardBenefitsViewModelType, CardBenefitsViewModelInput, CardBenefitsViewModelOutput{
    
    // MARK: Subjects
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private var nextSubject = PublishSubject<Void>()
    private var backSubject = PublishSubject<Void>()
    private var fetchBenefitsSubject = PublishSubject<Void>()
    private var errorSubject = PublishSubject<String>()
    private var cardSchemeSubject = PublishSubject<KYCCardsSchemeM>()
    private var coverImageSubject = BehaviorSubject<String?>(value: "")
    private var nextButtonTitleSubject = BehaviorSubject<String?>(value: "")
    private var isNextButtonEnabledSubject = BehaviorSubject<Bool>(value: false)
    private var viewModels = [ReusableTableViewCellViewModelType]()
    
    var inputs: CardBenefitsViewModelInput { self }
    var outputs: CardBenefitsViewModelOutput { self }
    
    // MARK: Inputs
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    var cardSchemeMObserver: AnyObserver<KYCCardsSchemeM> { cardSchemeSubject.asObserver() }
    var fetchBenefitsObserver: AnyObserver<Void> { fetchBenefitsSubject.asObserver() }
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    
    // MARK: Outputs
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    var heading: Observable<String?> { Observable.just("screen_kyc_card_scheme_screen_title".localized) }
    var next: Observable<Void> { nextSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var coverImage: Observable<String?> { coverImageSubject.asObservable() }
    var buttonTitle: Observable<String?> { nextButtonTitleSubject.asObservable() }
    var isNextButtonEnabled: Observable<Bool> { isNextButtonEnabledSubject.asObservable() }
    
    let disposeBag = DisposeBag()
    
    init(_ repository: KYCRepository) {
        
        cardSchemeSubject
            .subscribe(onNext:{ [weak self] obj in
                if obj.scheme == .Mastercard {
                    self?.coverImageSubject.onNext("benefits_mastercard_cover_image")
                    #warning("[UMAIR] - Todo: change next button title to coming soon for master card")
                    //self?.nextButtonTitleSubject.onNext("screen_kyc_card_benefits_screen_coming_soon_next_button_title".localized)
                    self?.nextButtonTitleSubject.onNext("screen_kyc_card_benefits_screen_next_button_title".localized)
                    self?.isNextButtonEnabledSubject.onNext(false)
                } else if obj.scheme == .PayPak {
                    self?.coverImageSubject.onNext("benefits_paypak_cover_image")
                    self?.nextButtonTitleSubject.onNext("screen_kyc_card_benefits_screen_next_button_title".localized)
                    self?.isNextButtonEnabledSubject.onNext(true)
                }
                self?.fetchCardsBenefits(repository, cardObj: obj)
            })
            .disposed(by: disposeBag)
    }
    
}

extension CardBenefitsViewModel {
    
    func fetchCardsBenefits(_ repository: KYCRepository, cardObj: KYCCardsSchemeM) {
        
        guard let scheme = cardObj.scheme else { return }
        
        let cardsRequest = fetchBenefitsSubject
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
                .flatMap{ () -> Observable<Event<[KYCCardBenefitsM]>> in
                    return repository.fetchCardBenefits(cardType: scheme)
                }
            .share()
        
        cardsRequest.subscribe(onNext: { _ in
            YAPProgressHud.hideProgressHud()
        }).disposed(by: disposeBag)
        
//        let cardObjSuccess = cardsRequest.elements()
        
        cardsRequest.elements().withUnretained(self)
            .subscribe {  benefits in
                let infoCellVMs = [CardInfoCellViewModel(cardObj)]
                if let allBenefits = benefits.element {
                    let benefitsCellVMs = allBenefits.1.map { CardBenefitsCellViewModel($0) }
                    self.viewModels.append(contentsOf: infoCellVMs)
                    self.viewModels.append(contentsOf: benefitsCellVMs)
                    self.dataSourceSubject.onNext([SectionModel(model: 0, items: self.viewModels)])
                }
            }
            .disposed(by: disposeBag)
        
        
        
//        dataSourceSubject.onNext([SectionModel(model: 0, items: cardObjSuccess.map { CardBenefitsCellViewModel($0) })])
//
//        cardObjSuccess
//            .map { $0.map { CardBenefitsCellViewModel($0) } }
//            .bind(to: optionViewModelsSubject)
//            .disposed(by: disposeBag)
//
//        cardObjSuccess
//            .map { $0.map { CardBenefitsCellViewModel($0) } }
//            .bind(to: optionViewModelsSubject)
//            .disposed(by: disposeBag)
        
        cardsRequest.errors()
            .map{ $0.localizedDescription }
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
    }
    
}
