//
//  ReorderCardViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 25/12/2021.
//

import YAPComponents
import RxTheme
import RxSwift

class ReorderCardViewController: UIViewController {
    
    private let titleLabel = UIFactory.makeLabel(font: .large)
    private let cardImageView = UIFactory.makeImageView()
    private let subTitleLabel = UIFactory.makeLabel(
        font: .small,
        insects: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    ).setCornerRadius(12)
    private let feeTitleLabel = UIFactory.makeLabel(font: .small)
    private let feeLabel = UIFactory.makeLabel(font: .title3)
    
    private let balanceContainer = UIFactory.makeView()
    private let balanceTitleLabel = UIFactory.makeLabel(font: .small)
    private let balanceLabel = UIFactory.makeLabel(font: .small)
    
    private let locationContainer = UIFactory.makeView().setCornerRadius(10).setBorder(width: 0.5)
    private let locationIconContainer = UIFactory.makeView().setCornerRadius(20)
    private let locationIcon = UIFactory.makeImageView()
    private let locationSubContainer = UIFactory.makeView()
    private let locationTitleLabel = UIFactory.makeLabel(font: .small)
    private let locationSubTitleLabel = UIFactory.makeLabel(font: .small)
    private let editButton = UIFactory.makeButton(with: .small)
    
    private let nextButton = UIFactory.makeAppRoundedButton(with: .regular)
    private let doitLaterButton = UIFactory.makeButton(with: .regular)
    
    let spacers = [UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView()
                   , UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView()
                   , UIFactory.makeView(), UIFactory.makeView()]
    
    var backButton: UIButton!
    
    private var themeService: ThemeService<AppTheme>!
    var viewModel:  ReorderCardViewModelType!
    
    convenience init(themeService: ThemeService<AppTheme>, viewModel: ReorderCardViewModelType) {
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
        
        locationIcon.image = UIImage(named: "icon_location", in: .yapPakistan)?
            .withRenderingMode(.alwaysTemplate)
    }
    
    func setupViews() {
        view
            .addSub(views: [
                cardImageView,
                subTitleLabel,
                feeTitleLabel,
                feeLabel,
                balanceContainer.addSub(views: [balanceTitleLabel, balanceLabel]),
                locationContainer.addSub(views: [
                    locationIconContainer.addSub(view: locationIcon),
                    locationSubContainer.addSub(views: [ locationTitleLabel, locationSubTitleLabel ]),
                    editButton
                ]),
                nextButton,
                doitLaterButton
            ])
            .addSub(views: spacers)
        
        navigationItem.titleView = titleLabel
        
        backButton = addBackButton(of: .backEmpty)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: subTitleLabel.rx.textColor)
            .bind({ UIColor($0.primaryExtraLight) }, to: subTitleLabel.rx.backgroundColor)
            .bind({ UIColor($0.greyDark) }, to: feeTitleLabel.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: feeLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: balanceTitleLabel.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: balanceLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: locationSubTitleLabel.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: locationTitleLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: editButton.rx.titleColor(for: .normal))
            .bind({ UIColor($0.primaryExtraLight) }, to: locationIconContainer.rx.backgroundColor)
            .bind({ UIColor($0.grey) }, to: locationContainer.rx.borderColor)
            .bind({ UIColor($0.primary) }, to: locationIcon.rx.tintColor)
            .bind({ UIColor($0.primary) }, to: nextButton.rx.enabledBackgroundColor)
            .bind({ UIColor($0.greyDark) }, to: nextButton.rx.disabledBackgroundColor)
            .bind({ UIColor($0.primary) }, to: doitLaterButton.rx.titleColor(for: .normal))
            .disposed(by: rx.disposeBag)
        
