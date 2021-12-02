//
//  CardDetailViewController.swift
//  ios-b2c-pk
//
//  Created by Sarmad on 25/11/2021.
//

import UIKit
import YAPComponents
import RxTheme

class CardDetailViewController: UIViewController {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    lazy var cardView = makeCardsView(themeService: themeService)
    lazy var creditView = makeCreditView(themeService: themeService)
    lazy var buttonsContainer = makeButtonsContainer(themeService: themeService)
    lazy var titleLabel = UIFactory.makeLabel(font: .large)
    lazy var freezUnfreezView = FreezUnfreezView(themeService: themeService).setHidden(true)

    private var backButton: UIButton!
    private var optionsButton: UIButton!

    // Properties
    var themeService: ThemeService<AppTheme>
    var viewModel: CardDetailViewModelType

    init(viewModel: CardDetailViewModelType, themeService: ThemeService<AppTheme>) {
        self.themeService = themeService
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupResources()
        setupTheme()
        setupConstraints()
        setupBindings()

        titleLabel.text = "Primary card"

        // FixMe
        let vmo = viewModel as? CardDetailViewModel
        cardView.subTitle.text = vmo?.paymentCard?.maskedCardNo ?? "-"
        creditView.balanceLabel.text = "PKR \(vmo?.paymentCard?.cardBalance ?? 0)"
        // End Fixme
    }

    func setupViews() {
        view.addSub(views: [ cardView, creditView, buttonsContainer, freezUnfreezView])
        navigationItem.titleView = titleLabel
        backButton = addBackButton(of: .backEmpty)

        let barButton = barButtonItem(image: UIImage(named: "icons_more", in: .yapPakistan), insectBy: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3))
        self.navigationItem.rightBarButtonItem = barButton.barItem
        optionsButton = barButton.button
    }

    func setupResources() { }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.backgroundColor) }, to: [ backButton.rx.backgroundColor ])
            .bind({ UIColor($0.primary) }, to: [ backButton.rx.tintColor ])
            .bind({ UIColor($0.primary) }, to: [ optionsButton.rx.tintColor ])
            .bind({ UIColor($0.primaryDark) }, to: [ titleLabel.rx.textColor ])
            .disposed(by: rx.disposeBag)
    }

    func setupConstraints() {
        cardView
            .alignEdgesWithSuperview([.safeAreaTop, .left, .right ], constants: [25, 0, 0])
            .aspectRatio(134 / 375)

        creditView
            .toBottomOf(cardView, constant: 25)
            .alignEdgesWithSuperview([.left, .right])

        buttonsContainer
            .toBottomOf(creditView, constant: 25)
            .alignEdgesWithSuperview([.left, .right], constant: 25)

        freezUnfreezView
            .alignEdgesWithSuperview([.safeAreaTop, .left, .right])
    }

    func setupBindings() {

        backButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)

        cardView.detailsButton.rx.tap.bind(to: viewModel.inputs.detailsObserver).disposed(by: rx.disposeBag)

        buttonsContainer.button1_1.rx.tap.asObservable()
            .merge(with: buttonsContainer.button1_0.rx.tap.asObservable())
            .merge(with: freezUnfreezView.button.rx.tap.asObservable())
            .bind(to: viewModel.inputs.freezObserver).disposed(by: rx.disposeBag)

        buttonsContainer.button2_1.rx.tap.asObservable()
            .merge(with: buttonsContainer.button2_0.rx.tap.asObservable())
            .bind(to: viewModel.inputs.limitObserver).disposed(by: rx.disposeBag)

        optionsButton.rx.tap.withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.makeOptionsView(themeService: self.themeService)
            })
            .disposed(by: rx.disposeBag)

        viewModel.outputs.hidefreezCard.withUnretained(self)
            .subscribe(onNext: { `self`, isHidden in
                self.buttonsContainer.button1_1.setTitle(isHidden ? "Freeze card": "Unfreeze card", for: .normal)
                self.freezUnfreezView.isHidden = isHidden
            })
            .disposed(by: rx.disposeBag)
            //.bind(to: freezUnfreezView.rx.isHidden).disposed(by: rx.disposeBag)
        viewModel.outputs.loader.bind(to: rx.loader).disposed(by: rx.disposeBag)
    }

}

fileprivate extension UIViewController {
    func makeCardsView(themeService: ThemeService<AppTheme>) -> CardView {

        let resources = CardViewModel.ResourcesType(
            title: "Primary Card",
            subtitle: "223344232****102",
            subsubTitle: "Secured by YAP",
            buttonTitle: "Card details",
            leftImageName: "payment_card",
            subsubTitleIconName: "icon_tabbar_cards"
        )

        let viewModel = CardViewModel(resources: resources)
        return CardView(viewModel: viewModel, themeService: themeService)
    }

    func makeCreditView(themeService: ThemeService<AppTheme>) -> CreditView {
        let viewModel = CreditViewModel()
        return CreditView(viewModel: viewModel, themeService: themeService)
    }

    func makeButtonsContainer(themeService: ThemeService<AppTheme>) -> ButtonsContainerView {
        let resources = ButtonsContainerViewModel.ResourcesType(
            button1_0Image: "freez_card",
            button1_1Title: "Freeze card",
            button2_0Image: "limits_card",
            button2_1Title: "Set limit"
        )

        let viewModel = ButtonsContainerViewModel(resources: resources)
        return ButtonsContainerView(viewModel: viewModel, themeService: themeService)
    }

    func makeOptionsView(themeService: ThemeService<AppTheme>) {
        let viewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // viewController.view.tintColor = UIColor(themeService.attrs.primaryDark)

        let action1 = UIAlertAction(title: "Change card's name", style: .default, handler: { _ in })
        let action2 = UIAlertAction(title: "Change PIN", style: .default, handler: { _ in })
        let action3 = UIAlertAction(title: "Forgot PIN", style: .default, handler: { _ in })
        let action4 = UIAlertAction(title: "View statement", style: .default, handler: { _ in })
        let action5 = UIAlertAction(title: "Report lost or stolen", style: .default, handler: { _ in })
        let action6 = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })

        viewController.addAction(action1)
        viewController.addAction(action2)
        viewController.addAction(action3)
        viewController.addAction(action4)
        viewController.addAction(action5)
        viewController.addAction(action6)

        self.present(viewController, animated: true, completion: nil)
    }
}
