//
//  CardDetailPopUpViewController.swift
//  ios-b2c-pk-components
//
//  Created by Sarmad on 26/11/2021.
//

import UIKit
import YAPComponents
import RxTheme

class CardDetailPopUpViewController: UIViewController {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    let contentContainr = UIFactory.makeView().setCornerRadius(10)

    let cardImage = UIFactory.makeImageView()
    let closeButton = UIFactory.makeButton(with: .title2)

    let titleLabel = UIFactory.makeLabel(font: .small)
    let subTitleLabel = UIFactory.makeLabel(font: .large)

    let numberTitleLabel = UIFactory.makeLabel(font: .small)
    let numberLabel = UIFactory.makeLabel(font: .large)

    let dateTitleLabel = UIFactory.makeLabel(font: .small)
    let dateLabel = UIFactory.makeLabel(font: .large)

    let cvvTitleLabel = UIFactory.makeLabel(font: .small)
    let cvvLabel = UIFactory.makeLabel(font: .large)

    let copyButton = UIFactory.makeAppRoundedButton(with: .small)

    // Properties
    private var viewModel: CardDetailPopUpViewModelType
    private var themeService: ThemeService<AppTheme>

    init(viewModel: CardDetailPopUpViewModelType, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupResources()
        setupTheme()
        setupConstraints()
        setupBindings()
    }

    func setupViews() {
        view.addSub(view: contentContainr)
        contentContainr.addSub(views: [cardImage, closeButton, titleLabel, subTitleLabel,
                                       numberTitleLabel, numberLabel, copyButton, dateTitleLabel,
                                       dateLabel, cvvTitleLabel, cvvLabel])
    }

    func setupResources() {
        viewModel.outputs.resources.withUnretained(self)
            .subscribe(onNext: { `self`, resources in
                self.closeButton.setTitle(resources.closeImage, for: .normal)
                //.setImage(UIImage(named: resources.closeImage), for: .normal)
                self.cardImage.image = UIImage(named: resources.cardImage, in: .yapPakistan)
                self.titleLabel.text = resources.titleLabel
                self.subTitleLabel.text = resources.subTitleLabel
                self.numberTitleLabel.text = resources.numberTitleLabel
                self.numberLabel.text = resources.numberLabel
                self.dateTitleLabel.text = resources.dateTitleLabel
                self.dateLabel.text = resources.dateLabel
                self.cvvTitleLabel.text = resources.cvvTitleLabel
                self.cvvLabel.text = resources.cvvLabel
                self.copyButton.setTitle(resources.copyButtonTitle, for: .normal)
            })
            .disposed(by: rx.disposeBag)
    }

    func setupTheme() {
        themeService.rx
            .bind({ _ in .black.withAlphaComponent(0.5) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.backgroundColor) }, to: [contentContainr.rx.backgroundColor])
            .bind({ UIColor($0.greyDark) }, to: [titleLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [subTitleLabel.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [numberTitleLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [numberLabel.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [dateTitleLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [dateLabel.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [cvvTitleLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [cvvLabel.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [closeButton.rx.titleColor(for: .normal)])
            .bind({ UIColor($0.primary) }, to: [copyButton.rx.titleColor(for: .normal)])
            .bind({ UIColor($0.primaryExtraLight) }, to: [copyButton.rx.enabledBackgroundColor])
            .disposed(by: rx.disposeBag)
    }

    func setupConstraints() {
        contentContainr
            .centerInSuperView()
            .widthEqualToSuperView(multiplier: 0.87)

        closeButton
            .alignEdgesWithSuperview([.top, .right], constant: 5)
            .width(constant: 35).height(constant: 35)

        cardImage
            .alignEdgeWithSuperview(.top, constant: 32)
            .centerHorizontallyInSuperview()
            .widthEqualToSuperView(multiplier: 84 / 330)
            .aspectRatio(134 / 84)

        titleLabel
            .toBottomOf(cardImage, constant: 6)
            .centerHorizontallyInSuperview()

        subTitleLabel
            .toBottomOf(titleLabel, constant: 6)
            .centerHorizontallyInSuperview()

        numberTitleLabel
            .toBottomOf(subTitleLabel, constant: 25)
            .alignEdgeWithSuperview(.left, constant: 25)
        numberLabel
            .toBottomOf(numberTitleLabel, constant: 6)
            .alignEdgeWithSuperview(.left, constant: 25)
        copyButton
            .centerVerticallyWith(numberLabel)
            .alignEdgeWithSuperview(.right, constant: 18)
            .width(constant: 50)

        dateTitleLabel
            .toBottomOf(numberLabel, constant: 25)
            .alignEdgeWithSuperview(.left, constant: 25)
        cvvTitleLabel
            .centerVerticallyWith(dateTitleLabel)
            .alignEdgeWithSuperview(.right, constant: 25)

        dateLabel
            .toBottomOf(dateTitleLabel, constant: 6)
            .alignEdgesWithSuperview([.left, .bottom], constants: [25, 30])
        cvvLabel
            .centerVerticallyWith(dateLabel)
            .alignEdgeWithSuperview(.right, constant: 25)
    }

    func setupBindings() {
        view.rx.tapGesture().map({ _ in () })
            .bind(to: viewModel.inputs.closeObserver)
            .disposed(by: rx.disposeBag)
        closeButton.rx.tap.bind(to: viewModel.inputs.closeObserver).disposed(by: rx.disposeBag)
    }
}
