//
//  DashboardTimelineViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 11/04/2022.
//

import Foundation
import RxSwift
import UIKit


public protocol DashboardTimelineViewModelOutputs {
    var icon: Observable<UIImage?> { get }
    var title: Observable<String> {get}
    var desc: Observable<String> {get}
    
    var model: Observable<DashboardTimelineModel> { get }
    var btn: Observable<Void> { get }
}
public protocol DashboardTimelineViewModelInputs {
    var btnObserver: AnyObserver<Void> { get }
}

public protocol DashboardTimelineViewModelType {
    var outputs: DashboardTimelineViewModelOutputs { get }
    var inputs: DashboardTimelineViewModelInputs { get }
}

public class DashboardTimelineViewModel: DashboardTimelineViewModelType, DashboardTimelineViewModelInputs, DashboardTimelineViewModelOutputs {
    
    public var inputs: DashboardTimelineViewModelInputs {self}
    public var outputs: DashboardTimelineViewModelOutputs {self}
    
    
    //MARK: subjects
    private let iconSubject = BehaviorSubject<UIImage?>(value: nil)
    private let titleSubject = BehaviorSubject<String>(value: "")
    private let descSubject = BehaviorSubject<String>(value: "")
    private let modelSubject = ReplaySubject<DashboardTimelineModel>.create(bufferSize: 1)
    private let btnSubject = PublishSubject<Void>()
    
    //MARK: Inputs
    public var btnObserver: AnyObserver<Void> { btnSubject.asObserver() }
    
    //MARK: outputs
    public var icon: Observable<UIImage?> { iconSubject.asObservable() }
    public var title: Observable<String> { titleSubject.asObservable() }
    public var desc: Observable<String> { descSubject.asObservable() }
    public var model: Observable<DashboardTimelineModel> { modelSubject.asObservable() }
    public var btn: Observable<Void> { btnSubject.asObservable() }
    
  //  private let featureFlagClient = FeatureFlagClient()
    private let disposeBag = DisposeBag()
    init(_ model: DashboardTimelineModel) {
        
        iconSubject.onNext(UIImage.init(named: "icon_coin", in: .yapPakistan))
        titleSubject.onNext("Welcome to YAP")
        descSubject.onNext("Add money to your YAP card to start spending")
        
        modelSubject.onNext(model)
    }
}

public struct DashboardTimelineModel {
    var title: String
    var description: String
    var leftIcon: UIImage?
    var isSeparator: Bool
    var isSeparatorVague: Bool
    var isProgress: Bool
    var progressStatus: String
    var isWholeContainerVague: Bool
    var btnTitle: String
    var isBtnHidden: Bool
}
