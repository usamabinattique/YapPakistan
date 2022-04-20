//
//  WidgetSelectionViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 20/04/2022.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents
import RxTheme
//import Networking

class WidgetSelectionViewModel {
    
    //MARK: Subjects
    private let backButtonSubject = PublishSubject<Void>()
    private let popupCancelSubject = PublishSubject<Void>()
    private let swapSubject = BehaviorSubject<(IndexPath?, IndexPath?)>(value: (nil, nil))
    private let topHeadingSubject = BehaviorSubject<String?>(value: nil)
    private let reloadSubject = PublishSubject<Void>()
    private let apiRespondedSubject = PublishSubject<Bool>()
    private let switchSubject = BehaviorSubject<Bool?>(value: nil)
    private let hideCellSubject = BehaviorSubject<Int?>(value: nil)
    private let errorSubject = PublishSubject<String>()
    private let viewDidAppearSubject = PublishSubject<Void>()
    private let showLoaderSubject = BehaviorSubject<Bool?>(value: nil)
    
    //MARK: inputs
    var backObserver: AnyObserver<Void> { backButtonSubject.asObserver() }
    var swap: AnyObserver<(IndexPath?, IndexPath?)> { swapSubject.asObserver() }
    var hideCellObserver: AnyObserver<Int?> { hideCellSubject.asObserver() }
    var cancelClickObserver: AnyObserver<Void> { popupCancelSubject.asObserver() }
    var viewDidAppearObserver: AnyObserver<Void> {viewDidAppearSubject.asObserver()}
    
    //MARK: outputs
    var topHeading: Observable<String?> { topHeadingSubject }
    var back: Observable<Bool> { apiRespondedSubject }
    var reload: Observable<Void> { reloadSubject }
    var isSwitchOn: Observable<Bool?> { switchSubject }
    var showLoader: Observable<Bool?> { showLoaderSubject }
    
    private let disposeBag = DisposeBag()
//    private let repository = AccountRepository()
    var viewModels: [[ReusableTableViewCellViewModelType]] = [[],[]]
    var widgetsData: [DashboardWidgetsResponse] = []
    var initialState: [DashboardWidgetsResponse] = []
   //private let featureFlagClient = FeatureFlagClient()
    private var repository: CardsRepositoryType
    private let themeService: ThemeService<AppTheme>

    init(accountProvider: AccountProvider,cardsRepository: CardsRepositoryType, themeService: ThemeService<AppTheme>) {
        self.themeService = themeService
        self.repository = cardsRepository
        topHeadingSubject.onNext("Edit dashboard widgets")
        hideCellSubject.subscribe(onNext: {[weak self] in
            guard let val = $0 else {return}
            self?.hideCell(index: val)
        }).disposed(by: disposeBag)
        
        swapSubject.subscribe(onNext: {[weak self] in
            guard let section = $0.1?.section else {return}
            if section == 1 {
                self?.shuffleToHiddenBox(source: $0.0?.row ?? 0)
            }
            else {
                self?.changeShuffleIndexes(source: $0.0?.row ?? 0, destination: $0.1?.row ?? 0)
            }
        }).disposed(by: disposeBag)
        
        getWidgetsItems()
        let customer_uuid = accountProvider.currentAccountValue.value?.customer.uuid ?? ""
        createRequestModel(uuid: UUID().uuidString, customer_uuid: customer_uuid)
        
    }
    
    func changeShuffleIndexes(source: Int, destination: Int){
        
        var shuffledCell = widgetsData[source]
        shuffledCell.shuffleIndex = destination
        
        for index in 0..<widgetsData.count {
            if widgetsData[index].name == shuffledCell.name {
                widgetsData.remove(at: index)
                widgetsData.insert(shuffledCell, at: destination)
                fetchData()
                return
            }
        }
    }
    
    func bindCateogryWithFeatureFlag(widgetsData: [DashboardWidgetsResponse]) {
        var widgetCellsData = widgetsData
        /*featureFlagClient.getFeatureFlag
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: {[unowned self] flag in
                if !flag {
                    widgetCellsData = widgetsData.filter { $0.name != "Bills" }
                }
                self.manageData(widgets: widgetCellsData)
            }).disposed(by: disposeBag)
        featureFlagClient.requestFeatureFlag.onNext(.billPayments) */
    }
    
    func manageData(widgets: [DashboardWidgetsResponse]) {
        self.widgetsData = widgets.filter {$0.status == true}
        let hiddenData = widgets.filter {$0.status == false}
        self.widgetsData.append(contentsOf: hiddenData)
        self.initialState = self.widgetsData
        
        fetchData()
    }
    
    func shuffleToHiddenBox(source: Int) {
        var shuffledCell = widgetsData[source]
        shuffledCell.shuffleIndex = 0
        shuffledCell.status = false
        
        for index in 0..<widgetsData.count {
            if widgetsData[index].name == shuffledCell.name {
                widgetsData.remove(at: index)
                widgetsData.insert(shuffledCell, at: widgetsData.count - 1)
                fetchData()
                return
            }
        }
    }
    
