//
//  UserProfileTableViewCellViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 30/03/2022.
//

import Foundation
import RxSwift
import RxCocoa
import YAPComponents

protocol UserProfileTableViewCellViewModelInputs {
    var actionObserver: AnyObserver<UserProfileTableViewAction> { get }
}

protocol UserProfileTableViewCellViewModelOutputs {
    var icon: Observable<UIImage?> { get }
    var title: Observable<String> { get }
    var warning: Observable<Bool> { get }
    var itemType: Observable<UserProfileItemType> { get }
    var accessory: Observable<UserProfileTableViewAccessory?> { get }
    var versionText: Observable<String?> { get }
}

protocol UserProfileTableViewCellViewModelType {
    var inputs: UserProfileTableViewCellViewModelInputs { get }
    var outputs: UserProfileTableViewCellViewModelOutputs { get }
}

class UserProfileTableViewCellViewModel: UserProfileTableViewCellViewModelType, UserProfileTableViewCellViewModelInputs, UserProfileTableViewCellViewModelOutputs {
        
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: UserProfileTableViewCellViewModelInputs { return self }
    var outputs: UserProfileTableViewCellViewModelOutputs { return self }
    
    private var userProfileTableViewItemSubject: BehaviorSubject<UserProfileTableViewItem>!
    private let versionTextSubject = BehaviorSubject<String?>(value: nil)
    
    // MARK: - Inputs
    var actionObserver: AnyObserver<UserProfileTableViewAction>
    
    // MARK: - Outputs
    var versionText: Observable<String?> { versionTextSubject.asObservable() }
    var userProfileTableViewItem: Observable<UserProfileTableViewItem> { return userProfileTableViewItemSubject.share(replay: 1, scope: .whileConnected) }
    var icon: Observable<UIImage?> { return userProfileTableViewItem.map { $0.icon } }
    var title: Observable<String> { return userProfileTableViewItem.map { $0.title } }
    var warning: Observable<Bool>
    var itemType: Observable<UserProfileItemType> { return userProfileTableViewItem.map { $0.type } }
    var accessory: Observable<UserProfileTableViewAccessory?> { return userProfileTableViewItem.map { $0.accessory } }
    
    // MARK: - Init
    init(_ userProfileTableViewItem: UserProfileTableViewItem) {
        self.userProfileTableViewItemSubject = BehaviorSubject(value: userProfileTableViewItem)
        actionObserver = userProfileTableViewItem.actionObserver
        warning = userProfileTableViewItem.warning
        //setupAppVersion()
    }
}

extension UserProfileTableViewCellViewModel {
    func setupAppVersion(){
        let version = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
        let build = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? ""
        versionTextSubject.onNext("Version \(version) (\(build))")
    }
}
