//
//  WidgetSelectionSectionCellViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 20/04/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift
import RxDataSources
import RxTheme
import UIKit


public protocol WidgetSelectionSectionCellViewModelInputs {
    var switchObserver: AnyObserver<Bool?> {get}
    var setSwitchValueObserver: AnyObserver<Bool> {get}
}

public protocol WidgetSelectionSectionCellViewModelOutputs {
    var hideSwitch: Observable<Bool> {get}
    var text: Observable<(String,UIColor)> {get}
    var switchValue: Observable<Bool> {get}
    var switchValueChanged: Observable<Bool?> {get}
}

public protocol WidgetSelectionSectionCellViewModelType {
    var inputs: WidgetSelectionSectionCellViewModelInputs { get }
    var outputs: WidgetSelectionSectionCellViewModelOutputs { get }
}

class WidgetSelectionSectionCellViewModel: ReusableTableViewCellViewModelType, WidgetSelectionSectionCellViewModelOutputs, WidgetSelectionSectionCellViewModelType, WidgetSelectionSectionCellViewModelInputs {
    
    let disposeBag = DisposeBag()
    var inputs: WidgetSelectionSectionCellViewModelInputs { self }
    var outputs: WidgetSelectionSectionCellViewModelOutputs { self }
    var reusableIdentifier: String { return WidgetSelectionSectionTableViewCell.defaultIdentifier }

    // MARK: - inputs
    var switchObserver: AnyObserver<Bool?> {changedSwitchSubject.asObserver()}
    var setSwitchValueObserver: AnyObserver<Bool> {switchValueSubject.asObserver()}
    
    // MARK: - output
    var hideSwitch: Observable<Bool> { hideSwitchSubject }
    var text: Observable<(String, UIColor)> {textSubject}
    var switchValue: Observable<Bool> {switchValueSubject}
    var switchValueChanged: Observable<Bool?> {changedSwitchSubject}
    
    // MARK: - Subject
    private let hideSwitchSubject = BehaviorSubject<Bool>(value: false)
    private let changedSwitchSubject = BehaviorSubject<Bool?>(value: nil)
    private let switchValueSubject = BehaviorSubject<Bool>(value: false)
    private let textSubject = BehaviorSubject<(String, UIColor)>(value: ("", .lightGray))
    private let themeService: ThemeService<AppTheme>
    
    init(for hidden: Bool, themeService: ThemeService<AppTheme>) {
        self.themeService = themeService
        hideSwitchSubject.onNext(hidden)
        switchValueSubject.onNext(YAPUserDefaults.isWidgetsBarHidden())
        changedSwitchSubject.subscribe(onNext: {
            guard let val = $0 else {return}
            YAPUserDefaults.hideWidgetsBar(for: val)
        }).disposed(by: disposeBag)
        textSubject.onNext(hidden ?("Hidden", UIColor(themeService.attrs.primary)) : ("Hide widgets from dashboard" , UIColor(themeService.attrs.primaryDark)))
    }
}
