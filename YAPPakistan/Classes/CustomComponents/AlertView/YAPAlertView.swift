//
//  YAPAlertView.swift
//  YAPKit
//
//  Created by Zain on 04/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxTheme


public class YAPAlertView: NSObject {
    
    // MARK: Properties
    
    let viewModel: YAPAlertViewModel!
    let viewController: YAPAlertViewController!
    
    public var showsCloseIcon: Bool = false {
        didSet {
            viewModel.inputs.showCloseObserver.onNext(showsCloseIcon)
        }
    }
    
    public typealias ButtonTapCompletionHandler = (() -> Void)
    public typealias LinkTapCompletionHandler = ((String) -> Void)
    
    private var primaryButtonTapCompletion: ButtonTapCompletionHandler!
    private var cancelButtonTapCompletion: ButtonTapCompletionHandler!
    private var linkTapCompletion: LinkTapCompletionHandler!
    
    // MARK: Initialization
    
    public init(theme: ThemeService<AppTheme>, icon: UIImage?, text: NSAttributedString, primaryButtonTitle: String, cancelButtonTitle: String?) {
        viewModel = YAPAlertViewModel(icon: icon, text: text, primaryActionTitle: primaryButtonTitle, cancelTitle: cancelButtonTitle)
        viewController = YAPAlertViewController(themeService: theme, viewModel: viewModel)
        
    }
}

// MARK: Public methods

public extension YAPAlertView {
    
    func show(onPrimaryButtonTap: @escaping ButtonTapCompletionHandler = {},
              onCancelButtonTap: @escaping ButtonTapCompletionHandler = {},
              onLinkTap: @escaping LinkTapCompletionHandler = {_ in }) {
        
        primaryButtonTapCompletion = onPrimaryButtonTap
        cancelButtonTapCompletion = onCancelButtonTap
        linkTapCompletion = onLinkTap
        viewModel.delegate = self
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        
        alertWindow.rootViewController = YAPAlertViewRootViewController(nibName: nil, bundle: nil)
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

// MARK: ViewModel delegate

extension YAPAlertView: YAPAlertViewModelDelegete {
    func yapAlertViewModelDidTapOnPrimaryButton(_ yapAlertViewModel: YAPAlertViewModel) {
        primaryButtonTapCompletion()
    }
    
    func yapAlertViewModelDidTapOnCancelButton(_ yapAlertViewModel: YAPAlertViewModel) {
        cancelButtonTapCompletion()
    }
    
    func yapAlertViewModel(_ yapAlertViewModel: YAPAlertViewModel, didTapOnLink link: String) {
        linkTapCompletion(link)
    }
}

// MARK: Root View controller

private class YAPAlertViewRootViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return UIApplication.shared.statusBarStyle
        }
    }
}

// MARK: Reactive

public extension Reactive where Base: YAPAlertView {
    var primaryTap: Observable<Void> {
        return self.base.viewModel.outputs.primaryAction
    }
    
    var cancelTap: Observable<Void> {
        return self.base.viewModel.outputs.cancelAction
    }
    
    var linkTap: Observable<String> {
        return self.base.viewModel.outputs.urlSelected
    }
}
