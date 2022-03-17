//
//  SendMoneyHomeViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 14/03/2022.
//

import Foundation
import RxSwift
import RxDataSources
import YAPCore
import YAPComponents
//import AppAnalytics

protocol SendMoneyHomeViewModelInput {
    var closeObserver: AnyObserver<Void> { get }
    var addObserver: AnyObserver<Void> { get }
    var beneficiaryObserver: AnyObserver<SendMoneyBeneficiary> { get }
    var refreshObserver: AnyObserver<Void> { get }
    var editBeneficiaryObserver: AnyObserver<SendMoneyBeneficiary> { get }
    var deleteBeneficiaryObserver: AnyObserver<SendMoneyBeneficiary> { get }
    var searchObserver: AnyObserver<Void> { get }
}

protocol SendMoneyHomeViewModelOutput {
    var close: Observable<Void> { get }
    var addBeneficiary: Observable<Void> { get }
    var beneficiaryAvailable: Observable<Bool> { get }
    var recentBeneficiaryAvailable: Observable<Bool> { get }
    var showError: Observable<String> { get }
    var allBeneficiaryDataSource: Observable<[SectionModel<Int, SendMoneyHomeBeneficiaryCellViewModel>]> { get }
    var recentBeneficiaryDataSource: Observable<[SectionModel<Int, SendMoneyHomeBeneficiaryCollectionCellViewModel>]> { get }

    var sendMoney: Observable<SendMoneyBeneficiary> { get }
    var showActivity: Observable<Bool> { get }
    var editBeneficiary: Observable<SendMoneyBeneficiary> { get }
    var searchBeneficiaries: Observable<[SendMoneyBeneficiary]> { get }
    var recentBeneficiaryViewModel: RecentBeneficiaryViewModelType { get }
    var title: Observable<String?> { get }
    var listLabel: Observable<String?> { get }
    var cellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
}

protocol SendMoneyHomeViewModelType {
    var inputs: SendMoneyHomeViewModelInput { get }
    var outputs: SendMoneyHomeViewModelOutput { get }
}

