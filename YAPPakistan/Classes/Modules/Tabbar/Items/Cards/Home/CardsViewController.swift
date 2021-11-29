//
//  CardsViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import RxSwift
import YAPComponents
import RxTheme

class CardsViewController: UIViewController {

    private lazy var titleLabelVC = UIFactory.makeLabel(font: .large, alignment: .center)
    private lazy var titleLabel = UIFactory.makeLabel(font: .title2, alignment: .center)
    private lazy var cardImage = UIFactory.makeImageView()
    private lazy var subTitleLabel = UIFactory.makeLabel(font: .regular, alignment: .center)
    private lazy var detailsIcon = UIFactory.makeImageView()
    private lazy var detailsButton = UIFactory.makeButton(with: .regular)
    private lazy var pageNumberLabel = UIFactory.makeLabel(font: .small, alignment: .center)
    private lazy var spacers = [ UIFactory.makeView(), UIFactory.makeView(),
                                 UIFactory.makeView(), UIFactory.makeView(),
                                 UIFactory.makeView() ]
    private lazy var addButton = barButtonItem(image: nil, insectBy: .zero)
    private lazy var sideMenuButton = barButtonItem(image: nil, insectBy: .zero)

    private lazy var iconContainer = UIFactory.makeImageView().shaddow()  // FIXME
    private lazy var clockEyeIcon = UIFactory.makeImageView()   // FIXME

    private lazy var letsDoItLabel = UIFactory.makeButton(with: .regular).setHidden(true)

    private var isPinSet = false { didSet {
        let theme = themeService.attrs
        if isPinSet {
            letsDoItLabel.backgroundColor = .clear
            letsDoItLabel.setTitleColor(UIColor(theme.primaryDark), for: .normal)
            letsDoItLabel.setTitle("PKR 0.0", for: .normal)
            subTitleLabel.text = "Card balance"
            if #available(iOS 13.0, *) {
                clockEyeIcon.image = UIImage(systemName: "eye")
            }
            clockEyeIcon.tintColor = UIColor(theme.primary)
        } else {
            letsDoItLabel.backgroundColor = UIColor(theme.primary)
            letsDoItLabel.setTitleColor(UIColor(theme.backgroundColor), for: .normal)
            letsDoItLabel.setTitle("Let's do it", for: .normal)
            if #available(iOS 13.0, *) {
                clockEyeIcon.image = UIImage(systemName: "clock")
            }
            clockEyeIcon.tintColor = UIColor(theme.secondaryOrange)
        }
        iconContainer.backgroundColor = .white
    }}

    // MARK: - Properties
    fileprivate var themeService: ThemeService<AppTheme>!
    var viewModel: CardsViewModelType!

    // MARK: - Init
    convenience init(themeService: ThemeService<AppTheme>, viewModel: CardsViewModelType) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.themeService = themeService
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupResources()
        setupLocalization()
        setupTheme()
        setupConstraints()
        bindViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.inputs.viewDidAppear.onNext(())
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        letsDoItLabel.layer.cornerRadius = letsDoItLabel.frame.size.height / 2
        iconContainer.layer.cornerRadius = iconContainer.frame.size.height / 2
    }
}

