//
//  PayPakBenefitsViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 04/02/2022.
//

import Foundation
import RxSwift
import RxCocoa
import YAPComponents
import RxDataSources

protocol PayPakBenefitsViewModelInput {
    var backObserver: AnyObserver<Void> { get }
    var nextObserver: AnyObserver<Void> { get }
    var cardSchemeMObserver: AnyObserver<KYCCardsSchemeM> { get }
    var fetchBenefitsObserver: AnyObserver<Void> { get }
}

protocol PayPakBenefitsViewModelOutput {
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var heading: Observable<String?> { get }
    var next: Observable<Void> { get }
    var back: Observable<Void> { get }
    var error: Observable<String> { get }
}

protocol PayPakBenefitsViewModelType{
    var inputs: PayPakBenefitsViewModelInput { get }
    var outputs: PayPakBenefitsViewModelOutput { get }
}

class PayPakBenefitsViewModel: PayPakBenefitsViewModelInput, PayPakBenefitsViewModelType, PayPakBenefitsViewModelOutput {
    
    var inputs: PayPakBenefitsViewModelInput { self }
    var outputs: PayPakBenefitsViewModelOutput { self }
    
    // MARK: Subjects
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private var nextSubject = PublishSubject<Void>()
    private var backSubject = PublishSubject<Void>()
    private var fetchBenefitsSubject = PublishSubject<Void>()
    private var errorSubject = PublishSubject<String>()
    private var cardSchemeSubject = PublishSubject<KYCCardsSchemeM>()
    private var viewModels = [ReusableTableViewCellViewModelType]()
    
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
                //self?.fetchCardsBenefits(repository, cardObj: obj)
            })
            .disposed(by: disposeBag)
    }
}
