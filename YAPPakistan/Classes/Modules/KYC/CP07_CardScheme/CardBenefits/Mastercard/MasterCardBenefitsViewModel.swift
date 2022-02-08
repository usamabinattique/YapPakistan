//
//  MasterCardBenefitsViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 04/02/2022.
//

import Foundation
import RxSwift
import RxCocoa
import YAPComponents
import RxDataSources

protocol MasterCardBenefitsViewModelInput {
    var backObserver: AnyObserver<Void> { get }
    var nextObserver: AnyObserver<Void> { get }
    var cardSchemeMObserver: AnyObserver<KYCCardsSchemeM> { get }
    var fetchBenefitsObserver: AnyObserver<Void> { get }
}

protocol MasterCardBenefitsViewModelOutput {
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var heading: Observable<String?> { get }
    var next: Observable<Void> { get }
    var back: Observable<Void> { get }
    var error: Observable<String> { get }
}

protocol MasterCardBenefitsViewModelType{
    var inputs: MasterCardBenefitsViewModelInput { get }
    var outputs: MasterCardBenefitsViewModelOutput { get }
}


class MasterCardBenefitsViewModel: MasterCardBenefitsViewModelType, MasterCardBenefitsViewModelInput, MasterCardBenefitsViewModelOutput{
    
    // MARK: Subjects
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private var nextSubject = PublishSubject<Void>()
    private var backSubject = PublishSubject<Void>()
    private var fetchBenefitsSubject = PublishSubject<Void>()
    private var errorSubject = PublishSubject<String>()
    private var cardSchemeSubject = PublishSubject<KYCCardsSchemeM>()
    
    var inputs: MasterCardBenefitsViewModelInput { self }
    var outputs: MasterCardBenefitsViewModelOutput { self }
    
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
    
    let disposeBag = DisposeBag()
    
    init(_ repository: KYCRepository) {
        cardSchemeSubject
            .subscribe(onNext:{ [weak self] obj in
                self?.fetchCardsBenefits(repository, cardObj: obj)
            })
            .disposed(by: disposeBag)
    }
    
}

extension MasterCardBenefitsViewModel {
    
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
        
        let cardObjSuccess = cardsRequest.elements().share()
        
        cardObjSuccess
            .subscribe { benefits in
                print(benefits)
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
