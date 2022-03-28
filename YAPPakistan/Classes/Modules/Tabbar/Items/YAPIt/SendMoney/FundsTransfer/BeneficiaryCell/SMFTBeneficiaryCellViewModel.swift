//
//  SMFTBeneficiaryCellViewModel.swift
//  YAP
//
//  Created by Zain on 14/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents

protocol SMFTBeneficiaryCellViewModelInput {
    
}

protocol SMFTBeneficiaryCellViewModelOutput {
    var image: Observable<(String?, UIImage?)> { get }
    var name: Observable<String?> { get }
    var flag: Observable<UIImage?> { get }
    var showsFlag: Observable<Bool> { get }
    var account: Observable<String?> { get }
}

protocol SMFTBeneficiaryCellViewModelType {
    var inputs: SMFTBeneficiaryCellViewModelInput { get }
    var outputs: SMFTBeneficiaryCellViewModelOutput { get }
}

class SMFTBeneficiaryCellViewModel: SMFTBeneficiaryCellViewModelType, SMFTBeneficiaryCellViewModelOutput, SMFTBeneficiaryCellViewModelInput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: SMFTBeneficiaryCellViewModelInput { return self }
    var outputs: SMFTBeneficiaryCellViewModelOutput { return self }
    var reusableIdentifier: String { return SMFTBeneficiaryCell.defaultIdentifier }
    
    private let imageSubject = BehaviorSubject<(String?, UIImage?)>(value: (nil, nil))
    private let nameSubject = BehaviorSubject<String?>(value: nil)
    private let flagSubject = BehaviorSubject<UIImage?>(value: nil)
    private let showsFlagSubject = BehaviorSubject<Bool>(value: false)
    private let accounSubject = BehaviorSubject<String?>(value: nil)
    
    // MARK: - Inputs
    
    // MARK: - Outputs
    var image: Observable<(String?, UIImage?)> { return imageSubject.asObservable() }
    var name: Observable<String?> { return nameSubject.asObservable() }
    var flag: Observable<UIImage?> { return flagSubject.asObservable() }
    var showsFlag: Observable<Bool> { return showsFlagSubject.asObservable() }
    var account: Observable<String?> { return accounSubject.asObservable() }
    
    // MARK: - Init
    init(_ beneficiary: SendMoneyBeneficiary, showsFlag: Bool = false, showsIban: Bool = false) {
        let name = [beneficiary.firstName ?? "", beneficiary.lastName ?? ""].joined(separator: " ")
        
        imageSubject.onNext((nil, name.thumbnail))//name.initialsImage(color: beneficiary.color)))
        nameSubject.onNext(name)
     //   flagSubject.onNext(UIImage.sharedImage(named: beneficiary.country!))
        showsFlagSubject.onNext(showsFlag)
        accounSubject.onNext(showsIban ? beneficiary.formattedIBAN : nil)
    }
}
