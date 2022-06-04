//
//  HSCallUsTableViewCellViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 02/06/2022.
//

import Foundation
import YAPComponents
import RxSwift

protocol HSCallUsTableViewCellViewModelInput {
    var phoneNumberObserver: AnyObserver<String?> { get }
}

protocol HSCallUsTableViewCellViewModelOutput {
    var icon: Observable<UIImage?> { get }
    var title: Observable<String?> { get }
    var phoneNumber: Observable<NSAttributedString?> { get }
}

protocol HSCallUsTableViewCellViewModelType {
    var inputs: HSCallUsTableViewCellViewModelInput { get }
    var outputs: HSCallUsTableViewCellViewModelOutput { get }
}

class HSCallUsTableViewCellViewModel: HSCallUsTableViewCellViewModelType, HSCallUsTableViewCellViewModelInput, HSCallUsTableViewCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: HSCallUsTableViewCellViewModelInput { return self }
    var outputs: HSCallUsTableViewCellViewModelOutput { return self }
    var reusableIdentifier: String { return HSCallUsTableViewCell.defaultIdentifier }
    let action: HelpAndSupportActionType = .call
    
    private let iconSubject = BehaviorSubject<UIImage?>(value: nil)
    private let titleSubject = BehaviorSubject<String?>(value: nil)
    private let phoneNumberSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    private let phoneNumberObserverSubject = PublishSubject<String?>()
    
    // MARK: - Inputs
    var phoneNumberObserver: AnyObserver<String?> { return phoneNumberObserverSubject.asObserver() }
    
    // MARK: - Outputs
    var icon: Observable<UIImage?> { return iconSubject.asObservable() }
    var title: Observable<String?> { return titleSubject.asObservable() }
    var phoneNumber: Observable<NSAttributedString?> { return phoneNumberSubject.asObservable() }
    
    // MARK: - Init
    init() {
        iconSubject.onNext(action.icon)
        titleSubject.onNext(action.title)
        
        phoneNumberObserverSubject.unwrap().map {
            let attributed = NSMutableAttributedString(string: $0)
            attributed.addAttributes([.underlineStyle: 1], range: NSRange(location: 0, length: attributed.length))
            return attributed
        }.bind(to: phoneNumberSubject).disposed(by: disposeBag)
    }
}
