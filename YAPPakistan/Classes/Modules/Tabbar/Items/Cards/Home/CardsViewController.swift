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
    private lazy var balanceLabel = UIFactory.makeLabel(font: .regular, alignment: .center)
    private lazy var letsDoItButton = UIFactory.makeButton(with: .regular).setHidden(true)
    
    private lazy var cardInfoStack = UIFactory.makeStackView(axis: .vertical, alignment: .center, distribution: .fill, spacing: 2, arrangedSubviews: [subTitleLabel, balanceLabel, letsDoItButton])
    
    private lazy var detailsIcon = UIFactory.makeImageView()
    private lazy var detailsButton = UIFactory.makeButton(with: .regular)
    private lazy var pageNumberLabel = UIFactory.makeLabel(font: .small, alignment: .center)
//    private lazy var spacers = [ UIFactory.makeView(), UIFactory.makeView(),
//                                 UIFactory.makeView(), UIFactory.makeView(),
//                                 UIFactory.makeView() ]
    //private lazy var addButton = barButtonItem(image: nil, insectBy: .zero)
    private lazy var sideMenuButton = barButtonItem(image: nil, insectBy: .zero)
    
    private lazy var addBarButtonItem = barButtonItem(image: UIImage(named: "icon_home_add", in: .yapPakistan), insectBy:.zero)

    private lazy var iconContainer = UIFactory.makeImageView().shaddow()  // FIXME
    private lazy var clockEyeIcon = UIFactory.makeImageView()   // FIXME

    fileprivate func updateButton() {
        
        let theme = themeService.attrs
        iconContainer.backgroundColor = .white
        if isCardBlocked {
            letsDoItButton.backgroundColor = UIColor(theme.primary)
            letsDoItButton.setTitleColor(UIColor(theme.backgroundColor), for: .normal)
            letsDoItButton.setTitle("Order new card", for: .normal)
            subTitleLabel.text = "This card is blocked"
            if #available(iOS 13.0, *) {
                clockEyeIcon.image = UIImage(systemName: "eye")
            }
            clockEyeIcon.tintColor = UIColor(theme.primary)
            letsDoItButton.isHidden = false
            detailsIcon.isHidden = true
            detailsButton.isHidden = true
            return
        }
        if isSetPinDoneFlow {
            if isUserBlocked {
                letsDoItButton.backgroundColor = UIColor(theme.primary)
                letsDoItButton.setTitleColor(UIColor(theme.backgroundColor), for: .normal)
                letsDoItButton.setTitle("Unfreeze card", for: .normal)
                subTitleLabel.text = "This card is frozen"
                if #available(iOS 13.0, *) {
                    clockEyeIcon.image = UIImage(systemName: "lock")
                }
                clockEyeIcon.tintColor = .red
            } else {
                letsDoItButton.isHidden = true
                subTitleLabel.text = "Card balance"
                if #available(iOS 13.0, *) {
                    clockEyeIcon.image = UIImage(systemName: "eye")
                }
                clockEyeIcon.tintColor = UIColor(theme.primary)
            }
        } else {
            letsDoItButton.backgroundColor = UIColor(theme.primary)
            letsDoItButton.setTitleColor(UIColor(theme.backgroundColor), for: .normal)
            letsDoItButton.setTitle("Let's do it", for: .normal)
            if #available(iOS 13.0, *) {
                clockEyeIcon.image = UIImage(systemName: "exclamationmark")
            }
            clockEyeIcon.tintColor = UIColor(theme.secondaryBlue)
        }
    }
    var isUserBlocked = false { didSet { updateButton() }}
    var isSetPinDoneFlow = false { didSet { updateButton() }}
    var isCardBlocked = false { didSet { updateButton() }}

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
        letsDoItButton.layer.cornerRadius = letsDoItButton.frame.size.height / 2
        iconContainer.layer.cornerRadius = iconContainer.frame.size.height / 2
    }
}

