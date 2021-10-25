//
//  EditNameViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 18/10/2021.
//

import YAPComponents
import RxTheme
import RxSwift

class EditNameViewController: UIViewController {

    private let titleLabel = UIFactory.makeLabel(font: .title2, alignment: .center, numberOfLines: 0)
    private let subTitleLabel = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0)
    private let tipsLabel = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0)
    private let nextButton = UIFactory.makeAppRoundedButton(with: .regular)
    private let textField = UIFactory.makeFloatingTextField(font: .regular,
                                                            fontPlaceholder: .small,
                                                            returnKeyType: .done,
                                                            capitalization: .words)
    private let cardImageView = UIFactory.makeImageView()
    private let nameLabel = UIFactory.makeLabel(font: .small)
    private let latterCountLabel = UIFactory.makeLabel(font: .micro, alignment: .right)

    let spacers = [UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView(),
                   UIFactory.makeView()]

    var backButton: UIButton!
    var nextButtonBottomAncher: NSLayoutConstraint!

    private var themeService: ThemeService<AppTheme>!
    var viewModel: EditNameViewModelType!

    convenience init(themeService: ThemeService<AppTheme>, viewModel: EditNameViewModelType) {
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
            .addSub(view: cardImageView)
            .addSub(view: textField)
            .addSub(view: tipsLabel)
            .addSub(view: nextButton)
            .addSub(view: spacers[0])
            .addSub(view: spacers[1])
            .addSub(view: spacers[2])
            .addSub(view: spacers[3])
            .addSub(view: spacers[4])

        cardImageView
            .addSub(view: nameLabel)
            .addSub(view: latterCountLabel)

        backButton = addBackButton(of: .backEmpty)

    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: subTitleLabel.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: nameLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: latterCountLabel.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: textField.placeholderLabel.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: textField.rx.textColor)
            .bind({ UIColor($0.greyLight) }, to: textField.rx.bottomLineColorNormal)
            .bind({ UIColor($0.primary) }, to: textField.rx.bottomLineColorWhileEditing)
            .bind({ UIColor($0.greyDark) }, to: tipsLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: nextButton.rx.enabledBackgroundColor)
            .bind({ UIColor($0.greyDark) }, to: nextButton.rx.disabledBackgroundColor)
            .disposed(by: rx.disposeBag)

        guard backButton != nil else { return }
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [ backButton.rx.tintColor ])
            .disposed(by: rx.disposeBag)
    }

    func setupResources() {
        cardImageView.image = UIImage(named: "card_back", in: .yapPakistan)
    }

    func setupLanguageStrings() {
        viewModel.outputs.languageStrings.withUnretained(self)
            .subscribe(onNext: { `self`, strings in
                self.titleLabel.text = strings.title
                self.subTitleLabel.text = strings.subTitle
                self.textField.placeholder = strings.typeYourName
                self.tipsLabel.text = strings.tips
                self.nextButton.setTitle(strings.next, for: .normal)
            })
            .disposed(by: rx.disposeBag)
    }

    func setupBindings() {
        let sharedName = viewModel.outputs.name
        sharedName.bind(to: textField.rx.text).disposed(by: rx.disposeBag)
        sharedName.map({ $0.count > 0 }).bind(to: nextButton.rx.isEnabled).disposed(by: rx.disposeBag)
        viewModel.outputs.cardName.bind(to: nameLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.charCount.bind(to: latterCountLabel.rx.text).disposed(by: rx.disposeBag)

        nextButton.rx.tap.bind(to: viewModel.inputs.nextObserver).disposed(by: rx.disposeBag)
        textField.rx.text.unwrap().bind(to: viewModel.inputs.nameObserver).disposed(by: rx.disposeBag)
        backButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)

        view.rx.tapGesture().withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.view.endEditing(true) })
            .disposed(by: rx.disposeBag)

        textField.rx.controlEvent(.editingDidBegin).withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                UIView.animate(withDuration: 0.3) {
                    self.nextButtonBottomAncher.constant = 160
                    self.view.layoutSubviews()
                }
            }).disposed(by: rx.disposeBag)

        textField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] _ in guard let self = self else { return }
                UIView.animate(withDuration: 0.3) {
                    self.nextButtonBottomAncher.constant = 25
                    self.view.layoutSubviews()
                }
            }).disposed(by: rx.disposeBag)
    }

    func setupConstraints() {
        titleLabel
            .alignEdgesWithSuperview([.left, .right, .safeAreaTop], constant: 25)

        spacers[0]
            .toBottomOf(titleLabel)
            .alignEdgesWithSuperview([.left, .right])

        subTitleLabel
            .toBottomOf(spacers[0])
            .alignEdgesWithSuperview([.left, .right], constant: 25)

        spacers[1]
            .toBottomOf(subTitleLabel)
            .alignEdgesWithSuperview([.left, .right])

        cardImageView
            .toBottomOf(spacers[1])
            .alignEdgesWithSuperview([.left, .right], constant: 26)
        nameLabel
            .alignEdgesWithSuperview([.bottom, .left], constants: [22, 13])
            .width(constant: 200)
        latterCountLabel
            .alignEdgesWithSuperview([.right], constants: [22])
            .centerVerticallyWith(nameLabel)
            .width(constant: 50)

        spacers[2]
            .toBottomOf(cardImageView)
            .alignEdgesWithSuperview([.left, .right])

        textField
            .toBottomOf(spacers[2])
            .alignEdgesWithSuperview([.left, .right], constant: 26)
            .height(constant: 50)

        spacers[3]
            .toBottomOf(textField)
            .alignEdgesWithSuperview([.left, .right])

        tipsLabel
            .toBottomOf(spacers[3])
            .alignEdgesWithSuperview([.right, .left], constant: 25)

        spacers[4]
            .toBottomOf(tipsLabel)
            .alignEdgesWithSuperview([.left, .right])

        nextButton
            .toBottomOf(spacers[4])
            .alignEdgeWithSuperview(.safeAreaBottom, constant: 25, assignTo: &nextButtonBottomAncher)
            .centerHorizontallyInSuperview()
            .width(constant: 294)
            .height(constant: 52)

        spacers[0]
            .heightEqualTo(view: spacers[1])
            .heightEqualTo(view: spacers[2])
            .heightEqualTo(view: spacers[3])
            .heightEqualTo(view: spacers[4], multiplier: 1 / 4)
    }
}