class SendMoneyHomeViewModel: SendMoneyHomeViewModelType, SendMoneyHomeViewModelInput, SendMoneyHomeViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: SendMoneyHomeViewModelInput { return self }
    var outputs: SendMoneyHomeViewModelOutput { return self }
    

    private let repository : YapItRepositoryType!
    private let sendMoneyType: SendMoneyType!
    private var accountProvider: AccountProvider!
    private let recentBeneficiariesViewModel = RecentBeneficiaryViewModel()

    private let closeSubject = PublishSubject<Void>()
    private let addSubject = PublishSubject<Void>()
    private let refreshSubject = PublishSubject<Void>()
    private let beneficiaryAvailableSubject = BehaviorSubject<Bool>(value: false)
    private let recentBeneficiaryAvailableSubject = BehaviorSubject<Bool>(value: false)
    private let showErrorSubject = PublishSubject<String>()
    private let showActivitySubject = PublishSubject<Bool>()

    private let allBeneficiaryDataSourceSubject = BehaviorSubject<[SectionModel<Int, SendMoneyHomeBeneficiaryCellViewModel>]>(value: [])
    private let recentBeneficiaryDataSourceSubject = BehaviorSubject<[SectionModel<Int, SendMoneyHomeBeneficiaryCollectionCellViewModel>]>(value: [])
    private let cellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>(value: [])
    private let sendMoneySubject = PublishSubject<SendMoneyBeneficiary>()
    private let editBeneficiarySubject = PublishSubject<SendMoneyBeneficiary>()
    private let deleteBeneficiarySubject = PublishSubject<SendMoneyBeneficiary>()

    private let searchObserverSubject = PublishSubject<Void>()
    private let searchBeneficiariesSubject = PublishSubject<[SendMoneyBeneficiary]>()
    private let titleSubject: BehaviorSubject<String?>
    private let listLabelSubject: BehaviorSubject<String?>

    // MARK: - Inputs
    var closeObserver: AnyObserver<Void> { return closeSubject.asObserver() }
    var addObserver: AnyObserver<Void> { return addSubject.asObserver() }
    var beneficiaryObserver: AnyObserver<SendMoneyBeneficiary> { return sendMoneySubject.asObserver() }
    var refreshObserver: AnyObserver<Void> { return refreshSubject.asObserver() }
    var editBeneficiaryObserver: AnyObserver<SendMoneyBeneficiary> { return editBeneficiarySubject.asObserver() }
    var deleteBeneficiaryObserver: AnyObserver<SendMoneyBeneficiary> { return deleteBeneficiarySubject.asObserver() }
    var searchObserver: AnyObserver<Void> { return searchObserverSubject.asObserver() }

    // MARK: - Outputs
    var close: Observable<Void> { return closeSubject.asObservable() }
    var addBeneficiary: Observable<Void> { return addSubject.asObservable() }
    var beneficiaryAvailable: Observable<Bool> { return beneficiaryAvailableSubject.asObservable() }
    var showError: Observable<String> { return showErrorSubject.asObservable() }
    var allBeneficiaryDataSource: Observable<[SectionModel<Int, SendMoneyHomeBeneficiaryCellViewModel>]> { return allBeneficiaryDataSourceSubject.asObservable() }
    var recentBeneficiaryDataSource: Observable<[SectionModel<Int, SendMoneyHomeBeneficiaryCollectionCellViewModel>]> { return recentBeneficiaryDataSourceSubject.asObservable() }
    var cellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { cellViewModelsSubject.asObservable() }
    var recentBeneficiaryAvailable: Observable<Bool> { return recentBeneficiaryAvailableSubject.asObservable() }
    var sendMoney: Observable<SendMoneyBeneficiary> { return sendMoneySubject.asObservable() }
    var showActivity: Observable<Bool> { return showActivitySubject.asObservable() }
    var editBeneficiary: Observable<SendMoneyBeneficiary> { return editBeneficiarySubject.asObservable() }
    var searchBeneficiaries: Observable<[SendMoneyBeneficiary]> { return searchBeneficiariesSubject.asObservable() }
    var recentBeneficiaryViewModel: RecentBeneficiaryViewModelType { recentBeneficiariesViewModel }
    var title: Observable<String?> { titleSubject.asObservable() }
    var listLabel: Observable<String?> { listLabelSubject.asObservable() }

    // MARK: - Init
    init(repository: YapItRepositoryType, sendMoneyType: SendMoneyType, accountProvider: AccountProvider) {
        self.repository = repository
        self.sendMoneyType = sendMoneyType
        self.accountProvider = accountProvider

        titleSubject = BehaviorSubject(value: sendMoneyType.title)
        listLabelSubject = BehaviorSubject(value: sendMoneyType.listLabel)

        fetchBeneficiaries()
//        deleteBeneficiary()
        fetchRecentBeneficiaries()

        allBeneficiaryDataSourceSubject.map { $0.count > 0 }.bind(to: beneficiaryAvailableSubject).disposed(by: disposeBag)

        /// firebase event logging
//        sendMoneySubject.map{ _ in SendMoneyEvent.beneficiaryTapped() }.bind(to: AppAnalytics.shared.rx.logEvent).disposed(by: disposeBag)
//        addSubject.map{ _ in SendMoneyEvent.addBeneficiary() }.bind(to: AppAnalytics.shared.rx.logEvent).disposed(by: disposeBag)
//        editBeneficiarySubject.map{ _ in SendMoneyEvent.editBeneficiary() }.bind(to: AppAnalytics.shared.rx.logEvent).disposed(by: disposeBag)
    }
}

