//
//  CardOnItsWayViewController.swift
//  Adjust
//
//  Created by Sarmad on 01/11/2021.
//

import YAPComponents
import RxSwift
import RxTheme

class CardOnItsWayViewController: UIViewController {

    private let cardImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private let titleLabel = UIFactory.makeLabel(font: .title2, alignment: .center)
    private let subTitleLabel = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0)

    private let cnicContainer = UIFactory.makeView().setCornerRadius(8)
    private let cnicLabel = UIFactory.makeLabel(font: .regular, numberOfLines: 0)
    private let tickMarkImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)

    private let dashboardButton = UIFactory.makeAppRoundedButton(with: .regular)

    let spacers = [UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView()]

    private var themeService: ThemeService<AppTheme>!
    var viewModel: CardOnItsWayViewModelType!

    convenience init(themeService: ThemeService<AppTheme>, viewModel: CardOnItsWayViewModelType) {
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
            .addSub(view: subTitleLabel)
            .addSub(view: cnicContainer)
            .addSub(view: dashboardButton)
            .addSub(views: spacers)

        cnicContainer
            .addSub(view: cnicLabel)
            .addSub(view: tickMarkImage)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: subTitleLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: dashboardButton.rx.backgroundColor)
            .bind({ UIColor($0.primaryExtraLight) }, to: cnicContainer.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: cnicLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: tickMarkImage.rx.tintColor)
            .disposed(by: rx.disposeBag)
    }

    func setupResources() {
        cardImage.image = UIImage(named: "card_on_way", in: .yapPakistan)
        tickMarkImage.image = UIImage(named: "icon_check", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
    }

    func setupLanguageStrings() {
        viewModel.outputs.languageStrings.withUnretained(self)
            .subscribe(onNext: { `self`, strings in
                self.titleLabel.text = strings.title
                self.subTitleLabel.text = strings.subTitle
                self.cnicLabel.text = strings.cinc
                self.dashboardButton.setTitle(strings.goToDashboard, for: .normal)
            })
            .disposed(by: rx.disposeBag)
    }

    func setupBindings() {
        dashboardButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
    }

    func setupConstraints() {

        spacers[0]
            .alignEdgesWithSuperview([.safeAreaTop, .left, .right])

        cardImage
            .toBottomOf(spacers[0])
            .widthEqualToSuperView(multiplier: 295 / 375)
            .centerHorizontallyInSuperview()

        spacers[1]
            .toBottomOf(cardImage)
            .alignEdgesWithSuperview([.left, .right])

        titleLabel
            .toBottomOf(spacers[1])
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])

        spacers[2]
            .toBottomOf(titleLabel)
            .alignEdgesWithSuperview([.left, .right])

        subTitleLabel
            .toBottomOf(spacers[2])
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])

        spacers[3]
            .toBottomOf(subTitleLabel)
            .alignEdgesWithSuperview([.left, .right])

        cnicContainer
            .toBottomOf(spacers[3])
            .widthEqualToSuperView(multiplier: 240 / 375)
            .aspectRatio(61 / 240)
            .centerHorizontallyInSuperview()
        cnicLabel
            .centerVerticallyInSuperview()
            .alignEdgeWithSuperview(.left, constant: 15)
        tickMarkImage
            .centerVerticallyInSuperview()
            .alignEdgeWithSuperview(.right, constant: 15)

        spacers[4]
            .toBottomOf(cnicContainer)
            .alignEdgesWithSuperview([.left, .right])

        dashboardButton
            .toBottomOf(spacers[4])
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.safeAreaBottom, constant: 25)
            .width(constant: 250)
            .height(constant: 52)

        spacers[0]
            .heightEqualTo(view: spacers[1])
            .heightEqualTo(view: spacers[2], multiplier: 2)
            .heightEqualTo(view: spacers[3], multiplier: 2)
            .heightEqualTo(view: spacers[4], multiplier: 1 / 2)
    }
}
