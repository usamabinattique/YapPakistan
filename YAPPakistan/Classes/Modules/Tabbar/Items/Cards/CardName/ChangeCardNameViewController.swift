//
//  ChangeCardNameViewController.swift
//  Adjust
//
//  Created by Sarmad on 12/12/2021.
//

import YAPComponents
import RxTheme
import RxSwift

class  ChangeCardNameViewController: UIViewController {

    private let titleLabel = UIFactory.makeLabel(font: .large)
    private let cardImageView = UIFactory.makeImageView()
    private let textField = UIFactory.makeFloatingTextField(font: .regular,
                                                            fontPlaceholder: .small,
                                                            returnKeyType: .done,
                                                            capitalization: .words)
    private let nextButton = UIFactory.makeAppRoundedButton(with: .regular)

    let spacers = [UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView()]

    var backButton: UIButton!
    var nextButtonTopAncher: NSLayoutConstraint!

    private var themeService: ThemeService<AppTheme>!
    var viewModel:  ChangeCardNameViewModelType!

    convenience init(themeService: ThemeService<AppTheme>, viewModel: ChangeCardNameViewModelType) {
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
        view.addSub(views: [cardImageView, textField, nextButton])
            .addSub(views: spacers)
        navigationItem.titleView = titleLabel
        backButton = addBackButton(of: .backEmpty)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: textField.placeholderLabel.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: textField.rx.textColor)
            .bind({ UIColor($0.greyLight) }, to: textField.rx.bottomLineColorNormal)
            .bind({ UIColor($0.primary) }, to: textField.rx.bottomLineColorWhileEditing)
            .bind({ UIColor($0.primary) }, to: nextButton.rx.enabledBackgroundColor)
            .bind({ UIColor($0.greyDark) }, to: nextButton.rx.disabledBackgroundColor)
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
                self.titleLabel.text = strings.title
                self.textField.placeholder = strings.typeYourName
                self.nextButton.setTitle(strings.next, for: .normal)
            })
            .disposed(by: rx.disposeBag)
    }

    func setupBindings() {
        let sharedName = viewModel.outputs.name
        sharedName.bind(to: textField.rx.text).disposed(by: rx.disposeBag)
        sharedName.map({ $0.count > 0 }).bind(to: nextButton.rx.isEnabled).disposed(by: rx.disposeBag)
//        viewModel.outputs.cardName.bind(to: nameLabel.rx.text).disposed(by: rx.disposeBag)
//        viewModel.outputs.charCount.bind(to: latterCountLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.loading.bind(to: rx.loader).disposed(by: rx.disposeBag)
        viewModel.outputs.error.withUnretained(self)
            .subscribe(onNext: { `self`, error in
                self.showAlert(title: "",
                               message: error,
                               defaultButtonTitle: "common_button_ok".localized)
        }).disposed(by: rx.disposeBag)

        nextButton.rx.tap.bind(to: viewModel.inputs.nextObserver).disposed(by: rx.disposeBag)
        textField.rx.text.unwrap().bind(to: viewModel.inputs.nameObserver).disposed(by: rx.disposeBag)
        backButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)

        view.rx.tapGesture().withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.view.endEditing(true) })
            .disposed(by: rx.disposeBag)

        textField.rx.controlEvent(.editingDidBegin).withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                    self.nextButtonTopAncher.constant = 220
                    self.view.layoutSubviews()
                }
            }).disposed(by: rx.disposeBag)

        textField.rx.controlEvent(.editingDidEnd).withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                    self.nextButtonTopAncher.constant = 0
                    self.view.layoutSubviews()
                }
            }).disposed(by: rx.disposeBag)
    }

    func setupConstraints() {

        spacers[0]
            .alignEdgesWithSuperview([.left, .right, .safeAreaTop])

        cardImageView
            .toBottomOf(spacers[0])
            .widthEqualToSuperView(multiplier: 0.5)
            .centerHorizontallyInSuperview()
            .aspectRatio(1030 / 652)

        spacers[1]
            .toBottomOf(cardImageView)
            .alignEdgesWithSuperview([.left, .right])

        textField
            .toBottomOf(spacers[1])
            .alignEdgesWithSuperview([.left, .right], constant: 26)
            .height(constant: 52)

        spacers[2]
            .toBottomOf(textField)
            .alignEdgesWithSuperview([.left, .right])

        nextButton
            .toBottomOf(spacers[2], constant: 0, assignTo: &nextButtonTopAncher)
            .alignEdgeWithSuperview(.safeAreaBottom, constant: 25)
            .centerHorizontallyInSuperview()
            .width(constant: 180)
            .height(constant: 52)

        spacers[0]
            .heightEqualTo(view: spacers[1])
            .heightEqualTo(view: spacers[2])
    }
}
