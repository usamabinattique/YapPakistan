//
//  ASMBTextInputCellViewModelPlainText.swift
//  YAPPakistan
//
//  Created by Muhammad Sohaib on 16/03/2022.
//

import Foundation
import RxSwift
import RxDataSources
import YAPCore
import YAPComponents

public class ASMBTextInputCellViewModelPlainText: ASMBTextInputCellViewModel {
    
    private let maxAllowedLength: Int
    public init(_ inputType: ASMBTextInputCellViewModel.InputType, beneficiary: SendMoneyBeneficiary? = nil, title: String? = nil, placeholder: String? = nil, isReviewing: Bool = false, isEnabled: Bool = true, maxAllowedLength: Int = 0) {
        self.maxAllowedLength = maxAllowedLength
        super.init(inputType, beneficiary: beneficiary, title: title, isReviewing: isReviewing)
        
        guard inputType != .phoneNumberOptional && inputType != .phoneNumber else {
            fatalError("'ASMBTextInputCellViewModelPlainText' cannot be initialized with input type 'ASMBTextInputCellViewModel.InputType.phoneNumber'")
        }
        
        let newTitle = inputType == .custome ? title : isReviewing ? inputType.reviewTitle : inputType.title
        titleSubject.onNext(newTitle)
        animatedTitleSubject.onNext(true)
        isEnabledSubject.onNext(isEnabled)
        
        placeholderSubject.onNext(placeholder ?? inputType.placeholder)
        
        captalizationTypeSubject.onNext(inputType == .firstName || inputType == .lastName || inputType == .nickname ? .words : inputType == .iban || inputType == .swift || inputType == .accountOrIban || inputType == .confirmIban ? .allCharacters : .sentences)
                
        let inputText = textSubject.unwrap().map{ $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        
        if inputType == .iban || inputType == .confirmIban {
            inputText
                .map{ text -> NSAttributedString in
                    let attributed = NSMutableAttributedString(string: text.uppercased())
                    
                    guard text.count > 0 else { return attributed }
                    
                    (0...text.count-1).filter{ $0.isMultiple(of: 4) && $0 > 0 }.map{ $0 - 1 }.forEach {
                        attributed.addAttributes([.kern: 8], range: NSRange(location: $0, length: 1))
                    }
                    
                    return attributed }
                .bind(to: attributedTextSubject)
                .disposed(by: disposeBag)
        } else {
            textSubject.unwrap().map{ NSAttributedString(string: $0) }.bind(to: attributedTextSubject).disposed(by: disposeBag)
        }
        
        
        switch inputType {
        case .firstName, .lastName:
            inputText.map { ValidationService.shared.validateName($0, maxLength: 31) }.bind(to: validSubject).disposed(by: disposeBag)
        case .nickname:
            inputText.map { ValidationService.shared.validateName($0) }.bind(to: validSubject).disposed(by: disposeBag)
        case .bankName, .branchName:
            inputText.map { ValidationService.shared.validateBankInfo($0, 35) }.bind(to: validSubject).disposed(by: disposeBag)
        case .bankCity:
            inputText.map { ValidationService.shared.validateBankInfo($0, 32) }.bind(to: validSubject).disposed(by: disposeBag)
        case .iban:
            inputText.map { ValidationService.shared.validateIBAN($0, for: self.beneficiary?.country ?? "AE") }.bind(to: validSubject).disposed(by: disposeBag)
        case .accountOrIban:
            inputText.map { ValidationService.shared.validateAccountNumber($0) }.bind(to: validSubject).disposed(by: disposeBag)
        case .swift:
            inputText.map { ValidationService.shared.validateSWIFT($0) }.bind(to: validSubject).disposed(by: disposeBag)
        default:
            break
        }
        
        if inputType != .iban && inputType != .confirmIban {
            editingEndSubject
                .withLatestFrom(inputText)
                .map{ NSAttributedString(string: $0) }
                .bind(to: attributedTextSubject)
                .disposed(by: disposeBag)
        }
        
        if inputType == .transferType {
            textFieldTextFontSubject.onNext(.micro)
            iconSubject.onNext(UIImage.init(named: beneficiary?.type?.iconName ?? "", in: .yapPakistan))
        }
        
        if inputType == .nickname {
            crossButtonImageSubject.onNext(UIImage.init(named: "icon_add_beneficiary_cross", in: .yapPakistan))
        }
    }
    
    
    override public func canEdit(text: String, replacementText: String, inRange range: NSRange) -> Bool {
        
        var maxAllowd = 0
        switch inputType {
        case .firstName, .lastName:
            maxAllowd = 31
        case .nickname:
            maxAllowd = 50
        case .bankName, .branchName:
            maxAllowd = 35
        case .bankCity:
            maxAllowd = 32
        case .iban:
            maxAllowd = 35
        case .accountOrIban:
            maxAllowd = 34
        case .swift:
            maxAllowd = 11
        case .custome:
            if maxAllowedLength > 0{
                maxAllowd = maxAllowedLength
            }
        default:
            return true
        }
        
        let newString = (text as NSString?)?.replacingCharacters(in: range, with: replacementText)
        return newString?.count ?? 0 <= maxAllowd
    }
}
