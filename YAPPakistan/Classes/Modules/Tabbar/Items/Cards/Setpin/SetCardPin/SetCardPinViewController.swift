//
//  SetCardPinViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 11/11/2021.
//

import YAPComponents
import RxSwift
import RxTheme

class SetCardPinViewController: UIViewController {

    private let backgroundImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private let titleLabel = UIFactory.makeLabel(font: .title2, alignment: .center, numberOfLines: 0)
    private let subTitleLabel = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0)
    private let createPinButton = UIFactory.makeAppRoundedButton(with: .regular)
    private let doitLaterButton = UIFactory.makeButton(with: .regular)

    let spacers = [UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView()]

    private var themeService: ThemeService<AppTheme>!
    var viewModel: SetCardPinViewModelType!

    convenience init(themeService: ThemeService<AppTheme>, viewModel: SetCardPinViewModelType) {
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
            .addSub(view: backgroundImage)
            .addSub(view: titleLabel)
            .addSub(view: subTitleLabel)
            .addSub(view: createPinButton)
            .addSub(view: doitLaterButton)
            .addSub(views: spacers)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: subTitleLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: createPinButton.rx.backgroundColor)
            .bind({ UIColor($0.primary) }, to: doitLaterButton.rx.titleColor(for: .normal))
            .disposed(by: rx.disposeBag)
    }

    func setupResources() {
        backgroundImage.image = UIImage(named: "image_backgound", in: .yapPakistan)
    }

    func setupLanguageStrings() {
        viewModel.outputs.languageStrings.withUnretained(self)
            .subscribe(onNext: { `self`, strings in
                self.titleLabel.text = strings.title
                self.subTitleLabel.text = strings.subTitle
                self.createPinButton.setTitle(strings.createPin, for: .normal)
                self.doitLaterButton.setTitle(strings.doItLater, for: .normal)
            })
            .disposed(by: rx.disposeBag)
    }

    func setupBindings() {
        // dashboardButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
    }

    func setupConstraints() {

        backgroundImage
            .alignEdgesWithSuperview([.top, .left, .right])

        spacers[0]
            .toBottomOf(backgroundImage)
            .alignEdgesWithSuperview([.left, .right])

        titleLabel
            .toBottomOf(spacers[0])
            .alignEdgesWithSuperview([.left, .right], constants: [22, 22])

        spacers[1]
            .toBottomOf(titleLabel)
            .alignEdgesWithSuperview([.left, .right])

        subTitleLabel
            .toBottomOf(spacers[1])
            .alignEdgesWithSuperview([.left, .right], constants: [22, 22])

        spacers[2]
            .toBottomOf(subTitleLabel)
            .alignEdgesWithSuperview([.left, .right])

        createPinButton
            .toBottomOf(spacers[2])
            .centerHorizontallyInSuperview()
            .width(constant: 250)
            .height(constant: 52)

        doitLaterButton
            .toBottomOf(createPinButton, constant: 10)
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.safeAreaBottom, constant: 10)

        spacers[2]
            .heightEqualTo(view: spacers[0], multiplier: 4)
            .heightEqualTo(view: spacers[1], multiplier: 5)
    }
}

