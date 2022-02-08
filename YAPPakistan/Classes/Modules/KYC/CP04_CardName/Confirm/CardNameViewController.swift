//
//  CardNameViewController.swift
//  Adjust
//
//  Created by Sarmad on 18/10/2021.
//

import YAPComponents
import RxTheme
import RxSwift

class CardNameViewController: UIViewController {

    private let titleLabel = UIFactory.makeLabel(font: .title2, alignment: .center, numberOfLines: 0)
    private let subTitleLabel = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0)
    private let cardImage = UIFactory.makeImageView()
    private let isThisLabel = UIFactory.makeLabel(font: .regular)

    private let nameContainer = UIFactory.makeCircularView()
    private let nameLabel = UIFactory.makeLabel(font: .regular)

    private let tipsLabel = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0)
    private let thisIsFineButton = UIFactory.makeAppRoundedButton(with: .regular)
    private let editNameButton = UIFactory.makeButton(with: .regular)
    let spacers = [UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView(),
                   UIFactory.makeView()]

    var backButton: UIButton!

    private var themeService: ThemeService<AppTheme>!
    var viewModel: CardNameViewModelType!

    convenience init(themeService: ThemeService<AppTheme>, viewModel: CardNameViewModelType) {
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
            .addSub(view: cardImage)
            .addSub(view: isThisLabel)
            .addSub(view: nameContainer)
            .addSub(view: tipsLabel)
            .addSub(view: thisIsFineButton)
            .addSub(view: editNameButton)
            .addSub(view: spacers[0])
            .addSub(view: spacers[1])
            .addSub(view: spacers[2])
            .addSub(view: spacers[3])
            .addSub(view: spacers[4])
        nameContainer
            .addSub(view: nameLabel)

        backButton = addBackButton(of: .backEmpty)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: subTitleLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: [tipsLabel.rx.textColor,nameLabel.rx.textColor])
            //.bind({ UIColor($0.primaryExtraLight) }, to: nameContainer.rx.backgroundColor)
            .bind({ UIColor($0.greyLight).withAlphaComponent(0.50) }, to: nameContainer.rx.backgroundColor)
           // .bind({ UIColor($0.primary) }, to: nameLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: isThisLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: thisIsFineButton.rx.enabledBackgroundColor)
            .bind({ UIColor($0.primary) }, to: editNameButton.rx.titleColor(for: .normal))
            .bind({ UIColor($0.primary) }, to: backButton.rx.tintColor)
            .disposed(by: rx.disposeBag)
    }

    func setupResources() {
        cardImage.image = UIImage(named: "payment_card", in: .yapPakistan)
    }

    func setupLanguageStrings() {
        viewModel.outputs.languageStrings.withUnretained(self)
            .subscribe(onNext: { `self`, strings in
                self.titleLabel.text = strings.title
                self.subTitleLabel.text = strings.subTitle
                self.isThisLabel.text = strings.isThis
                self.tipsLabel.text = strings.tips
                self.thisIsFineButton.setTitle(strings.thisIsFine, for: .normal)
                self.editNameButton.setTitle(strings.editName, for: .normal)
            })
            .disposed(by: rx.disposeBag)
    }

    func setupBindings() {
        viewModel.outputs.showError.subscribe(onNext: { [weak self] error in
            self?.showAlert(title: "", message: error,
                            defaultButtonTitle: "common_button_ok".localized)
        }).disposed(by: rx.disposeBag)
        viewModel.outputs.name.bind(to: nameLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.loading.bind(to: rx.loader).disposed(by: rx.disposeBag)

        thisIsFineButton.rx.tap.bind(to: viewModel.inputs.nextObserver).disposed(by: rx.disposeBag)
        editNameButton.rx.tap.bind(to: viewModel.inputs.editObserver).disposed(by: rx.disposeBag)
       // backButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
        backButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.navigationController?.popViewController()
            self?.viewModel.inputs.backObserver.onNext(())
//            self?.navigationController?.dismiss(animated: true
//                                                , completion: {
//                self?.viewModel.inputs.backObserver.onNext(())
//            })
        }).disposed(by: rx.disposeBag)

    }

    func setupConstraints() {
        titleLabel
            .alignEdgesWithSuperview([.left, .right, .safeAreaTop], constants: [25, 25, 10])

        spacers[4]
            .toBottomOf(titleLabel)
            .alignEdgesWithSuperview([.left, .right])

        subTitleLabel
            .toBottomOf(spacers[4])
            .alignEdgesWithSuperview([.left, .right], constant: 25)

        spacers[0]
            .toBottomOf(subTitleLabel)
            .alignEdgesWithSuperview([.left, .right])

        cardImage
            .toBottomOf(spacers[0])
            .centerHorizontallyInSuperview()
            .widthEqualToSuperView(multiplier: 148 / 375)
            .aspectRatio(221 / 148)

        spacers[1]
            .toBottomOf(cardImage)
            .alignEdgesWithSuperview([.left, .right])

        isThisLabel
            .toBottomOf(spacers[1])
            .centerHorizontallyInSuperview()

        nameContainer
            .toBottomOf(isThisLabel, constant: 10)
            .widthEqualToSuperView(multiplier: 249 / 375)
            .centerHorizontallyInSuperview()
            .height(constant: 44)
        nameLabel
            .centerHorizontallyInSuperview()
            .centerVerticallyInSuperview()

        spacers[2]
            .toBottomOf(nameContainer)
            .alignEdgesWithSuperview([.left, .right])

        tipsLabel
            .toBottomOf(spacers[2])
            .alignEdgesWithSuperview([.right, .left], constant: 25)

        spacers[3]
            .toBottomOf(tipsLabel)
            .alignEdgesWithSuperview([.left, .right])

        thisIsFineButton
            .toBottomOf(spacers[3])
            .centerHorizontallyInSuperview()
            .width(constant: 250)
            .height(constant: 52)

        editNameButton
            .toBottomOf(thisIsFineButton, constant: 10)
            .alignEdgesWithSuperview([.safeAreaBottom], constant: 10)
            .centerHorizontallyInSuperview()

        spacers[4]
            .heightEqualTo(view: spacers[0], constant: 3)
            .heightEqualTo(view: spacers[1], constant: 3)
            .heightEqualTo(view: spacers[2])
            .heightEqualTo(view: spacers[3])
    }
}
