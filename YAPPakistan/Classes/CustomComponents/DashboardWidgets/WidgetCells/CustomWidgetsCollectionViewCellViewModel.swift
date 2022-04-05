//
//  CustomWidgetsCollectionViewCellViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 04/04/2022.
//

import Foundation
import RxSwift
import RxCocoa

protocol CustomWidgetsCollectionViewCellViewModelOutputs {
    var categoryImage: Observable<ImageWithURL> { get }
    var categoryName: Observable<String?> {get}
    var removeShadow: Observable<WidgetCode> {get}
}
protocol CustomWidgetsCollectionViewCellViewModelType {
    var outputs: CustomWidgetsCollectionViewCellViewModelOutputs {get}
}

public class CustomWidgetsCollectionViewCellViewModel: CustomWidgetsCollectionViewCellViewModelOutputs, CustomWidgetsCollectionViewCellViewModelType, ReusableCollectionViewCellViewModelType   {
    public var reusableIdentifier: String {CustomWidgetsCollectionViewCell.defaultIdentifier}
    var outputs: CustomWidgetsCollectionViewCellViewModelOutputs {self}
    
    //MARK:- Outputs
    var categoryImage: Observable<ImageWithURL> {categoryImageSubject}
    var categoryName: Observable<String?> {categoryNameSubject}
    var removeShadow: Observable<WidgetCode> {removeShadowSubject}
    
    //MARK:- Subjects
    private let categoryImageSubject = BehaviorSubject<ImageWithURL>(value: (nil, nil))
    private let categoryNameSubject = BehaviorSubject<String?>(value: nil)
    private let removeShadowSubject = BehaviorSubject<WidgetCode>(value: .addMoney)
    
    init(widgetData: DashboardWidgetsResponse?) {
        categoryImageSubject.onNext((widgetData?.icon, widgetData?.iconPlaceholder))
        categoryNameSubject.onNext(widgetData?.name)
        
        if widgetData == nil {
            categoryNameSubject.onNext("Edit")
            removeShadowSubject.onNext(WidgetCode.init(rawValue: "Edit") ?? .edit)
           // categoryImageSubject.onNext(("",UIImage.init(named: "icon_edit", in: yapKitBundle, compatibleWith: nil)))
        }
    }
}

public enum WidgetCode: String, Codable {
    case addMoney = "Add money"
    case sendMoney = "Send money"
    case qrCode = "QR code"
    case bills = "Bills"
    case offers = "Offers"
    case coins = "Coins"
    case young = "Young"
    case houseHold = "Household"
    case statements = "Statements"
    case edit = "Edit"
    case unknown
}
