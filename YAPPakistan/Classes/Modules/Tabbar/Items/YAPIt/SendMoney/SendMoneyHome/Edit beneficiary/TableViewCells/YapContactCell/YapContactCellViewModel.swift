//
//  YapContactCellViewModel.swift
//  YAPPakistan
//
//  Created by Muhammad Sohaib on 17/03/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift
import RxCocoa
import RxDataSources
import RxTheme
import UIKit

protocol YapContactCellViewModelInput {
    var addProfilePictureObserver: AnyObserver<Void> { get }
    var updateProfilePicture: AnyObserver<(String?, UIImage?)> { get }
}

protocol YapContactCellViewModelOutput {
    var name: Observable<String?> { get }
    var iban: Observable<String?> { get }
    var addProfilePicture: Observable<Void> { get }
    var image: Observable<(String?, UIImage?)> { get }
}

protocol YapContactCellViewModelType {
    var inputs: YapContactCellViewModelInput { get }
    var outputs: YapContactCellViewModelOutput { get }
}

class YapContactCellViewModel: YapContactCellViewModelType, YapContactCellViewModelInput, YapContactCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: YapContactCellViewModelInput { return self }
    var outputs: YapContactCellViewModelOutput { return self }
    var reusableIdentifier: String { return YapContactCell.defaultIdentifier }
    let profilePhoto: (photoUrl: String?, initialsImage: UIImage?)
    
    private let nameSubject = BehaviorSubject<String?>(value: nil)
    private let ibanSubject = BehaviorSubject<String?>(value: nil)
    private let imageSubject = BehaviorSubject<(String?, UIImage?)>(value: (nil, nil))
    
    private let addProfilePictureSubject = PublishSubject<Void>()
    
    // MARK: - Inputs
    var updateProfilePicture: AnyObserver<(String?, UIImage?)> { imageSubject.asObserver() }
    var addProfilePictureObserver: AnyObserver<Void> { addProfilePictureSubject.asObserver() }
    
    // MARK: - Outputs
    var name: Observable<String?> { return nameSubject.asObservable() }
    var iban: Observable<String?> { return ibanSubject.asObservable() }
    var image: Observable<(String?, UIImage?)> { imageSubject.asObservable() }
    var addProfilePicture: Observable<Void> { addProfilePictureSubject.asObservable() }
    
    
    // MARK: - Init
    init(_ name: String = "", iban: String = "", profilePhoto: (photoUrl: String?, initialsImage: UIImage?)) {
        self.profilePhoto = profilePhoto
        imageSubject.onNext(profilePhoto)
        nameSubject.onNext(name)
        ibanSubject.onNext("IBAN: \(iban)")
    }
}
