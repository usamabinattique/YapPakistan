//
//  LimitsViewModelType.swift
//  ios-b2c-pk-components
//
//  Created by Sarmad on 29/11/2021.
//

import CardScanner
import Foundation
import RxSwift
import YAPComponents
protocol LimitsViewModelInput {
    var backObserver: AnyObserver<Void> { get }
    var withdrawlObserver: AnyObserver<Bool> { get }
    var retailObserver: AnyObserver<Bool> { get }
}

protocol LimitsViewModelOutput {
    typealias ResourcesType = LimitsViewModel.ResourcesType
    var showError: Observable<String> { get }
    var loader: Observable<Bool> { get }
    var back: Observable<Void> { get }
    var strings: Observable<ResourcesType> { get }

    var withdrawl: Observable<Bool> { get }
    var retail: Observable<Bool> { get }
}

protocol LimitsViewModelType {
    var inputs: LimitsViewModelInput { get }
    var outputs: LimitsViewModelOutput { get }
}

class LimitsViewModel: LimitsViewModelInput, LimitsViewModelOutput, LimitsViewModelType {

    let showErrorSubject = PublishSubject<String>()
    var loaderSubject = BehaviorSubject<Bool>(value: false)
    var backSubject = PublishSubject<Void>()
    var stringsSubject: BehaviorSubject<ResourcesType>

    var withdrawlSubject = PublishSubject<Bool>()
    var retailSubject = PublishSubject<Bool>()

    var withdrawlResultSubject = PublishSubject<Bool>()
    var retailResultSubject = PublishSubject<Bool>()

    var inputs: LimitsViewModelInput { return self }
    var outputs: LimitsViewModelOutput { return self }

    // MARK: Inputs
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    var withdrawlObserver: AnyObserver<Bool> { withdrawlSubject.asObserver() }
    var retailObserver: AnyObserver<Bool> { retailSubject.asObserver() }

    // MARK: Outputs
    var showError: Observable<String> { showErrorSubject.asObservable() }
    var loader: Observable<Bool> { loaderSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var strings: Observable<ResourcesType> { stringsSubject.asObservable() }
    var withdrawl: Observable<Bool>  { withdrawlResultSubject.asObservable() }
    var retail: Observable<Bool> { retailResultSubject.asObservable() }

    // MARK: Properties
    let disposeBag = DisposeBag()
    let paymentCard: PaymentCard
    let repository: CardsRepositoryType

    // MARK: Initialization

    init(strings: ResourcesType, paymentCard: PaymentCard, repository: CardsRepositoryType) {
        self.stringsSubject = BehaviorSubject<ResourcesType>(value: strings)
        self.paymentCard = paymentCard
        self.repository = repository

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            if paymentCard.blocked == true {
                self.withdrawlResultSubject.onNext(false)
                self.retailResultSubject.onNext(false)
            } else {
                self.withdrawlResultSubject.onNext(paymentCard.atmAllowed ?? false)
                self.retailResultSubject.onNext(paymentCard.retailPaymentAllowed ?? false)
            }
        }

        let withdrawlCall = self.withdrawlSubject.withUnretained(self).share()
        let withdrawl = withdrawlCall
            .filter({ `self`, _ in self.paymentCard.blocked == false })
            .do(onNext: { `self`, _ in self.loaderSubject.onNext(true) })
            .flatMapLatest{ `self`, _ in
                repository.configAllowAtm(cardSerialNumber: self.paymentCard.cardSerialNumber ?? "")
            }
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
            .share()
        withdrawl.elements().withLatestFrom(withdrawlResultSubject).map { !$0 }
            // .bind(to: withdrawlResultSubject)
            .subscribe(onNext: { [weak self] in
                if let value = self?.paymentCard.atmAllowed {
                    self?.paymentCard.atmAllowed = !value
                }
            })
            .disposed(by: disposeBag)


        let retailCall = self.retailSubject.withUnretained(self).share()
        let retail = retailCall
            .filter({ `self`, _ in self.paymentCard.blocked == false })
            .do(onNext: { `self`, _ in self.loaderSubject.onNext(true) })
            .flatMapLatest{ `self`, _ in
                repository.configRetailPayment(cardSerialNumber: self.paymentCard.cardSerialNumber ?? "")
            }
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
            .share()

        retail.elements().withLatestFrom(retailResultSubject).map { !$0 }
            .subscribe(onNext: { [weak self] in
                if let value = self?.paymentCard.retailPaymentAllowed {
                    self?.paymentCard.retailPaymentAllowed = !value
                }
            })
            //.bind(to: retailResultSubject)
            .disposed(by: disposeBag)

        retailCall.merge(with: withdrawlCall)
            .filter({ `self`, _ in self.paymentCard.blocked == true })
            .map({ _ in "Card already blocked" })
            .bind(to: showErrorSubject)
            .disposed(by: disposeBag)
    }

