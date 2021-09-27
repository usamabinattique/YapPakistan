//
//  KYCProgressViewController.swift
//  OnBoarding
//
//  Created by Zain on 06/06/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxTheme
import UIKit
import YAPComponents

class KYCProgressViewController: UIViewController {

    // MARK: Views

    private lazy var progressView: OnBoardingProgressView = {
        let progressView = OnBoardingProgressView()
        progressView.setProgress(0.775)
        progressView.showsProgressView = true
        progressView.showsCompletionView = true
        progressView.backImage = UIImage(named: "icon_back", in: .yapPakistan)
        progressView.completionImage = UIImage(named: "icon_check", in: .yapPakistan)
        return progressView
    }()

    // MARK: Properties

    private var themeService: ThemeService<AppTheme>!
    private var viewModel: KYCProgressViewModelType!

    private let disposeBag = DisposeBag()
    private var childNavigation: UINavigationController!
    private var childView: UIView!
    
    // MARK: Initialization
    
    init(themeService: ThemeService<AppTheme>,
         viewModel: KYCProgressViewModelType,
         withChildNavigation childNav: UINavigationController) {
        super.init(nibName: nil, bundle: nil)

        self.themeService = themeService
        self.viewModel = viewModel
        self.childNavigation = childNav
        self.childView = childNav.view
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTheme()
        setupContraints()
        bindViewModel()
    }

    // MARK: View setup

    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(progressView)
        childView.translatesAutoresizingMaskIntoConstraints = false
        addChild(childNavigation)
        view.addSubview(childView)
        childNavigation.didMove(toParent: self)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.primary) }, to: progressView.rx.tintColor)
            .bind({ UIColor($0.primaryLight) }, to: progressView.rx.disabledColor)
            .disposed(by: disposeBag)
    }

    private func setupContraints() {
        progressView
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .alignEdgeWithSuperviewSafeArea(.top, constant: 20)
            .height(constant: 40)

        childView
            .toBottomOf(progressView)
            .alignEdgesWithSuperview([.left, .right, .bottom])
    }

    // MARK: Binding

    private func bindViewModel() {
        viewModel.outputs.progress
            .bind(to: progressView.rx.progress)
            .disposed(by: disposeBag)

        viewModel.outputs.progress
            .filter { 1 == $0 }
            .map { _ in true }
            .bind(to: progressView.rx.animateCompletion)
            .disposed(by: disposeBag)

        viewModel.outputs.progressCompletion
            .bind(to: progressView.rx.animateCompletion)
            .disposed(by: disposeBag)

        progressView.rx.tapBack
            .bind(to: viewModel.inputs.backTapObserver)
            .disposed(by: disposeBag)
    }
}