// MARK: - Setup
fileprivate extension CardsViewController {
    func setupViews() {
        view.addSub(views: [ titleLabel,
                             cardImage,
                             cardInfoStack,
                             detailsIcon,
                             detailsButton,
                             pageNumberLabel,
                             iconContainer ])
        iconContainer.addSub(view: clockEyeIcon)
        //navigationItem.rightBarButtonItem = addButton.barItem
        navigationItem.leftBarButtonItem = sideMenuButton.barItem
        navigationItem.titleView = titleLabelVC
        navigationItem.rightBarButtonItem = addBarButtonItem.barItem
        // addButton.button?.isUserInteractionEnabled = false
    }

    func setupResources() {
        cardImage.image = UIImage(named: "payment_card", in: .yapPakistan)
        detailsIcon.image = UIImage(named: "arrow_up_purple", in: .yapPakistan)
        //addButton.button?.setImage(UIImage(named: "icon_home_add", in: .yapPakistan), for: .normal)
        //sideMenuButton.button?.setImage(UIImage(named: "icon_menu", in: .yapPakistan), for: .normal)
    }

    func setupLocalization() {
        viewModel.outputs.localizedStrings.withUnretained(self)
            .subscribe(onNext: { `self`, string in
                self.titleLabelVC.text = string.titleView
                self.titleLabel.text = string.titleCard
                self.subTitleLabel.text = self.isSetPinDoneFlow ? "Card balance": string.subTitle
                self.detailsButton.setTitle(string.seeDetail, for: .normal)
                self.cardImage.image = UIImage(named: string.cardImage, in: .yapPakistan)
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
            .bind({ UIColor($0.primaryDark) }, to: [balanceLabel.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [detailsIcon.rx.tintColor])
            .bind({ UIColor($0.primary) }, to: [detailsButton.rx.titleColor(for: .normal)])
            .bind({ UIColor($0.primary) }, to: [letsDoItButton.rx.backgroundColor])
            .bind({ UIColor($0.backgroundColor) }, to: [letsDoItButton.rx.titleColor(for: .normal)])
            .bind({ UIColor($0.greyDark) }, to: [pageNumberLabel.rx.textColor])
            .disposed(by: rx.disposeBag)
    }

    func setupConstraints() {
        
        titleLabel
            .alignEdgesWithSuperview([.safeAreaTop, .left, .right], constants: [0, 22, 22])
        cardImage
            .toBottomOf(titleLabel, constant: 16)
            .centerHorizontallyInSuperview()
            .widthEqualToSuperView(multiplier: 205 / 375)
            .aspectRatio(325 / 204)
        
        cardInfoStack
            .toBottomOf(cardImage, constant: 16)
            .alignEdgesWithSuperview([.left, .right], constant: 22)
        
        subTitleLabel
            .height(constant: 18)
        
        cardInfoStack
            .setCustomSpacing(12, after: subTitleLabel)

        balanceLabel
            .height(constant: 20)
        
        cardInfoStack
            .setCustomSpacing(12, after: balanceLabel)
        
        letsDoItButton
            .height(constant: 24)
            .width(constant: 135)

        detailsIcon
            .toBottomOf(cardInfoStack, constant: 30)
            .centerHorizontallyInSuperview()
            .height(constant: 22)
            .aspectRatio()
        detailsButton
            .toBottomOf(detailsIcon)
            .centerHorizontallyInSuperview()
        
        pageNumberLabel
            .toBottomOf(detailsButton, constant: 41)
            .centerHorizontallyInSuperview()
        
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

        viewModel.outputs.isCardActive
            .subscribe(onNext:{ isActive in
                if isActive {
                    self.balanceLabel.isHidden = false
                    self.letsDoItButton.isHidden = true
                } else {
                    self.balanceLabel.isHidden = true
                    self.letsDoItButton.isHidden = false
                }
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.cardImageType
            .subscribe(onNext: {  imageName in
                self.cardImage.image = UIImage(named: imageName, in: .yapPakistan)
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.cardBalance
            .bind(to: balanceLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.hideLetsDoIt
            .bind(to: letsDoItButton.rx.isHidden).disposed(by: rx.disposeBag)

        viewModel.outputs.isForSetPinFlow.withUnretained(self)
            .subscribe(onNext: { `self`, value in self.isSetPinDoneFlow = value })
            .disposed(by: rx.disposeBag)
        viewModel.outputs.isCardBLocked.withUnretained(self)
            .subscribe(onNext: { `self`, value in self.isCardBlocked = value })
            .disposed(by: rx.disposeBag)
        viewModel.outputs.isUserBlocked.withUnretained(self)
            .subscribe(onNext: { `self`, value in self.isUserBlocked = value })
            .disposed(by: rx.disposeBag)

        iconContainer.rx.tapGesture().skip(1).map({ _ in () })
            .bind(to: viewModel.inputs.eyeInfoObserver)
            .disposed(by: rx.disposeBag)
        
        addBarButtonItem.button?.rx.tap.bind(to: viewModel.inputs.addCardObserver).disposed(by: rx.disposeBag)

        detailsButton.rx.tap.map{ _ in () }
            .merge(with: letsDoItButton.rx.tap.map{ _ in () }.filter({[unowned self] _ in !self.isUserBlocked }) )
            .merge(with: cardImage.rx.tapGesture().skip(1).map{ _ in () })
            .merge(with: detailsIcon.rx.tapGesture().skip(1).map{ _ in () })
            .merge(with: view.rx.swipeGesture(.up).skip(1).map{ _ in () })
            .filter({ [weak self] in self?.isCardBlocked == false })
            .bind(to: viewModel.inputs.detailsObservers)
            .disposed(by: rx.disposeBag)

        letsDoItButton.rx.tap.map{ _ in () }
            .filter({[unowned self] _ in self.isUserBlocked })
            .bind(to: viewModel.inputs.unfreezObserver).disposed(by: rx.disposeBag)

        letsDoItButton.rx.tap.map{ _ in () }
            .filter({[unowned self] _ in self.isCardBlocked })
            .bind(to: viewModel.inputs.orderNewObserver).disposed(by: rx.disposeBag)
    }
}
