//
//  PinChangeSuccessViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/12/2021.
//

import YAPComponents
import RxSwift
import RxTheme

class PinChangeSuccessViewController: UIViewController {

    private let titleLabel = UIFactory.makeLabel(font: .title2, alignment: .center, numberOfLines: 0)
    private let subTitleLabel = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0)
    private let doneButton = UIFactory.makeAppRoundedButton(with: .regular)

    private var themeService: ThemeService<AppTheme>!
    var viewModel: PinChangeSuccessViewModelType!

    convenience init(themeService: ThemeService<AppTheme>, viewModel: PinChangeSuccessViewModelType) {
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
            .addSub(view: doneButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem()
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: subTitleLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: doneButton.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
    }

    func setupLanguageStrings() {
        viewModel.outputs.languageStrings.withUnretained(self)
            .subscribe(onNext: { `self`, strings in
                self.titleLabel.text = strings.title
                self.subTitleLabel.text = strings.subTitle
            })
            .disposed(by: rx.disposeBag)
        doneButton.setTitle("Done", for: .normal)
    }

    func setupBindings() {
        doneButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
    }

    func setupConstraints() {

        titleLabel
            .alignEdgesWithSuperview([.left, .right, .safeAreaTop], constant: 25)

        subTitleLabel
            .toBottomOf(titleLabel, constant: 25)
            .alignEdgesWithSuperview([.left, .right], constant: 25)

        doneButton
            .alignEdgeWithSuperviewSafeArea(.safeAreaBottom, constant: 25)
            .centerHorizontallyInSuperview()
            .height(constant: 52)
            .width(constant: 160)
    }
}

