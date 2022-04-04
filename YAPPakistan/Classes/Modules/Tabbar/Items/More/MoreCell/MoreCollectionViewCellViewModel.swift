//
//  MoreCollectionViewCellViewModel.swift
//  YAP
//
//  Created by Zain on 19/09/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents

protocol MoreCollectionViewCellViewModelInput {
    var badgeObserver: AnyObserver<String?> { get }
}

protocol MoreCollectionViewCellViewModelOutput {
    var icon: Observable<UIImage?> { get }
    var title: Observable<String?> { get }
    var notifications: Observable<String?> { get }
    var badge: Observable<String?> { get }
//    var accounType: Observable<AccountType> { get }
    var disableCell: Observable<Bool?>{ get }
}

protocol MoreCollectionViewCellViewModelType {
    var inputs: MoreCollectionViewCellViewModelInput { get }
    var outputs: MoreCollectionViewCellViewModelOutput { get }
}

class MoreCollectionViewCellViewModel: MoreCollectionViewCellViewModelType, MoreCollectionViewCellViewModelInput, MoreCollectionViewCellViewModelOutput, ReusableCollectionViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: MoreCollectionViewCellViewModelInput { return self }
    var outputs: MoreCollectionViewCellViewModelOutput { return self }
    var reusableIdentifier: String { return MoreCollectionViewCell.defaultIdentifier }
    
    private let iconSubject = BehaviorSubject<UIImage?>(value: nil)
    private let titleSubject = BehaviorSubject<String?>(value: nil)
    private let notificationsSubject = BehaviorSubject<String?>(value: nil)
    private let badgeSubject = BehaviorSubject<String?>(value: nil)
//    private let accounTypeSubject = BehaviorSubject<AccountType>(value: .b2cAccount)
    private let disableCellSubject = BehaviorSubject<Bool?>(value: nil)
    
    // MARK: - Inputs
    var badgeObserver: AnyObserver<String?> { badgeSubject.asObserver() }
    
    // MARK: - Outputs
    var icon: Observable<UIImage?> { return iconSubject.asObservable() }
    var title: Observable<String?> { return titleSubject.asObservable() }
    var notifications: Observable<String?> { return notificationsSubject.asObservable() }
    var badge: Observable<String?> { return badgeSubject.asObservable() }
//    var accounType: Observable<AccountType> { accounTypeSubject.asObservable() }
    var disableCell: Observable<Bool?>{ return disableCellSubject.asObservable() }
    
    let cellType: MoreCollectionViewCellViewModel.CellType!
    
    // MARK: - Init
    init(_ cellType: MoreCollectionViewCellViewModel.CellType) {
        self.cellType = cellType
        iconSubject.onNext(cellType.icon)
        titleSubject.onNext(cellType.title)
        if cellType == .notifications {
            badgeSubject.onNext(nil)
        }
        
        if cellType == .subscriptions || cellType == .yapBusiness || cellType == .gifts  {
            disableCellSubject.onNext(true)
        }
//        accounTypeSubject.onNext(accountType)
    }
}

extension MoreCollectionViewCellViewModel {
    enum CellType {
        case notifications
        case locateAtm
        case inviteAFriend
        case help
        case subscriptions
        case yapBusiness
        case termsAndConditions
        case yapForYou
        case gifts
    }
}

fileprivate extension MoreCollectionViewCellViewModel.CellType {
    
    var title: String? {
        switch self {
        case .notifications:
            return "screen_more_home_display_text_tile_notification".localized
        case .locateAtm:
            return "screen_more_home_display_text_atm_cdm".localized
        case .inviteAFriend:
            return "screen_more_home_display_text_tile_invite_friend".localized
        case .help:
            return "screen_more_home_display_text_tile_help".localized
        case .subscriptions:
            return "screen_more_home_display_text_tile_subscriptions".localized
        case .yapBusiness:
            return "screen_more_home_display_text_tile_business".localized
        case .termsAndConditions:
            return "screen_more_home_display_text_tile_terms".localized
        case .yapForYou:
            return "screen_more_home_display_text_yap_for_you_title".localized
        case .gifts:
            return "screen_more_home_display_text_tile_gift".localized
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .notifications:
            return UIImage(named: "icon_notifications", in: .yapPakistan)?.withRenderingMode(.alwaysOriginal)
        case .locateAtm:
            return UIImage(named: "icon_locate_atm", in: .yapPakistan)?.withRenderingMode(.alwaysOriginal)
        case .inviteAFriend:
            return UIImage(named: "icon_invite_friend", in: .yapPakistan)?.withRenderingMode(.alwaysOriginal)
        case .help:
            return UIImage(named: "icon_help_support", in: .yapPakistan)?.withRenderingMode(.alwaysOriginal)
        case .subscriptions:
            return UIImage(named: "icon_subscription", in: .yapPakistan)?.withRenderingMode(.alwaysOriginal)
        case .yapBusiness:
            return UIImage(named: "icon_business", in: .yapPakistan)?.withRenderingMode(.alwaysOriginal)
        case .termsAndConditions:
            return UIImage(named: "icon_terms_conditions", in: .yapPakistan)?.withRenderingMode(.alwaysOriginal)
        case .yapForYou:
            return UIImage(named: "icon_yap_for_you", in: .yapPakistan)?.withRenderingMode(.alwaysOriginal)
        case .gifts:
            return UIImage(named: "icon_gift", in: .yapPakistan)?.withRenderingMode(.alwaysOriginal)
        }
    }
}
