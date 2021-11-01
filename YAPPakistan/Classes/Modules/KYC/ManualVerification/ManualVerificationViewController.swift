//
//  ManualVerificationViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 01/11/2021.
//

import YAPComponents
import RxSwift
import RxTheme

class ManualVerificationViewController: UIViewController {

    private let infoImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private let titleLabel = UIFactory.makeLabel(font: .title2, alignment: .center, numberOfLines: 0)
    private let subTitleLabel = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0)
    private let dashboardButton = UIFactory.makeAppRoundedButton(with: .regular)

    let spacers = [UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView()]

    private var themeService: ThemeService<AppTheme>!
    var viewModel: ManualVerificationViewModelType!

    convenience init(themeService: ThemeService<AppTheme>, viewModel: ManualVerificationViewModelType) {
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
            .addSub(view: infoImage)
            .addSub(view: titleLabel)
            .addSub(view: subTitleLabel)
            .addSub(view: dashboardButton)
            .addSub(views: spacers)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: subTitleLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: dashboardButton.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
    }

    func setupResources() {
        infoImage.image = UIImage(named: "info_needed", in: .yapPakistan)
    }

    func setupLanguageStrings() {
        viewModel.outputs.languageStrings.withUnretained(self)
            .subscribe(onNext: { `self`, strings in
                self.titleLabel.text = strings.title
                self.subTitleLabel.text = strings.subTitle
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

        titleLabel
            .toBottomOf(spacers[0])
            .alignEdgesWithSuperview([.left, .right], constants: [22, 22])

        spacers[1]
            .toBottomOf(titleLabel)
            .alignEdgesWithSuperview([.left, .right])

        infoImage
            .toBottomOf(spacers[1])
            .widthEqualToSuperView(multiplier: 260 / 375)
            .aspectRatio(227 / 260)
            .centerHorizontallyInSuperview()

        spacers[2]
            .toBottomOf(infoImage)
            .alignEdgesWithSuperview([.left, .right])

        subTitleLabel
            .toBottomOf(spacers[2])
            .alignEdgesWithSuperview([.left, .right], constants: [22, 22])

        spacers[3]
            .toBottomOf(subTitleLabel)
            .alignEdgesWithSuperview([.left, .right])

        dashboardButton
            .toBottomOf(spacers[3])
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.safeAreaBottom, constant: 25)
            .width(constant: 250)
            .height(constant: 52)

        spacers[0]
            .heightEqualTo(view: spacers[1])
            .heightEqualTo(view: spacers[2])
            .heightEqualTo(view: spacers[3], multiplier: 1 / 5)
    }
}