// MARK: - Setup
fileprivate extension CardsViewController {
    func setupViews() {
        view.addSub(views: [ titleLabel,
                             cardImage,
                             subTitleLabel,
                             detailsIcon,
                             detailsButton,
                             pageNumberLabel,
                             letsDoItLabel,
                             iconContainer ])
        iconContainer.addSub(view: clockEyeIcon)
        view.addSub(views: spacers)
        navigationItem.rightBarButtonItem = addButton.barItem
        navigationItem.leftBarButtonItem = sideMenuButton.barItem
        navigationItem.titleView = titleLabelVC

        // addButton.button?.isUserInteractionEnabled = false
    }

    func setupResources() {
        cardImage.image = UIImage(named: "payment_card", in: .yapPakistan)
        detailsIcon.image = UIImage(named: "arrow_up_purple", in: .yapPakistan)
        addButton.button?.setImage(UIImage(named: "icon_home_add", in: .yapPakistan), for: .normal)
        sideMenuButton.button?.setImage(UIImage(named: "icon_menu", in: .yapPakistan), for: .normal)
    }

    func setupLocalization() {
        viewModel.outputs.localizedStrings.withUnretained(self)
            .subscribe(onNext: { `self`, string in
                self.titleLabelVC.text = string.titleView
                self.titleLabel.text = string.titleCard
                self.subTitleLabel.text = self.isPinSet ? "Card balance": string.subTitle
                self.detailsButton.setTitle(string.seeDetail, for: .normal)
                self.pageNumberLabel.text = string.count
            })
            .disposed(by: rx.disposeBag)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark) }, to: [titleLabelVC.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [titleLabel.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [subTitleLabel.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [detailsIcon.rx.tintColor])
            .bind({ UIColor($0.primary) }, to: [detailsButton.rx.titleColor(for: .normal)])
//            .bind({ UIColor($0.primary) }, to: [letsDoItLabel.rx.backgroundColor])
//            .bind({ UIColor($0.backgroundColor) }, to: [letsDoItLabel.rx.titleColor(for: .normal)])
            .bind({ UIColor($0.greyDark) }, to: [pageNumberLabel.rx.textColor])
            .disposed(by: rx.disposeBag)
    }

    func setupConstraints() {
        spacers[0]
            .alignEdgesWithSuperview([.safeAreaTop, .left, .right])

        titleLabel
            .toBottomOf(spacers[0], constant: -5)
            .alignEdgesWithSuperview([.left, .right], constant: 22)
        cardImage
            .toBottomOf(titleLabel, constant: 16)
            .centerHorizontallyInSuperview()
            .widthEqualToSuperView(multiplier: 205 / 375)
            .aspectRatio(325 / 204)
        subTitleLabel
            .toBottomOf(cardImage, constant: 16)
            .alignEdgesWithSuperview([.left, .right], constant: 22)

        spacers[1]
            .toBottomOf(subTitleLabel)
            .alignEdgesWithSuperview([.left, .right])

        letsDoItLabel
            .toBottomOf(spacers[1])
            .centerHorizontallyInSuperview()
            .height(constant: 32)
            .width(constant: 120)

        spacers[2]
            .toBottomOf(letsDoItLabel)
            .alignEdgesWithSuperview([.left, .right])

        detailsIcon
            .toBottomOf(spacers[2])
            .centerHorizontallyInSuperview()
            .height(constant: 30)
            .aspectRatio()
        detailsButton
            .toBottomOf(detailsIcon)
            .centerHorizontallyInSuperview()

        spacers[3]
            .toBottomOf(detailsButton)
            .alignEdgesWithSuperview([.left, .right])

        pageNumberLabel
            .toBottomOf(spacers[3], constant: -5)
            .centerHorizontallyInSuperview()

        spacers[4]
            .toBottomOf(pageNumberLabel)
            .alignEdgesWithSuperview([.left, .right, .safeAreaBottom])

        spacers[0]
            .heightEqualTo(view: spacers[1], multiplier: 2)
            .heightEqualTo(view: spacers[2], multiplier: 2)
            .heightEqualTo(view: spacers[3], multiplier: 1)
            .heightEqualTo(view: spacers[4], multiplier: 1)

        clockEyeIcon
            .alignEdgesWithSuperview([.top, .bottom, .left, .right], constant: 8)
            .height(constant: 25)
            .aspectRatio()

        clockEyeIcon.centerXAnchor.constraint(equalTo: cardImage.rightAnchor, constant: 0).isActive = true
        clockEyeIcon.centerYAnchor.constraint(equalTo: cardImage.topAnchor, constant: 0).isActive = true
    }

    func bindViewModel() {
        viewModel.outputs.loader.bind(to: rx.loader).disposed(by: rx.disposeBag)
        viewModel.outputs.error.subscribe(onNext: { [weak self] error in
            self?.showAlert(title: "", message: error, defaultButtonTitle: "common_button_ok".localized)
        }).disposed(by: rx.disposeBag)

        viewModel.outputs.hideLetsDoIt
            .bind(to: letsDoItLabel.rx.isHidden).disposed(by: rx.disposeBag)

        viewModel.outputs.isPinSet.withUnretained(self)
            .subscribe(onNext: { `self`, value in self.isPinSet = value }).disposed(by: rx.disposeBag)

        iconContainer.rx.tapGesture().skip(1).map({ _ in () })
            .bind(to: viewModel.inputs.eyeInfoObserver)
            .disposed(by: rx.disposeBag)

        detailsButton.rx.tap.map{ _ in () }
            .merge(with: letsDoItLabel.rx.tap.map{ _ in () })
            .merge(with: cardImage.rx.tapGesture().skip(1).map{ _ in () })
            .merge(with: detailsIcon.rx.tapGesture().skip(1).map{ _ in () })
            .merge(with: view.rx.swipeGesture(.up).skip(1).map{ _ in () })
            .bind(to: viewModel.inputs.detailsObservers)
            .disposed(by: rx.disposeBag)
    }
}
