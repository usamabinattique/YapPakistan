//
//  RecentBeneficiaryCollectionViewCellViewModel.swift
//  YAPKit
//
//  Created by Zain on 03/11/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import RxSwift

protocol RecentBeneficiaryCollectionViewCellViewModelInput {
    
}

protocol RecentBeneficiaryCollectionViewCellViewModelOutput {
    var country: Observable<String?> { get }
    var userImage: Observable<ImageWithURL> { get }
    var package: Observable<RecentBeneficiaryPackage> { get }
    var name: Observable<String?> { get }
}

protocol RecentBeneficiaryCollectionViewCellViewModelType {
    var inputs: RecentBeneficiaryCollectionViewCellViewModelInput { get }
    var outputs: RecentBeneficiaryCollectionViewCellViewModelOutput { get }
}

class RecentBeneficiaryCollectionViewCellViewModel: RecentBeneficiaryCollectionViewCellViewModelType, RecentBeneficiaryCollectionViewCellViewModelInput, RecentBeneficiaryCollectionViewCellViewModelOutput, ReusableCollectionViewCellViewModelType {
    
    // MARK: - Properties
    
    var inputs: RecentBeneficiaryCollectionViewCellViewModelInput { self }
    var outputs: RecentBeneficiaryCollectionViewCellViewModelOutput { self }
    
    var reusableIdentifier: String { RecentBeneficiaryCollectionViewCell.defaultIdentifier }
    
    private let disposeBag = DisposeBag()
    
    private let countrySubject: BehaviorSubject<String?>
    private let userImageSubject: BehaviorSubject<ImageWithURL>
    private let userNameSubject: BehaviorSubject<String?>
    private let packageSubject: BehaviorSubject<RecentBeneficiaryPackage>
    
    // MARK: - Inputs
    
    // MARK: - Outputs
    
    var country: Observable<String?> { countrySubject.asObservable() }
    var userImage: Observable<ImageWithURL> { userImageSubject.asObservable() }
    var name: Observable<String?> { userNameSubject.asObservable() }
    var package: Observable<RecentBeneficiaryPackage> { packageSubject.asObservable() }
    
    // MARK: - Initialization
    
    init(_ beneficairy: RecentBeneficiaryType) {
        countrySubject = BehaviorSubject(value: beneficairy.beneficiaryCountryCode)
        userNameSubject = BehaviorSubject(value: beneficairy.beneficiaryTitle)
        userImageSubject = BehaviorSubject(value: beneficairy.beneficiaryImage)
        packageSubject = BehaviorSubject(value: beneficairy.beneficiaryPackage)
    }
}
