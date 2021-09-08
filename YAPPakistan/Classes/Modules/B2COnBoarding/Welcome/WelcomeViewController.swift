//
//  WelcomeViewController.swift
//  YAP
//
//  Created by Zain on 18/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import YAPComponents

import RxSwift
import RxCocoa

class WelcomeViewController: UIViewController {
    
    fileprivate lazy var pageView: UIView = {
        let welcomePageViewController = WelcomePageViewController(viewModel: viewModel.outputs.welcomePageViewModel)
        let welcomePageView = welcomePageViewController.view!
        addChild(welcomePageViewController)
        welcomePageViewController.didMove(toParent: self)
        welcomePageView.translatesAutoresizingMaskIntoConstraints = false
        return welcomePageView
    }()
    
    fileprivate lazy var getStartedButton: AppRoundedButton = {
        let button = AppRoundedButton()
        button.setTitle( "screen_welcome_button_get_started".localized, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate lazy var pageControl: RxAppPageControl = {
        let pageControl = RxAppPageControl()
        pageControl.pages = 3
        return pageControl
    }()

    var viewModel: WelcomeViewModelType!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        bindViews()
    }
}

// MARK: View setup

extension WelcomeViewController {
    fileprivate func setupViews() {
        
        view.backgroundColor = .white
        view.addSubview(pageView)
        view.addSubview(pageControl)
        view.addSubview(getStartedButton)
        
    }
    
    fileprivate func setupConstraints() {
        
        pageView
            .alignEdgesWithSuperview([.left, .top, .right])
        
        getStartedButton
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 30)
            .width(constant: 190)
            .height(constant: 52)
            .centerHorizontallyInSuperview()
        
        pageControl
            .toBottomOf(pageView, constant: 30)
            .toTopOf(getStartedButton, constant: 90)
            .centerHorizontallyInSuperview()
    }
}

// MARK: Binding

extension WelcomeViewController {
    
    fileprivate func bindViews() {
        viewModel.outputs.pageSelected.bind(to: pageControl.rx.selectedPage).disposed(by: rx.disposeBag)
        getStartedButton.rx.tap.bind(to: viewModel.inputs.getStartedObserver).disposed(by: rx.disposeBag)
    }
}
