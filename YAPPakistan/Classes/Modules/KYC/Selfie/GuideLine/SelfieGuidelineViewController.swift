//
//  SelfieGuidelineViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 13/10/2021.
//

import YAPComponents
import RxTheme
import RxSwift

class SelfieGuidelineViewController: UIViewController {

    private let titleLabel = UIFactory.makeLabel(font: .title2, alignment: .center)
    private let subTitleLabel = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0)
    private let selfieImage = UIFactory.makeImageView()
    private let tipsContainer = UIFactory.makeView() // .setBackgroundColor(.blue)
    private let tipsIconContainer = UIFactory.makeView(cornerRadious: 15)
    private let tipsIcon = UIFactory.makeImageView()
    private let tipsLabel = UIFactory.makeLabel(font: .regular, numberOfLines: 0)
    private let takeSelfieButton = UIFactory.makeAppRoundedButton(with: .regular)
    let spacers = [UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView()]
    private var backButton: UIButton!

    private var themeService: ThemeService<AppTheme>!
    var viewModel: SelfieGuidelineViewModelType!

    convenience init(themeService: ThemeService<AppTheme>, viewModel: SelfieGuidelineViewModelType) {
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
            .addSub(view: titleLabel)
            .addSub(view: subTitleLabel)
            .addSub(view: selfieImage)
            .addSub(view: tipsContainer)
            .addSub(view: takeSelfieButton)
            .addSub(view: spacers[0])
            .addSub(view: spacers[1])
            .addSub(view: spacers[2])
        tipsContainer
            .addSub(view: tipsIconContainer)
            .addSub(view: tipsLabel)
        tipsIconContainer
            .addSub(view: tipsIcon)
        backButton = addBackButton(of: .backEmpty)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: subTitleLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: tipsLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: takeSelfieButton.rx.enabledBackgroundColor)
            .bind({ UIColor($0.primaryExtraLight) }, to: tipsIconContainer.rx.backgroundColor)
            .bind({ UIColor($0.primary) }, to: backButton.rx.tintColor)
            .disposed(by: rx.disposeBag)
    }

    func setupResources() {
        selfieImage.image = UIImage(named: "selfie_guide_image", in: .yapPakistan)
        tipsIcon.image = UIImage(named: "tips", in: .yapPakistan)
    }

    func setupLanguageStrings() {
        viewModel.outputs.languageStrings.withUnretained(self)
            .subscribe(onNext: { `self`, strings in
                self.titleLabel.text = strings.title
                self.subTitleLabel.text = strings.subTitle
                self.tipsLabel.text = strings.tips
                self.takeSelfieButton.setTitle(strings.action, for: .normal)
            })
            .disposed(by: rx.disposeBag)
    }

    func setupBindings() {
        backButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
        takeSelfieButton.rx.tap.bind(to: viewModel.inputs.nextObserver).disposed(by: rx.disposeBag)
    }

    func setupConstraints() {
        titleLabel
            .alignEdgesWithSuperview([.left, .right, .safeAreaTop], constants: [25, 25, 10])

        subTitleLabel
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
            .toBottomOf(titleLabel, constant: 10)

        spacers[0]
            .toBottomOf(subTitleLabel)
            .alignEdgesWithSuperview([.left, .right])

        selfieImage
            .toBottomOf(spacers[0])
            .widthEqualToSuperView(multiplier: 280 / 375)
            .aspectRatio(1)
            .centerHorizontallyInSuperview()

        spacers[1]
            .toBottomOf(selfieImage)
            .alignEdgesWithSuperview([.left, .right])

        tipsContainer
            .toBottomOf(spacers[1])
            .widthEqualToSuperView(multiplier: 280 / 375)
            .centerHorizontallyInSuperview()
            .height(constant: 50)

        tipsIconContainer
            .alignEdgesWithSuperview([.top, .left, .bottom])
            .aspectRatio()
        tipsIcon
            .centerVerticallyInSuperview()
            .centerHorizontallyInSuperview()
            .height(constant: 25)
            .width(constant: 25)
        tipsLabel
            .alignEdgesWithSuperview([.top, .bottom, .right], constants: [0, 0, 0])
            .toRightOf(tipsIconContainer, constant: 10)

        spacers[2]
            .toBottomOf(tipsContainer)
            .alignEdgesWithSuperview([.left, .right])

        takeSelfieButton
            .toBottomOf(spacers[2])
            .alignEdgesWithSuperview([.safeAreaBottom], constant: 25)
            .centerHorizontallyInSuperview()
            .width(constant: 200)
            .height(constant: 52)

        spacers[0]
            .heightEqualTo(view: spacers[1])
            .heightEqualTo(view: spacers[2])
    }
}
