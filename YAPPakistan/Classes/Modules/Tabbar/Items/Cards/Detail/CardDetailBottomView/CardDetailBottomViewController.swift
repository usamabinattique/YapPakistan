//
//  CardDetailBottomViewController.swift
//  ios-b2c-pk-components
//
//  Created by Sarmad on 26/11/2021.
//

import YAPComponents
import RxTheme
import RxSwift

class CardDetailBottomViewController: UIViewController {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let contentContainr = UIFactory.makeView().setCornerRadius(15)
    let safeAreaView = UIFactory.makeView()

    let lineView1 = UIFactory.makeView().setCornerRadius(2)
    let lineView2 = UIFactory.makeView()

    let titleLabel = UIFactory.makeLabel(font: .large)
    let numberTitleLabel = UIFactory.makeLabel(font: .small)
    let numberLabel = UIFactory.makeLabel(font: .large)

    let dateTitleLabel = UIFactory.makeLabel(font: .small)
    let dateLabel = UIFactory.makeLabel(font: .large)

    let cvvTitleLabel = UIFactory.makeLabel(font: .small)
    let cvvLabel = UIFactory.makeLabel(font: .large)

    let copyButton = UIFactory.makeAppRoundedButton(with: .small)

    // Properties
    private var themeService: ThemeService<AppTheme>
    private var viewModel: CardDetailBottomViewModelType

    init(viewModel: CardDetailBottomViewModelType, themeService: ThemeService<AppTheme>) {
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
    }

    func setupViews() {
        view.addSub(views: [contentContainr, safeAreaView])
        contentContainr
            .addSub(views: [
                lineView1, lineView2, titleLabel, numberTitleLabel, numberLabel, copyButton, dateTitleLabel, dateLabel, cvvTitleLabel, cvvLabel
            ])
    }

    func setupResources() {
        viewModel.outputs.resources.withUnretained(self)
            .subscribe(onNext: { `self`, resource in
                self.titleLabel.text = resource.titleLabel
                self.numberTitleLabel.text = resource.numberTitleLabel
                self.numberLabel.text = resource.numberLabel
                self.copyButton.setTitle(resource.copyButtonTitle, for: .normal)
                self.dateTitleLabel.text = resource.dateTitleLabel
                self.dateLabel.text = resource.dateLabel
                self.cvvTitleLabel.text = resource.cvvTitleLabel
                self.cvvLabel.text = resource.cvvLabel
            })
            .disposed(by: rx.disposeBag)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [contentContainr.rx.backgroundColor])
            .bind({ UIColor($0.backgroundColor) }, to: [safeAreaView.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark) }, to: [titleLabel.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [numberTitleLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [numberLabel.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [dateTitleLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [dateLabel.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [cvvTitleLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [cvvLabel.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [copyButton.rx.titleColor(for: .normal)])
            .bind({ UIColor($0.primaryExtraLight) }, to: [copyButton.rx.enabledBackgroundColor])
            .bind({ UIColor($0.primaryExtraLight) }, to: [lineView1.rx.backgroundColor])
            .bind({ UIColor($0.primaryExtraLight) }, to: [lineView2.rx.backgroundColor])
            .bind({ UIColor($0.primaryExtraLight) }, to: [copyButton.rx.backgroundColor])
            .disposed(by: rx.disposeBag)
    }

    func setupConstraints() {
        contentContainr
            .alignEdgesWithSuperview([.left, .right, .safeAreaBottom])
        safeAreaView
            .toBottomOf(contentContainr, constant: -12)
            .alignEdgesWithSuperview([.left, .right, .bottom])

        lineView1
            .alignEdgesWithSuperview([.top], constant: 15)
            .centerHorizontallyInSuperview()
            .height(constant: 4)
            .width(constant: 50)

        titleLabel
            .toBottomOf(lineView1, constant: 25)
            .alignEdgesWithSuperview([.left], constant: 25)

        lineView2
            .toBottomOf(titleLabel, constant: 18)
            .alignEdgesWithSuperview([.left, .right])
            .height(constant: 1)

        numberTitleLabel
            .toBottomOf(lineView2, constant: 18)
            .alignEdgeWithSuperview(.left, constant: 25)
        numberLabel
            .toBottomOf(numberTitleLabel, constant: 6)
            .alignEdgeWithSuperview(.left, constant: 25)
        copyButton
            .centerVerticallyWith(numberLabel)
            .alignEdgeWithSuperview(.right, constant: 18)
            .width(constant: 60)

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
        contentContainr.rx.swipeGesture(.down).map({ _ in () })
            .bind(to: viewModel.inputs.closeObserver)
            .disposed(by: rx.disposeBag)
    }
}
