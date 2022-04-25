//
//  StorePackageTableViewCellViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 23/04/2022.
//

import Foundation
import RxSwift
import RxCocoa

protocol StorePackageTableViewCellViewModelInputs {
    
}

protocol StorePackageTableViewCellViewModelOutputs {
    var coverImage: Observable<String?> { get }
    var packageLogo: Observable<String?> { get }
    var heading: Observable<String?> { get }
    var packageDescription: Observable<String?> { get }
    var commingSoonLabelIsHeaden: Observable<Bool?>{ get }
    var selectPackage: Observable<StorePackageType>{ get }
}

protocol StorePackageTableViewCellViewModelType {
    var inputs: StorePackageTableViewCellViewModelInputs { get }
    var outputs: StorePackageTableViewCellViewModelOutputs { get }
}

class StorePackageTableViewCellViewModel: StorePackageTableViewCellViewModelType, StorePackageTableViewCellViewModelInputs, StorePackageTableViewCellViewModelOutputs {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: StorePackageTableViewCellViewModelInputs { return self}
    var outputs: StorePackageTableViewCellViewModelOutputs { return self }
    
    private let coverImageSubject: BehaviorSubject<String?>
    private let packageLogoSubject: BehaviorSubject<String?>
    private let headingSubject: BehaviorSubject<String?>
    private let packageDescriptionSubject: BehaviorSubject<String?>
    private let commingSoonLabelIsHeadenSubject: BehaviorSubject<Bool?>
    private let selectPackageSubject: BehaviorSubject<StorePackageType>
    
    // MARK:- Inputs
    
    // MARK: - Outputs
    var coverImage: Observable<String?> { return coverImageSubject.asObservable() }
    var packageLogo: Observable<String?> { return packageLogoSubject.asObservable() }
    var heading: Observable<String?> { return headingSubject.asObservable() }
    var packageDescription: Observable<String?> {  return packageDescriptionSubject.asObservable() }
    var commingSoonLabelIsHeaden: Observable<Bool?>{ return commingSoonLabelIsHeadenSubject.asObservable() }
    var selectPackage: Observable<StorePackageType>{ return selectPackageSubject.asObservable() }
    
    init(_ yapStore: YAPStore) {
        coverImageSubject = BehaviorSubject(value: yapStore.coverImage)
        packageLogoSubject = BehaviorSubject(value: yapStore.packageLogo)
        headingSubject = BehaviorSubject(value: yapStore.heading)
        packageDescriptionSubject = BehaviorSubject(value: yapStore.packageDescription)
        commingSoonLabelIsHeadenSubject = BehaviorSubject(value: yapStore.commingSoonIsHeaden)
        selectPackageSubject = BehaviorSubject(value: yapStore.storePackageType)
    }
}
    

