//
//  MoreViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import Foundation
import YAPComponents
import RxSwift
import RxDataSources
import RxTheme
import UIKit

protocol MoreViewModelInput {
    var viewDidAppearObserver: AnyObserver<Void> { get }
    var settingsObserver: AnyObserver<Void> { get }
    var notificationObserver: AnyObserver<Void> { get }
    var bankDetailsObserver: AnyObserver<Void> { get }
    var itemTappedObserver: AnyObserver<ReusableCollectionViewCellViewModelType> { get }
    var logoutObserver: AnyObserver<Void> { get }
//    var moreHelpTourObserver: AnyObserver<[GuidedTour]> { get }
//    var markTourGuideCompleteObserver: AnyObserver<TourGuideView> { get }
//    var markTourGuideSkipObserver: AnyObserver<TourGuideView> { get }
}

protocol MoreViewModelOutput {
    var viewDidAppear: Observable<Void> { get }
    var dataSource: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
    var profileImage: Observable<(String?, UIImage?)> { get }
    var name: Observable<String?> { get }
    var iban: Observable<NSAttributedString?> { get }
    var bic: Observable<NSAttributedString?> { get }
    var openMoreItem: Observable<MoreCollectionViewCellViewModel.CellType> { get }
    var bankDetails: Observable<Void> { get }
    var locateAtm: Observable<Void> { get }
    var openProfile: Observable<Void> { get }
    var openNotification: Observable<Void> { get }
    var accountNumber: Observable<String?> { get }
    var logout: Observable<Void> { get }
    var showError: Observable<String> { get }
//    var moreHelpTour: Observable<[GuidedTour]> { get }
    var presentTourGuide: Observable<Void> { get }
    var badgeValue: Observable<String?> { get }
}

protocol MoreViewModelType {
    var inputs: MoreViewModelInput { get }
    var outputs: MoreViewModelOutput { get }
}

class MoreViewModel: MoreViewModelType, MoreViewModelInput, MoreViewModelOutput {

    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: MoreViewModelInput { return self }
    var outputs: MoreViewModelOutput { return self }
    
    private let viewDidAppearSubject = PublishSubject<Void>()
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>(value: [])
    private let profileImageSubject = BehaviorSubject<(String?, UIImage?)>(value: ("", nil))
    private let nameSubject = BehaviorSubject<String?>(value: nil)
    private let ibanSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    private let bicSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    private let openMoreItemSubject = PublishSubject<MoreCollectionViewCellViewModel.CellType>()
    private let logoutSubject = PublishSubject<Void>()
    private let loggedOutSubject = PublishSubject<Void>()
    
    private let settingsSubject = PublishSubject<Void>()
    private let notificationSubject = PublishSubject<Void>()
    private let bankDetailsSubject = PublishSubject<Void>()
    private let itemTappedSubject = PublishSubject<ReusableCollectionViewCellViewModelType>()
    private let locateAtmSubject = PublishSubject<Void>()
    private let showErrorSubject = PublishSubject<String>()
//    private let moreHelpTourSubject = PublishSubject<[GuidedTour]>()
//    private let markTourGuideCompleteSubject = PublishSubject<TourGuideView>()
//    private let markTourGuideSkipSubject = PublishSubject<TourGuideView>()
    private let presentTourGuideSubject = PublishSubject<Void>()
    private let unreadNotificationsCount = BehaviorSubject<String?>(value: nil)
    
    // MARK: - Inputs
    var viewDidAppearObserver: AnyObserver<Void> { viewDidAppearSubject.asObserver() }
    var settingsObserver: AnyObserver<Void> { return settingsSubject.asObserver() }
    var notificationObserver: AnyObserver<Void> { return notificationSubject.asObserver() }
    var bankDetailsObserver: AnyObserver<Void> { return bankDetailsSubject.asObserver() }
    var itemTappedObserver: AnyObserver<ReusableCollectionViewCellViewModelType> { return itemTappedSubject.asObserver() }
    var logoutObserver: AnyObserver<Void> { logoutSubject.asObserver() }
//    var moreHelpTourObserver: AnyObserver<[GuidedTour]> { moreHelpTourSubject.asObserver() }
//    var markTourGuideSkipObserver: AnyObserver<TourGuideView> { markTourGuideSkipSubject.asObserver() }
//    var markTourGuideCompleteObserver: AnyObserver<TourGuideView> { markTourGuideCompleteSubject.asObserver() }
    
    // MARK: - Outputs
    var viewDidAppear: Observable<Void> { viewDidAppearSubject }
    var dataSource: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    var profileImage: Observable<(String?, UIImage?)> { return profileImageSubject.asObservable() }
    var name: Observable<String?> { return nameSubject.asObservable() }
    var iban: Observable<NSAttributedString?> { return ibanSubject.asObservable() }
    var bic: Observable<NSAttributedString?> { return bicSubject.asObservable() }
    var openMoreItem: Observable<MoreCollectionViewCellViewModel.CellType> { return openMoreItemSubject.asObservable() }
    var bankDetails: Observable<Void> { return bankDetailsSubject.asObservable() }
    var locateAtm: Observable<Void> { return locateAtmSubject.asObservable() }
    var openProfile: Observable<Void> { return settingsSubject.asObservable() }
    var openNotification: Observable<Void> { return notificationSubject.asObservable() }
    var badgeValue: Observable<String?> {unreadNotificationsCount}
    
