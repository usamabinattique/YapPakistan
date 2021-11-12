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
                                 UIFactory.makeView(), UIFactory.makeView() ]
    private lazy var addButton = barButtonItem(image: nil, insectBy: .zero)
    private lazy var sideMenuButton = barButtonItem(image: nil, insectBy: .zero)

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
        setupTheme()
        setupConstraints()
        bindViewModel()
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
                             pageNumberLabel ])
        view.addSub(views: spacers)
        navigationItem.rightBarButtonItem = addButton.barItem
        navigationItem.leftBarButtonItem = sideMenuButton.barItem
        navigationItem.titleView = titleLabelVC

        addButton.button?.isUserInteractionEnabled = false
    }

    func setupResources() {
        cardImage.image = UIImage(named: "payment_card", in: .yapPakistan)
        detailsIcon.image = UIImage(named: "arrow_up_purple", in: .yapPakistan)
        addButton.button?.setImage(UIImage(named: "icon_plus", in: .yapPakistan), for: .normal)
        sideMenuButton.button?.setImage(UIImage(named: "icon_menu", in: .yapPakistan), for: .normal)

        titleLabelVC.text = "Your cards"
        titleLabel.text = "Primary card"
        subTitleLabel.text = "This card is on the way"
        detailsButton.setTitle("See details", for: .normal)
        pageNumberLabel.text = "1 of 1"
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark) }, to: [titleLabel.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [subTitleLabel.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [detailsIcon.rx.tintColor])
            .bind({ UIColor($0.primary) }, to: [detailsButton.rx.titleColor(for: .normal)])
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

        detailsIcon
            .toBottomOf(spacers[1])
            .centerHorizontallyInSuperview()
            .height(constant: 32)
            .aspectRatio()
        detailsButton
            .toBottomOf(detailsIcon)
            .centerHorizontallyInSuperview()

        spacers[2]
            .toBottomOf(detailsButton)
            .alignEdgesWithSuperview([.left, .right])

        pageNumberLabel
            .toBottomOf(spacers[2], constant: -5)
            .centerHorizontallyInSuperview()

        spacers[3]
            .toBottomOf(pageNumberLabel)
            .alignEdgesWithSuperview([.left, .right, .safeAreaBottom])

        spacers[0]
            .heightEqualTo(view: spacers[1], multiplier: 1)
            .heightEqualTo(view: spacers[2], multiplier: 1)
            .heightEqualTo(view: spacers[3], multiplier: 1)
    }

    func bindViewModel() {
        detailsButton.rx.tap.bind(to: viewModel.inputs.detailsObservers).disposed(by: rx.disposeBag)
        cardImage.rx.tapGesture().map{ _ in () }
            .bind(to: viewModel.inputs.detailsObservers)
            .disposed(by: rx.disposeBag)
        detailsIcon.rx.tapGesture().map{ _ in () }
            .bind(to: viewModel.inputs.detailsObservers)
            .disposed(by: rx.disposeBag)
    }
}