        guard backButton != nil else { return }
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [ backButton.rx.tintColor ])
            .disposed(by: rx.disposeBag)
    }
    
    func setupResources() {
        cardImageView.image = UIImage(named: "payment_card", in: .yapPakistan)
    }
    
    func setupLanguageStrings() {
        viewModel.outputs.languageStrings.withUnretained(self)
            .subscribe(onNext: { `self`, strings in
                self.titleLabel.text = "Reorder new card"
                self.subTitleLabel.text = "Primary card"
                self.feeTitleLabel.text = "Card fees"
                self.feeLabel.text = "PKR 39.50"
                self.balanceTitleLabel.text = "Your available balance is"
                self.balanceLabel.text = "PKR 250.00"
                self.locationTitleLabel.text = "12 Street Road 10"
                self.locationSubTitleLabel.text = "Suite 102 lahore"
                self.editButton.setTitle("Edit", for: .normal)
                self.nextButton.setTitle("Confirm purchase", for: .normal)
                self.doitLaterButton.setTitle("Do it later", for: .normal)
            })
            .disposed(by: rx.disposeBag)
    }

    func setupBindings() {
        viewModel.outputs.loading.bind(to: rx.loader).disposed(by: rx.disposeBag)
        viewModel.outputs.error.withUnretained(self)
            .subscribe(onNext: { `self`, message in self.showAlert(message: message) })
            .disposed(by: rx.disposeBag)

        editButton.rx.tap.bind(to: viewModel.inputs.editAddressObserver).disposed(by: rx.disposeBag)
        nextButton.rx.tap.bind(to: viewModel.inputs.nextObserver).disposed(by: rx.disposeBag)
        backButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
    }
    
    func setupConstraints() {
        spacers[0]
            .alignEdgesWithSuperview([.left, .right, .safeAreaTop])
        
        cardImageView
            .toBottomOf(spacers[0])
            .widthEqualToSuperView(multiplier: 0.45)
            .centerHorizontallyInSuperview()
            .aspectRatio(1030 / 652)
        spacers[1]
            .toBottomOf(cardImageView)
            .alignEdgesWithSuperview([.left, .right])
        subTitleLabel
            .toBottomOf(spacers[1])
            .centerHorizontallyInSuperview()
            .height(constant: 24)
        
        spacers[2]
            .toBottomOf(subTitleLabel)
            .alignEdgesWithSuperview([.left, .right])
        
        feeTitleLabel
            .toBottomOf(spacers[2])
            .centerHorizontallyInSuperview()
        spacers[3]
            .toBottomOf(feeTitleLabel)
            .alignEdgesWithSuperview([.left, .right])
        feeLabel
            .toBottomOf(spacers[3])
            .centerHorizontallyInSuperview()
        
        spacers[4]
            .toBottomOf(feeLabel)
            .alignEdgesWithSuperview([.left, .right])
        
        balanceContainer
            .toBottomOf(spacers[4])
            .centerHorizontallyInSuperview()
        balanceTitleLabel
            .alignEdgesWithSuperview([.top, .bottom, .left])
        balanceLabel
            .toRightOf(balanceTitleLabel, constant: 4)
            .alignEdgesWithSuperview([.top, .bottom, .right])
        
        
        spacers[5]
            .toBottomOf(balanceContainer)
            .alignEdgesWithSuperview([.left, .right])
        
        locationContainer
            .toBottomOf(spacers[5])
            .alignEdgesWithSuperview([.left, .right], constant: 25)
        
        locationIconContainer
            .alignEdgesWithSuperview([.top, .bottom, .left], constant: 20)
            .aspectRatio()
            .height(constant: 40)
        locationIcon
            .centerInSuperView()
            .widthEqualToSuperView(multiplier: 0.5)
        
        locationSubContainer
            .toRightOf(locationIconContainer, constant: 25)
            .alignEdgesWithSuperview([.top, .bottom], constant: 20)
        locationTitleLabel
            .alignEdgesWithSuperview([.top, .left, .right])
        locationSubTitleLabel
            .alignEdgesWithSuperview([.left, .right, .bottom])
        
        
        editButton
            .centerVerticallyInSuperview()
            .alignEdgesWithSuperview([.right], constant: 20)
        
        spacers[6]
            .toBottomOf(locationContainer)
            .alignEdgesWithSuperview([.left, .right])
        
        nextButton
            .toBottomOf(spacers[6])
            .centerHorizontallyInSuperview()
            .width(constant: 200)
            .height(constant: 52)
        
        spacers[7]
            .toBottomOf(nextButton)
            .alignEdgesWithSuperview([.left, .right])
        
        doitLaterButton
            .toBottomOf(spacers[7])
            .alignEdgeWithSuperview(.safeAreaBottom, constant: 10)
            .centerHorizontallyInSuperview()
        
        spacers[0]
            .heightEqualTo(view: spacers[1], multiplier: 2)
            .heightEqualTo(view: spacers[2])
            .heightEqualTo(view: spacers[3], multiplier: 2)
            .heightEqualTo(view: spacers[4])
            .heightEqualTo(view: spacers[5])
            .heightEqualTo(view: spacers[6])
            .heightEqualTo(view: spacers[7], multiplier: 2)
    }
}

extension UIViewController {
    func showAlert(title: String = "", message: String, buttonTitle: String = "common_button_ok".localized) {
        self.showAlert(title: title, message: message, defaultButtonTitle: buttonTitle)
    }
}