    struct ResourcesType {
        var title: String
        var cellsData: [(title: String, detail: String, isOn: Bool)] = []
    }
}



/*
protocol LimitsViewModelInput {
    var backObserver: AnyObserver<Void> { get }
}

protocol LimitsViewModelOutput {
    typealias ResourcesType = LimitsViewModel.ResourcesType
    var optionViewModels: Observable<[TitleDetailCellViewModel]> { get }
    var showError: Observable<String> { get }
    var loader: Observable<Bool> { get }
    var strings: Observable<ResourcesType> { get }
}

protocol LimitsViewModelType {
    var inputs: LimitsViewModelInput { get }
    var outputs: LimitsViewModelOutput { get }
}

class LimitsViewModel: LimitsViewModelInput, LimitsViewModelOutput, LimitsViewModelType {

    var optionViewModelsSubject = BehaviorSubject<[TitleDetailCellViewModel]>(value: [])
    let showErrorSubject = PublishSubject<String>()
    var loaderSubject = BehaviorSubject<Bool>(value: false)
    var backSubject = PublishSubject<Void>()
    var stringsSubject: BehaviorSubject<ResourcesType>

    var inputs: LimitsViewModelInput { return self }
    var outputs: LimitsViewModelOutput { return self }

    // MARK: Inputs
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }

    // MARK: Outputs
    var optionViewModels: Observable<[TitleDetailCellViewModel]> { optionViewModelsSubject.asObservable() }
    var showError: Observable<String> { showErrorSubject.asObservable() }
    var loader: Observable<Bool> { loaderSubject.asObserver() }
    var strings: Observable<ResourcesType> { stringsSubject.asObservable() }

    // MARK: Properties
    let disposeBag = DisposeBag()
    private let cellViewModel: Observable<[TitleDetailCellViewModel]>

    // MARK: Initialization

    init(strings: ResourcesType) {

        self.stringsSubject = BehaviorSubject<ResourcesType>(value: strings)
        self.cellViewModel = Observable
            .just(strings.cellsData.map{ cell -> TitleDetailCellViewModel in
                let cellVM = TitleDetailCellViewModel()
                cellVM.inputs.titleObserver.onNext(cell.title)
                cellVM.inputs.detailObserver.onNext(cell.detail)
                cellVM.inputs.selectedObserver.onNext(cell.isOn)
                return cellVM
            })

        self.cellViewModel
            .bind(to: optionViewModelsSubject)
            .disposed(by: disposeBag)

        //        self.cellViewModel.subscribe(onNext: { vms in
        //            let oss = vms.map({ $0.outputs.selected })
        //            oss.forEach { [unowned self] isSelected in
        //                isSelected.filter({ $0 })
        //                    .distinctUntilChanged()
        //                    .bind(to: self.isNextEnableSubject).disposed(by: self.disposeBag)
        //            }
        //        }).disposed(by: disposeBag)

    }

    struct ResourcesType {
        var title: String
        var cellsData: [(title: String, detail: String, isOn: Bool)] = []
    }
}

*/
