//
//  SearchableActionSheet.swift
//  YAPPakistan
//
//  Created by Yasir on 14/03/2022.
//

import Foundation
import UIKit
import RxSwift
import RxTheme

public class SearchableActionSheet {
    
    // MARK: Properties
    
    private let viewModel: SearchableActionSheetViewModelType
    private let viewController: SearchableActionSheetViewController
    private let itemSelectedSubject = PublishSubject<Int>()
    public var itemSelected: Observable<Int> { itemSelectedSubject.asObservable() }
    private let disposeBag = DisposeBag()
    private var themeService: ThemeService<AppTheme>
    
    // MARK: Initialization
    
    public init(title: String?, searchPlaceholderText: String, items: [SearchableDataType], themeService: ThemeService<AppTheme>) {
        self.themeService = themeService
        viewModel = SearchableActionSheetViewModel(title, searchPlaceholderText: searchPlaceholderText, items: items)
        viewController = SearchableActionSheetViewController(themeService: themeService, viewModel)
        viewModel.outputs.itemSelected.subscribe(onNext: { [weak self] in
            if $0 >= 0 {
                self?.itemSelectedSubject.onNext($0)
            }
            self?.itemSelectedSubject.onCompleted()
        }).disposed(by: disposeBag)
    }
}

// MARK: Public methods

public extension SearchableActionSheet {
    
    
    func show() {
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        
        alertWindow.rootViewController = YAPActionSheetRootViewController(nibName: nil, bundle: nil)
        alertWindow.backgroundColor = .clear
        alertWindow.windowLevel = .alert + 1
        alertWindow.makeKeyAndVisible()
        
        let nav = UINavigationController(rootViewController: viewController)
        nav.navigationBar.isHidden = true
        nav.modalPresentationStyle = .overCurrentContext
        
        alertWindow.rootViewController?.present(nav, animated: false, completion: nil)
        
        viewController.window = alertWindow
    }
}
