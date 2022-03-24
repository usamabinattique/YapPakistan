//
//  ASMBTitleCellViewModel.swift
//  YAPPakistan
//
//  Created by Muhammad Sohaib on 16/03/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift
import RxCocoa
import RxDataSources
import RxTheme
import UIKit

protocol ASMBTitleCellViewModelInput {
    var titleObserver: AnyObserver<String> { get }
}

protocol ASMBTitleCellViewModelOutput {
    var title: Observable<String> { get }
    var font: Observable<UIFont> { get }
    var cellTitleType: Observable<ASMBTitleCellViewModel.TitleType> { get }
    var textAlignment: Observable<NSTextAlignment> { get }
}

protocol ASMBTitleCellViewModelType {
    var inputs: ASMBTitleCellViewModelInput { get }
    var outputs: ASMBTitleCellViewModelOutput { get }
}

open class ASMBTitleCellViewModel: ASMBTitleCellViewModelType, ASMBTitleCellViewModelInput, ASMBTitleCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: ASMBTitleCellViewModelInput { return self }
    var outputs: ASMBTitleCellViewModelOutput { return self }
    open var reusableIdentifier: String { return ASMBTitleCell.defaultIdentifier }
    let titleType: TitleType!
    
    private let titleSubject: BehaviorSubject<String>
    private let fontSubject: BehaviorSubject<UIFont>
    private let titleTypeSubject: BehaviorSubject<TitleType>
    private let textAlignmentSubject: BehaviorSubject<NSTextAlignment>
    
    // MARK: - Inputs
    var titleObserver: AnyObserver<String> { titleSubject.asObserver() }
    
    // MARK: - Outputs
    var title: Observable<String> { titleSubject.asObservable() }
    var font: Observable<UIFont> { fontSubject.asObservable() }
    var cellTitleType: Observable<TitleType> { titleTypeSubject.asObservable() }
    var textAlignment: Observable<NSTextAlignment> { textAlignmentSubject.asObservable() }
    
    // MARK: - Init
    public init(titleType: ASMBTitleCellViewModel.TitleType, text: String? = "") {
        self.titleType = titleType
        fontSubject = BehaviorSubject<UIFont>(value: titleType.font)
        titleTypeSubject = BehaviorSubject<TitleType>(value: titleType)
        textAlignmentSubject = BehaviorSubject<NSTextAlignment>(value: titleType.textAlignment)
        titleSubject = BehaviorSubject<String>(value: [titleType.title, text].compactMap { $0 }.joined(separator: " "))
    }
}

// MARK: Title type

public extension ASMBTitleCellViewModel {
    enum TitleType {
        case iban
        case fullName
        case country
        case transferType
        case beneficiaryInfo
        case bankInfo
        case accountInfo
        case overview
        case empty
    }
}

extension ASMBTitleCellViewModel.TitleType {
    
    var title: String? {
        switch self {
        case .fullName, .empty:
            return ""
        case .iban:
            return "screen_send_money_edit_beneficiary_display_text_iban".localized
        case .country:
            return "screen_add_beneficiary_display_text_country_title".localized
        case .transferType:
            return "screen_add_beneficiary_display_text_transfer_type".localized
        case .beneficiaryInfo:
            return "screen_add_beneficiary_detail_display_text_title".localized
        case .bankInfo:
            return "screen_bank_details_display_text_title".localized
        case .accountInfo:
            return "screen_beneficiary_account_details_display_text_title".localized
        case .overview:
            return "screen_beneficiary_overview_display_text_title".localized
        }
    }
    
    var textAlignment: NSTextAlignment {
        switch self {
        case .fullName, .iban:  return .center
        default:                return .left
        }
    }
    
    var font: UIFont {
        switch self {
        case .fullName: return .large
        case .iban:     return .small
        default:        return .regular
        }
    }
}
