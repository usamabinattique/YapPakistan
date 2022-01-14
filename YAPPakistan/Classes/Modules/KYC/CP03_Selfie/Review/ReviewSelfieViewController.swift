//
//  ReviewSelfieViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 14/10/2021.
//

import YAPComponents
import RxTheme
import RxSwift

class ReviewSelfieViewController: UIViewController {

    private let titleLabel = UIFactory.makeLabel(font: .title2, alignment: .center)
    private let subTitleLabel = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0)
    private let selfieContainer = UIFactory.makeView().setCornerRadius(12).shaddow()
    private let selfieImage = UIFactory.makeImageView(contentMode: .scaleAspectFill).setCornerRadius(10)
    private let yesThatsMeButton = UIFactory.makeAppRoundedButton(with: .regular)
    private let retakeButton = UIFactory.makeButton(with: .regular)
    private let spacers = [UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView()]
    private var backButton: UIButton!

    private var themeService: ThemeService<AppTheme>!
    var viewModel: ReviewSelfieViewModelType!

    convenience init(themeService: ThemeService<AppTheme>, viewModel: ReviewSelfieViewModelType) {
        self.init(nibName: nil, bundle: nil)

        self.themeService = themeService
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTheme()
        setupLanguageStrings()
        setupBindings()
        setupConstraints()
    }

    func setupViews() {
        view
            .addSub(view: titleLabel)
            .addSub(view: subTitleLabel)
            .addSub(view: selfieContainer)
            .addSub(view: yesThatsMeButton)
            .addSub(view: retakeButton)
            .addSub(view: spacers[0])
            .addSub(view: spacers[1])
            .addSub(view: spacers[2])
            .addSub(view: spacers[3])
        selfieContainer
            .addSub(view: selfieImage)
        backButton = addBackButton(of: .backEmpty)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: subTitleLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: yesThatsMeButton.rx.enabledBackgroundColor)
            .bind({ UIColor($0.primary) }, to: retakeButton.rx.titleColor(for: .normal))
            .bind({ UIColor($0.backgroundColor) }, to: selfieContainer.rx.backgroundColor)
            .bind({ UIColor($0.primary) }, to: backButton.rx.tintColor)
            .disposed(by: rx.disposeBag)
    }

    func setupLanguageStrings() {
        viewModel.outputs.languageStrings.withUnretained(self)
            .subscribe(onNext: { `self`, strings in
                self.titleLabel.text = strings.title
                self.subTitleLabel.text = strings.subTitle
                self.yesThatsMeButton.setTitle(strings.yesItsMe, for: .normal)
                self.retakeButton.setTitle(strings.retakeSelfie, for: .normal)
            })
            .disposed(by: rx.disposeBag)
    }

    func setupBindings() {
        viewModel.outputs.showError.subscribe(onNext: { [weak self] error in
            self?.showAlert(title: "", message: error,
                            defaultButtonTitle: "common_button_ok".localized)
        }).disposed(by: rx.disposeBag)
        viewModel.outputs.image.bind(to: selfieImage.rx.image).disposed(by: rx.disposeBag)
        viewModel.outputs.loading.bind(to: rx.loader).disposed(by: rx.disposeBag)

        retakeButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
        backButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
        yesThatsMeButton.rx.tap.bind(to: viewModel.inputs.nextObserver).disposed(by: rx.disposeBag)
    }

    func setupConstraints() {
        spacers[0]
            .alignEdgesWithSuperview([.left, .right, .safeAreaTop])

        titleLabel
            .toBottomOf(spacers[0])
            .alignEdgesWithSuperview([.left, .right], constant: 25)

        spacers[1]
            .toBottomOf(titleLabel)
            .alignEdgesWithSuperview([.left, .right])

        selfieContainer
            .toBottomOf(spacers[1])
            .widthEqualToSuperView(multiplier: 219 / 375)
            .centerHorizontallyInSuperview()
            .aspectRatio(248 / 219)
        selfieImage
            .alignEdgesWithSuperview([.left, .right, .top, .bottom], constant: 12)

        spacers[2]
            .toBottomOf(selfieContainer)
            .alignEdgesWithSuperview([.left, .right])

        subTitleLabel
            .toBottomOf(spacers[2])
            .widthEqualToSuperView(multiplier: 315 / 375)
            .centerHorizontallyInSuperview()

        spacers[3]
            .toBottomOf(subTitleLabel)
            .alignEdgesWithSuperview([.left, .right])

        yesThatsMeButton
            .toBottomOf(spacers[3])
            .centerHorizontallyInSuperview()
            .width(constant: 200)
            .height(constant: 52)

        retakeButton
            .toBottomOf(yesThatsMeButton, constant: 10)
            .alignEdgesWithSuperview([.safeAreaBottom], constant: 10)
            .centerHorizontallyInSuperview()

        spacers[3]
            .heightEqualTo(view: spacers[0], multiplier: 2)
            .heightEqualTo(view: spacers[1], multiplier: 2)
            .heightEqualTo(view: spacers[2], multiplier: 2)
    }
}
