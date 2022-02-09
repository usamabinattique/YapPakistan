//
//  YapItTileCellViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 05/01/2022.
//

import Foundation
import RxSwift
import YAPComponents

protocol YapItTileCellViewModelInput {
    
}

protocol YapItTileCellViewModelOutput {
    var iconName: Observable<String> { get }
    var title: Observable<String> { get }
    var flag: Observable<String?> { get }
}

protocol YapItTileCellViewModelType {
    var inputs: YapItTileCellViewModelInput { get }
    var outputs: YapItTileCellViewModelOutput { get }
}

class YapItTileCellViewModel: YapItTileCellViewModelInput, YapItTileCellViewModelOutput, YapItTileCellViewModelType, ReusableCollectionViewCellViewModelType {
    
    
    var reusableIdentifier: String { YapItTileCell.defaultIdentifier }
    
    var inputs: YapItTileCellViewModelInput { self }
    var outputs: YapItTileCellViewModelOutput { self }
    
    private let disposeBag = DisposeBag()
    
    private let iconNameSubject: BehaviorSubject<String>
    private let titleSubject: BehaviorSubject<String>
    private let flagSubject: BehaviorSubject<String?>
    
    let action: YapItTileAction!
    // MARK: - inputs
    
    // MARK: - Outputs
    
    var iconName: Observable<String> { iconNameSubject.asObservable() }
    var title: Observable<String> { titleSubject.asObservable() }
    var flag: Observable<String?> { flagSubject.asObservable() }
    
    init(_ action: YapItTileAction) {
        self.action = action
        iconNameSubject = BehaviorSubject(value: action.iconName)
        titleSubject = BehaviorSubject(value: action.title)
        
        var country: String? = nil
        if case let YapItTileAction.homeCountry(countryCode) = action {
            country = countryCode
        } else if case let YapItTileAction.localTransfer(countryCode) = action {
            country = countryCode
        }
        
        flagSubject = BehaviorSubject(value: country)
    }
    
}

enum YapItTileAction {
    case topupViaCard
    case bankTransfer
    case cashOrCheque
    case qrCode
    case yapContact
    case localTransfer(_ country: String)
    case internationalTransfer
    case homeCountry(_ country: String)
    case requestMoeny
}

fileprivate extension YapItTileAction {
    var iconName: String {
        switch self {
        case .topupViaCard:
            return "icon_add_money_debit_credit_card"
        case .bankTransfer, .localTransfer, .internationalTransfer:
            return "icon_add_money_bank_transfer"
        case .cashOrCheque:
            return "icon_add_money_cash_cheque"
        case .qrCode:
            return "icon_add_money_qr_code"
        case .yapContact:
            return "icon_add_money_yap_contact"
        case .homeCountry:
            return "icon_add_money_home"
        case .requestMoeny:
            return "icon_add_money_request_money"
        }
    }
    
    var title: String {
        switch self {
        case .topupViaCard:
            return "Debit/Credit Card"
        case .bankTransfer:
            return "Bank transfer"
        case .cashOrCheque:
            return "Cash or cheque"
        case .qrCode:
            return "QR code"
        case .yapContact:
            return "YAP contact"
        case .internationalTransfer:
            return "International transfer"
        case .localTransfer:
            return "Local bank"
        case .homeCountry:
            return "Home country"
        case .requestMoeny:
            return "Request money"
        }
    }
}
