//
//  SetPintSuccessViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 11/11/2021.
//

import YAPComponents
import RxSwift
import RxTheme

class SetPintSuccessViewController: UIViewController {

    private let successImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private let titleLabel = UIFactory.makeLabel(font: .title2, alignment: .center, numberOfLines: 0)
    //private let subTitleLabel = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0)
    //private let topupButton = UIFactory.makeAppRoundedButton(with: .regular)
    private let goToDashboardBtn = UIFactory.makeAppRoundedButton(with: .regular)
    let spacers = [UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView()]
    private var backButton: UIButton?

    private var themeService: ThemeService<AppTheme>!
    var viewModel: SetPintSuccessViewModelType!

    convenience init(themeService: ThemeService<AppTheme>, viewModel: SetPintSuccessViewModelType) {
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
            .addSub(view: successImage)
            .addSub(view: titleLabel)
            //.addSub(view: subTitleLabel)
            //.addSub(view: topupButton)
            .addSub(view: goToDashboardBtn)
            .addSub(views: spacers)
        backButton = addBackButton(of: .backEmpty)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            //.bind({ UIColor($0.greyDark) }, to: subTitleLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: goToDashboardBtn.rx.backgroundColor)
            //.bind({ UIColor($0.primary) }, to: goToDashboardBtn.rx.titleColor(for: .normal))
            .disposed(by: rx.disposeBag)

        guard let backButton = backButton else { return }
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [ backButton.rx.tintColor ])
            .disposed(by: rx.disposeBag)
    }

    func setupResources() {
        successImage.image = UIImage(named: "pinset_success", in: .yapPakistan)
    }

    func setupLanguageStrings() {
        viewModel.outputs.languageStrings.withUnretained(self)
            .subscribe(onNext: { `self`, strings in
                self.titleLabel.text = strings.title
                //self.subTitleLabel.text = strings.subTitle
                //self.topupButton.setTitle(strings.topupNow, for: .normal)
                self.goToDashboardBtn.setTitle(strings.doItLater, for: .normal)
            })
            .disposed(by: rx.disposeBag)
    }

    func setupBindings() {
        goToDashboardBtn.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
        backButton?.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
    }

    func setupConstraints() {

        spacers[3]
            .alignEdgesWithSuperview([.safeAreaTop, .left, .right])

        titleLabel
            .toBottomOf(spacers[3])
            .alignEdgesWithSuperview([.left, .right], constant: 25)

        spacers[0]
            .toBottomOf(titleLabel)
            .alignEdgesWithSuperview([.left, .right])

        successImage
            .toBottomOf(spacers[0])
            .alignEdgesWithSuperview([.left, .right], constant: 25)

        spacers[1]
            .toBottomOf(successImage)
            .alignEdgesWithSuperview([.left, .right])

//        subTitleLabel
//            .toBottomOf(s)
//            .alignEdgesWithSuperview([.left, .right], constants: [22, 22])

        spacers[2]
            .toBottomOf(spacers[1])
            .alignEdgesWithSuperview([.left, .right])

//        topupButton
//            .toBottomOf(spacers[2])
//            .centerHorizontallyInSuperview()
//            .width(constant: 250)
//            .height(constant: 52)

        goToDashboardBtn
            .alignEdgeWithSuperview(.safeAreaBottom, constant: 10)
            .centerHorizontallyInSuperview()
            

        spacers[0]
            .heightEqualTo(view: spacers[1], multiplier: 1)
            .heightEqualTo(view: spacers[2], multiplier: 1)
            .heightEqualTo(view: spacers[3], multiplier: 1)
    }
}
