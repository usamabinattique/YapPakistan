//
//  OnBoardingViewController.swift
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

class OnBoardingViewController: UIViewController {
    
    private lazy var progressView: OnBoardingProgressView = UIFactory
        .makeOnBoardingProgressView(with: UIImage(named: "icon_back", in: .yapPak), completionImage: UIImage(named: "icon_check", in: .yapPak))
    
    private var childNavigation: UINavigationController?
    private var childView: UIView?
    private var viewModel: OnBoardingViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    init(themeService: ThemeService<AppTheme>, viewModel: OnBoardingViewModelType, withChildNavigation childNav: UINavigationController) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.themeService = themeService
        self.childNavigation = childNav
        self.childView = childNav.view
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupContraints()
        setupTheme()
        bindViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.inputs.startTimeObserver.onNext(())
    }
    
    @objc func tapAction() {
        view.endEditing(true)
    }

}

// MARK: View setup

fileprivate extension OnBoardingViewController {
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(progressView)
        childView?.translatesAutoresizingMaskIntoConstraints = false
        if childView != nil,  childNavigation != nil {
            addChild(childNavigation!)
            view.addSubview(childView!)
        }
        childNavigation?.didMove(toParent: self)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
    }
    
    func setupContraints() {
        progressView
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .alignEdgeWithSuperviewSafeArea(.top, constant: 20)
            .height(constant: 40)
        
        childView?
            .toBottomOf(progressView)
            .alignEdgesWithSuperview([.left, .right, .bottom])
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ $0.primary }, to: [progressView.rx.tintColor])
            .bind({ $0.primaryLight }, to: [progressView.rx.disabledColor])
            .disposed(by: rx.disposeBag)
    }
}

// MARK: Binding

fileprivate extension OnBoardingViewController {
    func bindViews() {
        viewModel.outputs.progress.bind(to: progressView.rx.progress).disposed(by: rx.disposeBag)
        viewModel.outputs.progressCompletion.bind(to: progressView.rx.animateCompletion).disposed(by: rx.disposeBag)
        progressView.rx.tapBack.bind(to: viewModel.inputs.backTapObserver).disposed(by: rx.disposeBag)
    }
}
 
