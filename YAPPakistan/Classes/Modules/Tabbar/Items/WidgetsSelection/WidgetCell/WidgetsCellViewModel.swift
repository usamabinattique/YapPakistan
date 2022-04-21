//
//  WidgetsCellViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 20/04/2022.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents

public protocol WidgetsCellViewModelInputs {
    var addButtonObserver: AnyObserver<String?> {get}
}

public protocol WidgetsCellViewModelOutputs {
    var trailingIcon: Observable<UIImage?> {get}
    var leadingIcon: Observable<ImageWithURL?> {get}
    var labelText: Observable<String> {get}
    var iconConstraint: Observable<CGFloat?> { get }
    var addButtonClicked: Observable<String?> {get}
}

public protocol WidgetsCellViewModelType {
    var inputs: WidgetsCellViewModelInputs { get }
    var outputs: WidgetsCellViewModelOutputs { get }
}

class WidgetsCellViewModel: ReusableTableViewCellViewModelType, WidgetsCellViewModelType, WidgetsCellViewModelInputs, WidgetsCellViewModelOutputs {
    
    var reusableIdentifier: String {WidgetsTableViewCell.defaultIdentifier}
    
    var inputs: WidgetsCellViewModelInputs {self}
    var outputs: WidgetsCellViewModelOutputs {self}
    
    //MARK:- inputs
    var addButtonObserver: AnyObserver<String?> { addButtonClickedSubject.asObserver() }
    
    
    //MARK:- Outputs
    var iconConstraint: Observable<CGFloat?> {iconConstraintSubject}
    var labelText: Observable<String> {labelTextSubject}
    var trailingIcon: Observable<UIImage?> {trailingIconSubject}
    var leadingIcon: Observable<ImageWithURL?> {leadingIconSubject.asObservable()}
    var addButtonClicked: Observable<String?> { addButtonClickedSubject }
   
    
    //MARK:- Subjects
    private let labelTextSubject = BehaviorSubject<String>(value: "")
    private let trailingIconSubject = BehaviorSubject<UIImage?>(value: nil)
    private let leadingIconSubject = BehaviorSubject<ImageWithURL?>(value: nil)
    private let iconConstraintSubject = BehaviorSubject<CGFloat?>(value: nil)
    private let addButtonClickedSubject = BehaviorSubject<String?>(value: nil)
    
    init(for hidden: Bool? = false, data: DashboardWidgetsResponse? = nil) {
        
        trailingIconSubject.onNext(((hidden ?? false ? nil : UIImage(named: "icon_add", in: .yapPakistan, compatibleWith: .none))))
        leadingIconSubject.onNext((data?.icon, data?.iconPlaceholder))
        iconConstraintSubject.onNext(hidden ?? false ? 55 : 22)
        labelTextSubject.onNext(data?.name ?? "unknown")
    }
}
