//
//  DashboardWidgetsViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 04/04/2022.
//

import Foundation
import RxSwift
import RxDataSources


public protocol DashboardWidgetsViewModelOutputs {
    var dataSource: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
    var selectedWidget: Observable<WidgetCode?> {get}
    var scrollToTop: Observable<Void> {get}
}
public protocol DashboardWidgetsViewModelInputs {
    var modelObserver: AnyObserver <CustomWidgetsCollectionViewCellViewModel?> {get}
    var widgetsDataObserver: AnyObserver <[DashboardWidgetsResponse]?> {get}
}

public protocol DashboardWidgetsViewModelType {
    var outputs: DashboardWidgetsViewModelOutputs { get }
    var inputs: DashboardWidgetsViewModelInputs { get }
}

public class DashboardWidgetsViewModel: DashboardWidgetsViewModelType, DashboardWidgetsViewModelInputs, DashboardWidgetsViewModelOutputs {
    
    public var inputs: DashboardWidgetsViewModelInputs {self}
    public var outputs: DashboardWidgetsViewModelOutputs{self}
    
    public var modelObserver: AnyObserver<CustomWidgetsCollectionViewCellViewModel?> { return modelObserverSubject.asObserver() }
    public var widgetsDataObserver: AnyObserver<[DashboardWidgetsResponse]?> { widgetsDataSubject.asObserver() }
    
    //MARK: subjects
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>(value: [])
    private let selectedCellNameSubject = BehaviorSubject<String?>(value: nil)
    private let selectedWidgetSubject = BehaviorSubject<WidgetCode?>(value: nil)
    private let modelObserverSubject = BehaviorSubject<CustomWidgetsCollectionViewCellViewModel?>(value: nil)
    private let widgetsDataSubject = BehaviorSubject<[DashboardWidgetsResponse]?>(value: nil)
    private let scrollToTopSubject = PublishSubject<Void>()
    
    //MARK: outputs
    public var dataSource: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> {dataSourceSubject}
    public var selectedWidget: Observable<WidgetCode?> {selectedWidgetSubject}
    public var scrollToTop: Observable<Void> {scrollToTopSubject}
    
  //  private let featureFlagClient = FeatureFlagClient()
    private let disposeBag = DisposeBag()
    public init() {
        
        widgetsDataSubject.subscribe(onNext: { [weak self] in
            guard let data = $0 else { return }
            self?.bindCateogryWithFeatureFlag(widgetsData: data)
        }).disposed(by: disposeBag)
        
        modelObserverSubject.subscribe(onNext: {[weak self] in
            guard let selectedModel = $0 else {return}
            self?.getClickedCell(model: selectedModel)
        }).disposed(by:disposeBag )
    }
    
    func bindCateogryWithFeatureFlag(widgetsData: [DashboardWidgetsResponse]) {
//        featureFlagClient.getFeatureFlag
//            .observe(on: MainScheduler.asyncInstance)
//            .subscribe(onNext: {[unowned self] flag in
//                self.createCellViewModels(widgetsData: widgetsData, featureFlag: flag)
//        }).disposed(by: disposeBag)
//        featureFlagClient.requestFeatureFlag.onNext(.billPayments)
        
        self.createCellViewModels(widgetsData: widgetsData, featureFlag: false)
    }
    
    func createCellViewModels(widgetsData: [DashboardWidgetsResponse], featureFlag: Bool) {
        var viewModels: [CustomWidgetsCollectionViewCellViewModel] = []
        
        var shownData = widgetsData.filter { ($0.status ?? false)}
        if !featureFlag {
            shownData = shownData.filter { $0.name != "Bills" }
        }
        
        for widget in shownData {
            let vm = CustomWidgetsCollectionViewCellViewModel(widgetData: widget)
            viewModels.append(vm)
        }
        if viewModels.count > 0 {
            let edit =  CustomWidgetsCollectionViewCellViewModel(widgetData: nil)
            viewModels.append(edit)
            dataSourceSubject.onNext([SectionModel(model: 0, items: viewModels)])
            scrollToTopSubject.onNext(())
        }
    }
    
    func getClickedCell(model: CustomWidgetsCollectionViewCellViewModel) {
        var catName = ""
        model.categoryName.subscribe(onNext: {
            catName = $0 ?? ""
        }).disposed(by: disposeBag)
        let selectedWidget = WidgetCode.init(rawValue: catName)
        selectedWidgetSubject.onNext(selectedWidget)
    }
}
