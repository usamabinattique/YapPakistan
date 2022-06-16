//
//  SideMenuViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 15/04/2022.
//

import Foundation
import RxSwift
import RxDataSources
import YAPComponents

public protocol SideMenuViewModelInput {
    var menuItemSelectedObserver: AnyObserver<MenuItemType> { get }
    var accountSelectedObserver: AnyObserver<Account> { get }
    var settingsObserver: AnyObserver<Void> { get }
    var logoutObserver: AnyObserver<Void>{ get }
    var shareAccountInfoObserver: AnyObserver <String> { get }
}

public protocol SideMenuViewModelOutput {
    var menuCellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var accountCellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var update: Observable<Void> { get }
    var menuItemSelected: Observable<MenuItemType> { get }
    var switchAccount: Observable<Void> { get }
    var settings: Observable<Void> { get }
    var error: Observable<String> { get }
    var logout: Observable<Void>{ get }
    var result: Observable<Void> { get }
    var openProfile: Observable<Account>{ get }
    var shareAccountInfo: Observable<String> { get }
}

public protocol SideMenuViewModelType {
    var inputs: SideMenuViewModelInput { get }
    var outputs: SideMenuViewModelOutput { get }
}

public class SideMenuViewModel: SideMenuViewModelType, SideMenuViewModelInput, SideMenuViewModelOutput {

    // MARK: - Properties
    let disposeBag = DisposeBag()
    public var inputs: SideMenuViewModelInput { return self }
    public var outputs: SideMenuViewModelOutput { return self }

    private let menuCellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let accountCellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let updateSubject = BehaviorSubject<Void>(value: ())
    private let menuItemSelectedSubject = PublishSubject<MenuItemType>()
    private let accountSelectedSubject = PublishSubject<Account>()
    private let switchAccountSubject = PublishSubject<Void>()
    private let settingsSubject = PublishSubject<Void>()
    private let errorSubject = PublishSubject<String>()
    private let logoutSubject = PublishSubject<Void>()
    private let resultSubject = PublishSubject<Void>()
    private let shareAccountInfoSubject = PublishSubject<String>()

    // MARK: - Inputs
    public var menuItemSelectedObserver: AnyObserver<MenuItemType> { return menuItemSelectedSubject.asObserver() }
    public var accountSelectedObserver: AnyObserver<Account> { return accountSelectedSubject.asObserver() }
    public var settingsObserver: AnyObserver<Void> { return settingsSubject.asObserver() }
    public var logoutObserver: AnyObserver<Void>{ return logoutSubject.asObserver() }
    public var shareAccountInfoObserver: AnyObserver<String> { return shareAccountInfoSubject.asObserver() }
    

    // MARK: - Outputs
    public var menuCellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return menuCellViewModelsSubject.asObservable().share() }
    public var accountCellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return accountCellViewModelsSubject.asObservable() }
    public var update: Observable<Void> { return updateSubject.asObservable() }
    public var menuItemSelected: Observable<MenuItemType> { return menuItemSelectedSubject.asObservable() }
    public var switchAccount: Observable<Void> { return switchAccountSubject.asObservable() }
    public var settings: Observable<Void> { return settingsSubject.asObservable() }
    public var error: Observable<String> { errorSubject.asObservable() }
    public var logout: Observable<Void>{ return logoutSubject.asObservable() }
    public var result: Observable<Void> { return resultSubject.asObservable() }
    public var openProfile: Observable<Account>{ return accountSelectedSubject.asObservable() }
    public var shareAccountInfo: Observable<String> { return shareAccountInfoSubject.asObservable() }

    private var menuViewModels = [ReusableTableViewCellViewModelType]()
    
    private var accountProvider: AccountProvider!

    public init(repository: AccountRepository, accountProvider: AccountProvider) {

        self.accountProvider = accountProvider
        self.loadMenuCell()
        
        loadAcccountCells()
        logout(repository: repository)
    }
}

private extension SideMenuViewModel {
    func loadMenuCell() {
        let menuUserCellViewModel = MenuUserTableViewCellViewModel(accountProvider: self.accountProvider)
        let accountInfoCellViewModel = MenuAccountInfoTableViewCellViewModel(accountProvider: self.accountProvider)
        accountInfoCellViewModel.outputs.shareAccountInfo.bind(to: shareAccountInfoObserver).disposed(by: disposeBag)
        menuViewModels.removeAll()
        
        menuUserCellViewModel.outputs.dropDown.bind(to: updateSubject).disposed(by: disposeBag)
        
        menuUserCellViewModel.outputs.dropDownState.map { $0 == .up }.bind(to: accountInfoCellViewModel.inputs.showInfoObserver).disposed(by: disposeBag)
        
        menuViewModels.append(menuUserCellViewModel)
        menuViewModels.append(accountInfoCellViewModel)
        
        menuViewModels.append(MenuItemTableViewCellViewModel(menuItemType: .analytics))
        menuViewModels.append(MenuSeparatorTableViewCellViewModel())
        
//        menuViewModels.append(MenuItemTableViewCellViewModel(menuItemType: .young))
//        menuViewModels.append(MenuSeparatorTableViewCellViewModel())
        
        menuViewModels.append(MenuItemTableViewCellViewModel(menuItemType: .referFriend))
//        menuViewModels.append(MenuItemTableViewCellViewModel(menuItemType: .notifications))
        menuViewModels.append(MenuItemTableViewCellViewModel(menuItemType: .statements))
        
        menuViewModels.append(MenuItemTableViewCellViewModel(menuItemType: .qrCode))
        menuViewModels.append(MenuItemTableViewCellViewModel(menuItemType: .dashboardWidget))
        menuViewModels.append(MenuItemTableViewCellViewModel(menuItemType: .accountLimits))
        menuViewModels.append(MenuSeparatorTableViewCellViewModel())
        
//        menuViewModels.append(MenuItemTableViewCellViewModel(menuItemType: .chat))
        menuViewModels.append(MenuItemTableViewCellViewModel(menuItemType: .help))
        menuCellViewModelsSubject.onNext([SectionModel(model: 0, items: menuViewModels)])
    }
    
    func loadAcccountCells() {

        self.accountProvider.currentAccount.unwrap()
            .map { account in
                let cellModel = UserAccountTableViewCellViewModel(account: account, accountProvider: self.accountProvider)
                return [SectionModel(model: 0, items: [cellModel])]
            }
            .bind(to: accountCellViewModelsSubject)
            .disposed(by: disposeBag)
//        SessionManager.current.allAccounts
//            .map{ $0.filter{ $0.accountStatus != .invitationDeclined }}
//            .map { $0.map { UserAccountTableViewCellViewModel(account: $0) } }
//            .map { [SectionModel(model: 0, items: $0)] }
//            .bind(to: accountCellViewModelsSubject)
//            .disposed(by: disposeBag)

    }

    func logout(repository: AccountRepository) {
        let logoutRequest = logout
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .flatMap { _ -> Observable<Event<[String: String]?>> in

                return repository.logout(deviceUUID: UIDevice.current.identifierForVendor?.uuidString ?? "")
        }
        .do(onNext: { _ in YAPProgressHud.hideProgressHud()})
        .share(replay: 1, scope: .whileConnected)

        logoutRequest.errors().map{ $0.localizedDescription }.bind(to: errorSubject).disposed(by: disposeBag)

        logoutRequest.elements()
            .map {_ in ()}
            .subscribe(onNext: { [weak self] in
                self?.resultSubject.onNext(()) })
            .disposed(by: disposeBag)
    }
}

