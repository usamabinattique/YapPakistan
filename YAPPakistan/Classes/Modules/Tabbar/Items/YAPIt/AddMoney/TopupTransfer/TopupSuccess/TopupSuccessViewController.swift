//
//  TopupSuccessViewController.swift
//  YAP
//
//  Created by Wajahat Hassan on 11/11/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents
import RxTheme

class TopupSuccessViewController: UIViewController {
    
    // MARK: - Views
    lazy var cardImageView = UIFactory.makeImageView(contentMode: .scaleAspectFill)
    lazy var cardTitle = UIFactory.makeLabel(font: .large, alignment: .center)
    lazy var cardNumber = UIFactory.makeLabel(font: .small, alignment: .center)
    lazy var successMessage = UIFactory.makeLabel(alignment: .center, numberOfLines:0, lineBreakMode: .byWordWrapping)
    lazy var accountBalanceTitle = UIFactory.makeLabel(font: .small, alignment: .center)
    lazy var balance = UIFactory.makeLabel(font: .title2, alignment: .center)
    lazy var successImageView = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    lazy var dashboardActionButton = AppRoundedButtonFactory.createAppRoundedButton(font: .regular)
    //lazy var tickIcon = UIFactory.makeImageView()
    
    // MARK: - Properties
    let viewModel: TopupSuccessViewModelType
    let themeService: ThemeService<AppTheme>
    let disposeBag: DisposeBag
    
    // MARK: - Init
    init(themeService: ThemeService<AppTheme>, viewModel: TopupSuccessViewModelType) {
        self.viewModel = viewModel
        self.themeService = themeService
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubViews()
        setupConstraints()
        setupBindings()
        setupTheme()
        //setupResources()
    }
    
//    func setupResources() {
//        self.tickIcon.image = UIImage(named: "tickIcon", in: .yapPakistan)
//    }
}

extension TopupSuccessViewController: ViewDesignable {
    func setupSubViews() {
        hideBackButton()
        view.backgroundColor = .white
        view.addSubview(cardImageView)
        view.addSubview(cardTitle)
        view.addSubview(cardNumber)
        view.addSubview(successMessage)
        view.addSubview(accountBalanceTitle)
        view.addSubview(balance)
        view.addSubview(successImageView)
        view.addSubview(dashboardActionButton)
    }
    
    func setupConstraints() {
        
        cardImageView
            .alignEdgeWithSuperviewSafeArea(.top, constant: 60)
            .width(constant: 90)
            .height(constant: 56)
            .centerHorizontallyInSuperview()
        
        cardTitle
            .toBottomOf(cardImageView, constant: 30)
            .alignEdgesWithSuperview([.left, .right], constants: [80, 80])
            .height(constant: 32)

        cardNumber
            .toBottomOf(cardTitle)
            .alignEdgesWithSuperview([.left, .right], constants: [80, 80])
            .height(constant: 22)
        
        successMessage
            .toBottomOf(cardNumber, constant: 14)
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
        
        accountBalanceTitle
            .toBottomOf(successMessage, constant: 22)
            .alignEdgesWithSuperview([.left, .right], constants: [80, 80])
            .height(constant: 20)
        
        balance
            .toBottomOf(accountBalanceTitle)
            .alignEdgesWithSuperview([.left, .right], constants: [60, 60])
            .height(constant: 36)
        
        successImageView
            .toBottomOf(balance, constant: 44)
            .width(constant: 90)
            .height(constant: 90)
            .centerHorizontallyInSuperview()
        
        dashboardActionButton
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 20)
            .width(constant: 240)
            .height(constant: 52)
            .centerHorizontallyInSuperview()
        
    }
    
    func setupBindings() {
        
        viewModel.outputs.cardImage.bind(to: cardImageView.rx.image).disposed(by: disposeBag)
        viewModel.outputs.cardTitle.bind(to: cardTitle.rx.text).disposed(by: disposeBag)
        viewModel.outputs.cardNumber.bind(to: cardNumber.rx.text).disposed(by: disposeBag)
        viewModel.outputs.successMessage.bind(to: successMessage.rx.attributedText).disposed(by: disposeBag)
        viewModel.outputs.accountBalanceTitle.bind(to: accountBalanceTitle.rx.text).disposed(by: disposeBag)
        viewModel.outputs.balance.bind(to: balance.rx.text).disposed(by: disposeBag)
        viewModel.outputs.sucessImage.bind(to: successImageView.rx.image).disposed(by: disposeBag)
        viewModel.outputs.screenTitle.unwrap().bind(to: self.rx.title).disposed(by: disposeBag)
        viewModel.outputs.dashboardButtonTitle.bind(to: dashboardActionButton.rx.title(for: .normal)).disposed(by: disposeBag)
        
        dashboardActionButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: disposeBag)
        
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [cardTitle.rx.textColor, balance.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [cardNumber.rx.textColor, accountBalanceTitle.rx.textColor])
            .bind({ UIColor($0.primary) }, to: dashboardActionButton.rx.enabledBackgroundColor)
            .disposed(by: rx.disposeBag)
    }
    
}