private extension SendMoneyHomeViewModel {
    func fetchBeneficiaries() {
        
        self.showLoadingEffects()
        
        let allIBFTBenefeciries = refreshSubject
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
                .flatMap{ self.repository.fetchAllIBFTBeneficiaries() }
            .share()
        
        allIBFTBenefeciries.subscribe(onNext: { _ in
            YAPProgressHud.hideProgressHud()

        }).disposed(by: disposeBag)
        
        allIBFTBenefeciries.errors().map { $0.localizedDescription }.bind(to: showErrorSubject).disposed(by: disposeBag)
        
        allIBFTBenefeciries.errors().subscribe(onNext: { [weak self] (_) in
            self?.allBeneficiaryDataSourceSubject.onNext([SectionModel(model: 0, items: [])])
        }).disposed(by: disposeBag)
        
        allIBFTBenefeciries.elements().subscribe(onNext: { responseData in


            //self.allBeneficiaryDataSourceSubject.onNext([SectionModel()])
            print("Elements: \(responseData)")


        }).disposed(by: disposeBag)
        
        let allBeneficiaries = allIBFTBenefeciries.elements().withLatestFrom(
            Observable.combineLatest(allIBFTBenefeciries.elements(), self.accountProvider.currentAccount.map{ $0?.customer.homeCountry }.unwrap())
        )
            .map{ [unowned self] beneficiaries, homeCountry -> [SendMoneyBeneficiary] in
                switch self.sendMoneyType {
                case .local:
                    return beneficiaries.filter{ $0.type == .uaefts || $0.type == .domestic || $0.type == .IBFT }
                case .international:
                    return beneficiaries.filter{ ($0.type == .rmt || $0.type == .swift) && $0.country != homeCountry }
                case .homeCountry(let country, _):
                    return beneficiaries.filter{ $0.country == country.isoCode2Digit }
                case .cashPickUp:
                    return beneficiaries.filter{ $0.type == .cashPayout }
                default:
                    return beneficiaries
                } }
        
        
        allBeneficiaries
            .map { $0.indexed.map { SendMoneyHomeBeneficiaryCellViewModel($0) } }
            .map { [SectionModel(model: 0, items: $0)] }
            .subscribe(onNext : { [weak self] model in
                print("Model Printed: \(model)")
                self?.allBeneficiaryDataSourceSubject.onNext( (model) )
            })
            //.bind(to: allBeneficiaryDataSourceSubject)
            .disposed(by: disposeBag)
        
//        allBeneficiaries
//            .map { $0.indexed.map { SendMobneyHomeBeneficiaryCellViewModel($0) } }
//            .map { [SectionModel(model: 0, items: $0)] }
//            .bind(to: allBeneficiaryDataSourceSubject)
//            .disposed(by: disposeBag)

        allBeneficiaries.map { $0.count > 0 }.bind(to: beneficiaryAvailableSubject).disposed(by: disposeBag)
        
        
        

        searchObserverSubject.withLatestFrom(allBeneficiaries).bind(to: searchBeneficiariesSubject).disposed(by: disposeBag)
//
//        let recentBeneficiaries = allBeneficiaries.map{ $0.filter{ $0.lastTranseferDate != nil }.sorted{ $0.beneficiaryLasTransferDate > $1.beneficiaryLasTransferDate }.prefix(15) }
//
//        recentBeneficiaries.map{ $0.count > 0 }.bind(to: recentBeneficiaryAvailableSubject).disposed(by: disposeBag)
//
//        recentBeneficiaries.map{ $0.map{ $0 as RecentBeneficiaryType }.indexed }.bind(to: recentBeneficiariesViewModel.inputs.recentBeneficiaryObserver).disposed(by: disposeBag)
//
//        recentBeneficiariesViewModel.outputs.itemSelected
//            .withLatestFrom(Observable.combineLatest(recentBeneficiariesViewModel.outputs.itemSelected, recentBeneficiaries))
//            .map{ $0.1[$0.0] }
//            .bind(to: sendMoneySubject)
//            .disposed(by: disposeBag)
    }
    
