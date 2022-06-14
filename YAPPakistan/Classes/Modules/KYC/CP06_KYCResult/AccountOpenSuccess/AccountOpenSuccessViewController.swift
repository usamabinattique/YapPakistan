//
//  AccountOpenSuccessViewController.swift
//  Adjust
//
//  Created by Sarmad on 01/11/2021.
//

import YAPComponents
import RxSwift
import RxTheme

class AccountOpenSuccessViewController: UIViewController {
    
    private let cardImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private let titleLabel = UIFactory.makeLabel(font: .title2, alignment: .center, numberOfLines: 0)
    private let dashboardButton = UIFactory.makeAppRoundedButton(with: .regular)
    
    private var themeService: ThemeService<AppTheme>!
    var viewModel: AccountOpenSuccessViewModelType!
    
    convenience init(themeService: ThemeService<AppTheme>, viewModel: AccountOpenSuccessViewModelType) {
        self.init(nibName: nil, bundle: nil)
        
        self.themeService = themeService
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTheme()
        setupResources()
        setupLanguageStrings()
        setupBindings()
        setupConstraints()
    }
    
    func setupViews() {
        view
            .addSub(view: cardImage)
            .addSub(view: titleLabel)
            .addSub(view: dashboardButton)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: dashboardButton.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
    }
    
    func setupResources() {
        cardImage.image = UIImage(named: "account_open_success", in: .yapPakistan)
    }
    
    func setupLanguageStrings() {
        viewModel.outputs.languageStrings.withUnretained(self)
            .subscribe(onNext: { `self`, strings in
                self.titleLabel.text = strings.title
                self.dashboardButton.setTitle(strings.goToDashboard, for: .normal)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func setupBindings() {
        self.dashboardButton.rx.tap.bind(to: viewModel.inputs.gotoDashboardObserver).disposed(by: rx.disposeBag)
        //dashboardButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
    }
    
    func setupConstraints() {
        
        titleLabel
            .centerHorizontallyInSuperview()
            .alignEdgesWithSuperview([.top, .safeAreaLeft, .safeAreaRight], constants: [96, 41, 39])
        
        cardImage
            .centerHorizontallyInSuperview()
            .toBottomOf(titleLabel, constant: 59)
            .height(constant: 230)
            .width(constant: 230)
        
        dashboardButton
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.safeAreaBottom, constant: 25)
            .width(constant: 250)
            .height(constant: 52)
    }
}
