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
    var allBeneficiaryDataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }

    var sendMoney: Observable<SendMoneyBeneficiary> { get }
    var showActivity: Observable<Bool> { get }
    var editBeneficiary: Observable<SendMoneyBeneficiary> { get }
    var searchBeneficiaries: Observable<[SendMoneyBeneficiary]> { get }
    var recentBeneficiaryViewModel: RecentBeneficiaryViewModelType { get }
    var title: Observable<String?> { get }
    var listLabel: Observable<String?> { get }
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

    private let recentBeneficiariesViewModel = RecentBeneficiaryViewModel()

    private let closeSubject = PublishSubject<Void>()
    private let addSubject = PublishSubject<Void>()
    private let refreshSubject = PublishSubject<Void>()
    private let beneficiaryAvailableSubject = BehaviorSubject<Bool>(value: false)
    private let recentBeneficiaryAvailableSubject = BehaviorSubject<Bool>(value: false)
    private let showErrorSubject = PublishSubject<String>()
    private let showActivitySubject = PublishSubject<Bool>()

    private let allBeneficiaryDataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
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
    var allBeneficiaryDataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return allBeneficiaryDataSourceSubject.asObservable() }
    var recentBeneficiaryAvailable: Observable<Bool> { return recentBeneficiaryAvailableSubject.asObservable() }
    var sendMoney: Observable<SendMoneyBeneficiary> { return sendMoneySubject.asObservable() }
    var showActivity: Observable<Bool> { return showActivitySubject.asObservable() }
    var editBeneficiary: Observable<SendMoneyBeneficiary> { return editBeneficiarySubject.asObservable() }
    var searchBeneficiaries: Observable<[SendMoneyBeneficiary]> { return searchBeneficiariesSubject.asObservable() }
    var recentBeneficiaryViewModel: RecentBeneficiaryViewModelType { recentBeneficiariesViewModel }
    var title: Observable<String?> { titleSubject.asObservable() }
    var listLabel: Observable<String?> { listLabelSubject.asObservable() }

    // MARK: - Init
    init(repository: YapItRepositoryType, sendMoneyType: SendMoneyType) {
        self.repository = repository
        self.sendMoneyType = sendMoneyType

        titleSubject = BehaviorSubject(value: sendMoneyType.title)
        listLabelSubject = BehaviorSubject(value: sendMoneyType.listLabel)

//        fetchBeneficiaries()
//        deleteBeneficiary()
        


        allBeneficiaryDataSourceSubject.map { $0.count > 0 }.bind(to: beneficiaryAvailableSubject).disposed(by: disposeBag)

        /// firebase event logging
//        sendMoneySubject.map{ _ in SendMoneyEvent.beneficiaryTapped() }.bind(to: AppAnalytics.shared.rx.logEvent).disposed(by: disposeBag)
//        addSubject.map{ _ in SendMoneyEvent.addBeneficiary() }.bind(to: AppAnalytics.shared.rx.logEvent).disposed(by: disposeBag)
//        editBeneficiarySubject.map{ _ in SendMoneyEvent.editBeneficiary() }.bind(to: AppAnalytics.shared.rx.logEvent).disposed(by: disposeBag)
    }
}
/*
private extension SendMoneyHomeViewModel {
    func fetchBeneficiaries() {

        let allBeneficiariesRequest = refreshSubject.withLatestFrom(showActivitySubject.startWith(false))
            .do(onNext: { [weak self] in if !$0 { self?.showLoadingEffects() } })
            .flatMap { [unowned self] _ in self.repository.fetchBeneficiaries() }.share()

        allBeneficiariesRequest.map { _ in false }.bind(to: showActivitySubject).disposed(by: disposeBag)

        allBeneficiariesRequest.errors().map { $0.localizedDescription }.bind(to: showErrorSubject).disposed(by: disposeBag)

        allBeneficiariesRequest.errors().subscribe(onNext: { [weak self] (_) in
            self?.allBeneficiaryDataSourceSubject.onNext([SectionModel(model: 0, items: [])])
        }).disposed(by: disposeBag)

        let allBeneficiaries = allBeneficiariesRequest.elements().withLatestFrom(Observable.combineLatest(allBeneficiariesRequest.elements(), SessionManager.current.currentAccount.map{ $0?.customer.homeCountry2Digit }.unwrap()))
            .map{ [unowned self] beneficiaries, homeCountry -> [SendMoneyBeneficiary] in
                switch self.sendMoneyType {
                case .local:
                    return beneficiaries.filter{ $0.type == .uaefts || $0.type == .domestic }
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
            .bind(to: allBeneficiaryDataSourceSubject)
            .disposed(by: disposeBag)

        allBeneficiaries.map { $0.count > 0 }.bind(to: beneficiaryAvailableSubject).disposed(by: disposeBag)

        searchObserverSubject.withLatestFrom(allBeneficiaries).bind(to: searchBeneficiariesSubject).disposed(by: disposeBag)

        let recentBeneficiaries = allBeneficiaries.map{ $0.filter{ $0.lastTranseferDate != nil }.sorted{ $0.beneficiaryLasTransferDate > $1.beneficiaryLasTransferDate }.prefix(15) }

        recentBeneficiaries.map{ $0.count > 0 }.bind(to: recentBeneficiaryAvailableSubject).disposed(by: disposeBag)

        recentBeneficiaries.map{ $0.map{ $0 as RecentBeneficiaryType }.indexed }.bind(to: recentBeneficiariesViewModel.inputs.recentBeneficiaryObserver).disposed(by: disposeBag)

        recentBeneficiariesViewModel.outputs.itemSelected
            .withLatestFrom(Observable.combineLatest(recentBeneficiariesViewModel.outputs.itemSelected, recentBeneficiaries))
            .map{ $0.1[$0.0] }
            .bind(to: sendMoneySubject)
            .disposed(by: disposeBag)
    }

    func deleteBeneficiary() {

        deleteBeneficiarySubject.map { _ in true }.bind(to: showActivitySubject).disposed(by: disposeBag)

        let deleteRequest = deleteBeneficiarySubject.flatMap { [unowned self] in self.repository.deleteBeneficiary(String($0.id ?? 0))}.share()

        deleteRequest.errors().map { _ in false }.bind(to: showActivitySubject).disposed(by: disposeBag)

        deleteRequest.errors().map { $0.localizedDescription }.bind(to: showErrorSubject).disposed(by: disposeBag)

        deleteRequest.elements().map { _ in }.bind(to: refreshSubject).disposed(by: disposeBag)
        deleteRequest.elements().map{ _ in SendMoneyEvent.deleteBeneficiary() }.bind(to: AppAnalytics.shared.rx.logEvent).disposed(by: disposeBag)
    }

    func showLoadingEffects() {
        var dummyObjects: [SendMoneyHomeBeneficiaryCellViewModel] = []
        for _ in 1...12 {
            dummyObjects.append(SendMoneyHomeBeneficiaryCellViewModel())
        }
        allBeneficiaryDataSourceSubject.onNext([SectionModel(model: 0, items: dummyObjects)])
    }
}
*/
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
            return "All local beneficiaries"
        default:
            return "All beneficiaries"
        }
    }

}