    var accountNumber: Observable<String?> { self.accountProvider.currentAccount
        .map{ $0?.accountNumber }.unwrap()
        .map{ "Account number: \($0)" } }
    var logout: Observable<Void> { loggedOutSubject.asObservable() }
    var showError: Observable<String> { showErrorSubject.asObservable() }
//    var moreHelpTour: Observable<[GuidedTour]> { moreHelpTourSubject.asObservable() }
    var presentTourGuide: Observable<Void> { presentTourGuideSubject }
    
    private var accountProvider: AccountProvider
    private var theme: ThemeService<AppTheme>
    private var repository: MoreRepositoryType
    
    // MARK: - Init
    init(accountProvider: AccountProvider, repository: MoreRepositoryType, theme: ThemeService<AppTheme>) {
        self.accountProvider = accountProvider
        self.repository = repository
        self.theme = theme
        
        let cellTypes: [MoreCollectionViewCellViewModel.CellType]
        cellTypes = [.yapForYou,.locateAtm, .inviteAFriend, .help, .subscriptions, .gifts]
        
        let cellViewModels = cellTypes
            .map{ type -> MoreCollectionViewCellViewModel in
                let cellViewModel = MoreCollectionViewCellViewModel(type)
                if type == .notifications {
                    unreadNotificationsCount.bind(to: cellViewModel.inputs.badgeObserver).disposed(by: disposeBag)
                }
                return cellViewModel
            }
        
        dataSourceSubject.onNext([SectionModel(model: 0, items: cellViewModels)])
        
        accountProvider.currentAccount.map { ($0?.customer.imageURL?.absoluteString, $0?.customer.fullName?.initialsImage(color: $0?.customer.accentColor ?? UIColor(self.theme.attrs.primary)))}.bind(to: profileImageSubject).disposed(by: disposeBag)
        
        accountProvider.currentAccount.map { $0?.customer.fullName }.bind(to: nameSubject).disposed(by: disposeBag)
        
        accountProvider.currentAccount.map { account -> NSAttributedString? in
            
            guard let iban = (account?.parnterBankStatus == .activated ? account?.formattedIBAN : account?.maskedAndFormattedIBAN) else { return nil }
            let attributed = NSMutableAttributedString(string: "IBAN " + iban)
            attributed.addAttribute(.foregroundColor, value: UIColor(self.theme.attrs.primaryDark), range: NSRange(location: 0, length: 4))
            return attributed
        }.bind(to: ibanSubject).disposed(by: disposeBag)
        
        accountProvider.currentAccount.map { account -> NSAttributedString? in
            guard let bic = account?.bank.swiftCode else { return nil }
            let attributed = NSMutableAttributedString(string: "BIC " + bic)
            attributed.addAttribute(.foregroundColor, value: UIColor(self.theme.attrs.primaryDark), range: NSRange(location: 0, length: 3))
            if account?.accountType != .b2cAccount {
                attributed.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributed.length))
            }
            return attributed
        }.bind(to: bicSubject).disposed(by: disposeBag)
        
        itemTappedSubject.subscribe(onNext: { vm in
            
        }).disposed(by: disposeBag)
        
        let action = itemTappedSubject.filter { $0 is MoreCollectionViewCellViewModelType }
            .map { ($0 as? MoreCollectionViewCellViewModel)?.cellType }
            .unwrap()
            .share()
        
        action
            .bind(to: openMoreItemSubject)
            .disposed(by: disposeBag)
        
        action
            .filter { $0 == .locateAtm }
            .map { _ in }
            .bind(to: locateAtmSubject).disposed(by: disposeBag)
        
//        notificationManager.unreadNotificationsCount.map{ $0 <= 0 ? nil : "\($0)" }.bind(to: unreadNotificationsCount).disposed(by: disposeBag)
        
//        bindTourGuideStatus(repository: tourGuideRepository)
    }
    
//    private func bindTourGuideStatus(repository: TourGuideRepository) {
//        markTourGuideComplete(repository: repository)
//        markTourGuideSkip(repository: repository)
//        invokeTourGuide(repository: repository)
//    }
//
//    func markTourGuideComplete(repository: TourGuideRepository) {
//        markTourGuideCompleteSubject.flatMap {
//            repository.markComplete(for: $0.rawValue)
//        }.subscribe().disposed(by: disposeBag)
//    }
//
//    func markTourGuideSkip(repository: TourGuideRepository) {
//        markTourGuideSkipSubject.flatMap {
//            repository.markSkip(for: $0.rawValue)
//        }.subscribe().disposed(by: disposeBag)
//    }
//
//    func invokeTourGuide(repository: TourGuideRepository) {
//        let response = repository.getTourGuides()
//            .share(replay: 1, scope: .whileConnected)
//
//        let firstViewDidAppear = viewDidAppear.take(1)
//        let hasTourGuideNotShown = response.elements().map { $0.filter { $0.viewName == TourGuideView.more } }
//            .map { $0.count > 0 ? ($0.first?.completed ?? false) || ($0.first?.skipped ?? false) : false }
//            .filter { !$0 }
//
//        Observable.combineLatest(firstViewDidAppear,
//                                 hasTourGuideNotShown)
//            .map { _ in () }
//            .bind(to: presentTourGuideSubject)
//            .disposed(by: disposeBag)
//    }
}