    func fetchRecentBeneficiaries() {
        
        //contactsManager.syncPhoneBookContacts()
        
        let recentIBFTBenefeciries = refreshSubject
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
                .flatMap{ self.repository.fetchRecentSendMoneyBeneficiaries() }
            .share()
        
        
        recentIBFTBenefeciries.subscribe(onNext: { _ in
            YAPProgressHud.hideProgressHud()

        }).disposed(by: disposeBag)
        
        
        recentIBFTBenefeciries.errors().map { $0.localizedDescription }.bind(to: showErrorSubject).disposed(by: disposeBag)
        
//        recentIBFTBenefeciries.elements().subscribe(onNext: { responseData in
//
//
//            //self.allBeneficiaryDataSourceSubject.onNext([SectionModel()])
//            print("Recent Benefs Elements: \(responseData)")
//
//
//
//
//        }).disposed(by: disposeBag)
        
        
        
        
        recentIBFTBenefeciries.elements().map { $0.count > 0 }.bind(to: recentBeneficiaryAvailableSubject).disposed(by: disposeBag)
        
        
//        allBeneficiaries
//            .map { $0.indexed.map { SendMoneyHomeBeneficiaryCellViewModel($0) } }
//            .map { [SectionModel(model: 0, items: $0)] }
//            .subscribe(onNext : { [weak self] model in
//                print("Model Printed: \(model)")
//                self?.allBeneficiaryDataSourceSubject.onNext( (model) )
//            })
//            //.bind(to: allBeneficiaryDataSourceSubject)
//            .disposed(by: disposeBag)
        
        
        
        
        
            //Here change below
        recentIBFTBenefeciries.elements()
            .map { $0.indexed.map { SendMoneyHomeBeneficiaryCollectionCellViewModel($0) } }
            .map { [SectionModel(model: 0, items: $0)] }
            .subscribe(onNext: { model in
                self.recentBeneficiaryDataSourceSubject.onNext( ( model ))
            })
            .disposed(by: disposeBag)
        
//        recentIBFTBenefeciries.elements().map { list -> [SendMoneyHomeBeneficiaryCollectionCellViewModel]  in
//            return list.map { beneficiary -> SendMoneyHomeBeneficiaryCollectionCellViewModel in
//                SendMoneyHomeBeneficiaryCollectionCellViewModel(beneficiary)
//            }
//        }.map{ [SectionModel(model: 0, items: $0)] }.bind(to: recentBeneficiaryDataSourceSubject).disposed(by: disposeBag)
        
        
        
        
//        let sendMoneyBeneficiariesRequest = refreshSubject
//            .flatMap{ repository.fetchRecentSendMoneyBeneficiaries() }
//            .share()
        
//        let countriesRequest = repository.fetchBeneficiaryCountries().share()
        
//        y2yBeneficiariesRequest.map{ _ in }
//            .subscribe(onNext: { respons in
//
//            })
//            .disposed(by: disposeBag)
       
        /* Observable.zip(y2yBeneficiariesRequest, sendMoneyBeneficiariesRequest).subscribe(onNext: { _ in
            YAPProgressHud.hideProgressHud()
        }).disposed(by: disposeBag) */
//        y2yBeneficiariesRequest.subscribe(onNext: { _ in
//            YAPProgressHud.hideProgressHud()
//
//        }).disposed(by: disposeBag)
        
//        sendMoneyBeneficiariesRequest.elements().subscribe(onNext: { benefiearies in
//
//                print("SendMoneyBen are \(benefiearies)")
//
//        }).disposed(by: disposeBag)
//
//        sendMoneyBeneficiariesRequest.errors().subscribe(onNext: { error in
//            print("error found \(error)")
//        }).disposed(by: disposeBag)


        
//        Observable.merge(contactsManager.error, Observable.merge(y2yBeneficiariesRequest.errors(), sendMoneyBeneficiariesRequest.errors()).map{ $0.localizedDescription })
//            .bind(to: errorSubject)
//            .disposed(by: disposeBag)
        
     //   sendMoneyBeneficiariesRequest.elements().bind(to: sendMoneyBeneficiariesSubject).disposed(by: disposeBag)
        //y2yBeneficiariesRequest.elements().bind(to: y2yRecentBeneficiariesSubject).disposed(by: disposeBag)
//        countriesRequest.elements().bind(to: allCountriesSubject).disposed(by: disposeBag)
        
        
        
//        Observable.combineLatest(y2yBeneficiariesRequest.elements(),
//                                 contactsManager.result,
//                                 self.accountProvider.currentAccount.unwrap().map { $0.customer.uuid }.unwrap())
//            .map({ (y2yRecents, contactResult, currentAccountUUID) -> [YAPContact] in
//                var allContacts: [YAPContact] = contactResult
//                allContacts.removeAll { $0.yapAccountDetails?.first?.uuid == currentAccountUUID }
//                allContacts.append(contentsOf: y2yRecents.map({ YAPContact.contact(fromRecentBeneficiary: $0) }))
//                return allContacts.unique() })
//            .bind(to: y2yContactsSubject)
//            .disposed(by: disposeBag)
    }

//    func deleteBeneficiary() {
//
//        deleteBeneficiarySubject.map { _ in true }.bind(to: showActivitySubject).disposed(by: disposeBag)
//
//        let deleteRequest = deleteBeneficiarySubject.flatMap { [unowned self] in self.repository.deleteBeneficiary(String($0.id ?? 0))}.share()
//
//        deleteRequest.errors().map { _ in false }.bind(to: showActivitySubject).disposed(by: disposeBag)
//
//        deleteRequest.errors().map { $0.localizedDescription }.bind(to: showErrorSubject).disposed(by: disposeBag)
//
//        deleteRequest.elements().map { _ in }.bind(to: refreshSubject).disposed(by: disposeBag)
//        deleteRequest.elements().map{ _ in SendMoneyEvent.deleteBeneficiary() }.bind(to: AppAnalytics.shared.rx.logEvent).disposed(by: disposeBag)
//    }
//
    func showLoadingEffects() {
        var dummyObjects: [SendMoneyHomeBeneficiaryCellViewModel] = []
        for _ in 1...12 {
            dummyObjects.append(SendMoneyHomeBeneficiaryCellViewModel())
        }
        allBeneficiaryDataSourceSubject.onNext([SectionModel(model: 0, items: dummyObjects)])
    }
}

fileprivate extension SendMoneyType {
    var title: String? {
        switch self {
        case .local:
            return "Bank transfer"
        case .international:
            return "Send money internationally"
        case .homeCountry:
            return "Send money home"
        default:
            return nil
        }
    }

    var listLabel: String {
        switch self {
        case .local:
            return "All beneficiaries"
        default:
            return "All beneficiaries"
        }
    }

}