    func fetchData() {
        let firstSectionData = self.widgetsData.filter {$0.status ?? true}
        viewModels = [[],[]]
        for data in firstSectionData {
            let vm = WidgetsCellViewModel(for: true, data: data)
            viewModels[0].append(vm)
        }
        
        let secondSectionData = self.widgetsData.filter {!($0.status ?? true) }
        for data in secondSectionData {
           let vm = HiddenWidgetsCellViewModel(for: false, data: data)
            viewModels[1].append(vm)
            vm.outputs.addButtonClicked.subscribe(onNext: {[weak self] in
                self?.addCategory(value: $0)
            }).disposed(by: disposeBag)
        }
        
        self.widgetsData = []
        self.widgetsData.append(contentsOf: firstSectionData)
        self.widgetsData.append(contentsOf: secondSectionData)
        
        reloadSubject.onNext(())
    }
    
    func addCategory(value: String?) {
        guard let val = value else { return }
        
        guard var updatedData = self.widgetsData.filter({$0.name == val}).first else {return}
        updatedData.status = true
        
        let numberOfVisibleCells = self.widgetsData.filter { $0.status == true }.count
        
        for index in 0..<widgetsData.count {
            if widgetsData[index].name == val {
                widgetsData.remove(at: index)
                widgetsData.insert(updatedData, at: numberOfVisibleCells)
                fetchData()
            }
        }
    }
    
    func hideCell(index: Int) {
        
        var cellToBeUpdated = self.widgetsData[index]
        cellToBeUpdated.status = false
        cellToBeUpdated.shuffleIndex = 0
        self.widgetsData.remove(at: index)
        self.widgetsData.append(cellToBeUpdated)
        
        fetchData()
    }
    
    func createWigetRequest()->[DashboardWidgetsRequest] {
        
        var request: [DashboardWidgetsRequest] = []
    
        for index in 0..<widgetsData.count {
            self.widgetsData[index].shuffleIndex = widgetsData[index].status ?? false ? index : 0
            request.append(DashboardWidgetsRequest(id: self.widgetsData[index].id ?? 0, status: self.widgetsData[index].status ?? false, shuffleIndex: self.widgetsData[index].shuffleIndex ?? 0))
        }
        return request
    }
    
    func createRequestModel(uuid: String, customer_uuid: String){
        
        let request = backButtonSubject
            .do(onNext: {[weak self] _ in self?.showLoaderSubject.onNext(true) })
            .flatMap { [unowned self] _ in
                self.repository.updateDashboardWidgets(widgets: self.createWigetRequest(), uuid: uuid, customer_uuid: customer_uuid)
            }
            .share(replay: 1, scope: .whileConnected)
        
        request.elements().subscribe(onNext: {[weak self] _ in
            self?.apiRespondedSubject.onNext(self?.isSequenceChanged ?? false)
            self?.showLoaderSubject.onNext(false)
        }).disposed(by: disposeBag)
        
        request
            .errors()
            .do(onNext: {[weak self] _ in
                self?.showLoaderSubject.onNext(false)
            })
            .map{$0.localizedDescription}
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
    }
    
    func getWidgetsItems() {
        
        let request = viewDidAppearSubject
            .do(onNext: {[weak self] in
                self?.showLoaderSubject.onNext(true) })
            .flatMap { [unowned self] _ in self.repository.getDashboardWidgets() }
            .share(replay: 1, scope: .whileConnected)
        
        request.elements()
            .subscribe(onNext: {[weak self] widgets in
                self?.showLoaderSubject.onNext(false)
                self?.bindCateogryWithFeatureFlag(widgetsData: widgets)
        }).disposed(by: disposeBag)
        
        request
            .errors()
            .do(onNext: { [weak self] _ in
            self?.showLoaderSubject.onNext(false) })
            .map{$0.localizedDescription}
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
    }
}

extension WidgetSelectionViewModel {
    // return custom viewModel for
    public func sectionViewModel(for section: Int) -> ReusableTableViewCellViewModelType {
        if section == 0 {
            let section = WidgetSelectionSectionCellViewModel(for: false, themeService: themeService)
            
            section.outputs.switchValueChanged.subscribe(onNext: {[weak self] in
                self?.switchSubject.onNext($0)
            }).disposed(by: disposeBag)
            
            self.popupCancelSubject.subscribe(onNext: {
                section.setSwitchValueObserver.onNext(false)
            }).disposed(by: disposeBag)
            return section
        }
        else {
            return WidgetSelectionSectionCellViewModel(for: true, themeService: themeService)
        }
    }
    
    public func cellViewModel(for indexPath: IndexPath) -> ReusableTableViewCellViewModelType {
        let viewModel = self.viewModels[indexPath.section][indexPath.row]
        return viewModel
    }
    
    public var numberOfSections: Int {
        return self.viewModels.count
    }
    
    public func numberOfRows(inSection section: Int) -> Int {
        return self.viewModels[section].count
    }
}

extension WidgetSelectionViewModel {
    
    var isSequenceChanged: Bool {
        for index in 0..<self.widgetsData.count {
            if self.initialState[index].name != widgetsData[index].name || self.initialState[index].status != widgetsData[index].status {
                return true
            }
        }
        return false
    }
}
