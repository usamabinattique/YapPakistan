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
}

protocol LimitsViewModelOutput {
    typealias ResourcesType = LimitsViewModel.ResourcesType
    var showError: Observable<String> { get }
    var loader: Observable<Bool> { get }
    var back: Observable<Void> { get }
    var strings: Observable<ResourcesType> { get }
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

    var inputs: LimitsViewModelInput { return self }
    var outputs: LimitsViewModelOutput { return self }

    // MARK: Inputs
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }

    // MARK: Outputs
    var showError: Observable<String> { showErrorSubject.asObservable() }
    var loader: Observable<Bool> { loaderSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var strings: Observable<ResourcesType> { stringsSubject.asObservable() }

    // MARK: Properties
    let disposeBag = DisposeBag()

    // MARK: Initialization

    init(strings: ResourcesType) {
        self.stringsSubject = BehaviorSubject<ResourcesType>(value: strings)
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
