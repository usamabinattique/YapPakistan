//
//  OnBoardingContainerViewController.swift
//  YAP
//
//  Created by Zain on 21/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import YAPComponents
import RxCocoa
import RxSwift
import RxTheme


class OnBoardingContainerViewController: KeyboardAvoidingViewController {
    
    private lazy var sendButton: AppRoundedButton = {
        let button = AppRoundedButton()
        button.title =  "common_button_next".localized
        button.titleLabel?.font = .large
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var themeService: ThemeService<AppTheme>!
    private var viewModel: OnBoardingContainerViewModelType!
    private var childNavigation: UINavigationController?
    private var childView: UIView?
    
    init(themeService: ThemeService<AppTheme> ,viewModel: OnBoardingContainerViewModelType, childNavigation: UINavigationController?) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
        self.themeService = themeService
        self.childNavigation = childNavigation
        self.childView = childNavigation?.view
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupTheme()
        setupCostraints()
        bindViews()
    }
}

// MAKR: View setup

fileprivate extension OnBoardingContainerViewController {
    func setupViews() {
        view.addSubview(sendButton)
        
        childView?.translatesAutoresizingMaskIntoConstraints = false
        if childView != nil, childNavigation != nil {
            addChild(childNavigation!)
            view.addSubview(childView!)
        }
        childNavigation?.didMove(toParent: self)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({$0.primaryExtraLight}, to: [view.rx.backgroundColor])
            .bind({$0.primary}, to: [sendButton.rx.enabledBackgroundColor])
            .bind({$0.primary}, to: [sendButton.rx.disabledBackgroundColor])
            .bind({$0.primaryExtraLight}, to: [sendButton.rx.titleColor(for: .normal)])
            
            .disposed(by: rx.disposeBag)
    }
    
    func setupCostraints() {
        
        sendButton
            .alignEdgeWithSuperviewSafeArea(.bottomAvoidingKeyboard, constant: 25)
            .centerHorizontallyInSuperview()
            .height(constant: 52)
            .width(constant: 192)
        
        childView?
            .alignEdgesWithSuperview([.left, .right, .top])
            .toTopOf(sendButton)
    }
}

// MARK: Binding

fileprivate extension OnBoardingContainerViewController {
    func bindViews() {
        sendButton.rx.tap.withLatestFrom(viewModel.outputs.activeStage)
            .do(onNext: { value in
                print(value)
            }).bind(to: viewModel.inputs.sendObserver).disposed(by: rx.disposeBag)
        viewModel.outputs.valid.bind(to: sendButton.rx.isEnabled).disposed(by: rx.disposeBag)
    }
}
