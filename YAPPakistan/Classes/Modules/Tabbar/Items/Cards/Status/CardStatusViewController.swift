//
//  CardStatusViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import YAPComponents
import RxSwift
import RxTheme

class CardStatusViewController: UIViewController {

    private let cardImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private let cardTypeLabel = UIFactory.makeLabel(font: .small, alignment: .center).setCornerRadius(15)
    private let statusLabel = UIFactory.makeLabel(font: .regular, alignment: .center)
    private let statusView = UIFactory.makeCardStatusView()
    private let actionButton = UIFactory.makeAppRoundedButton(with: .regular)
    let spacers = [UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView()]
    private var backButton: UIButton!

    private var themeService: ThemeService<AppTheme>!
    var viewModel: CardStatusViewModelType!

    convenience init(themeService: ThemeService<AppTheme>, viewModel: CardStatusViewModelType) {
        self.init(nibName: nil, bundle: nil)
        self.themeService = themeService
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupResources()
        setupTheme()
        setupLanguageStrings()
        setupBindings()
        setupConstraints()
    }

    func setupViews() {
        view.addSubviews([cardImage, cardTypeLabel, statusLabel, statusView, actionButton])
        view.addSubviews(spacers)
        backButton = addBackButton(of: .backEmpty)
    }

    func setupResources() {
        cardImage.image = UIImage(named: "payment_card", in: .yapPakistan)
        let image = UIImage(named: "icon_check", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        statusView.icons = [image, image?.copy() as? UIImage, image?.copy() as? UIImage]
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primaryExtraLight) }, to: [ cardTypeLabel.rx.backgroundColor ])
            .bind({ UIColor($0.primary) }, to: [ cardTypeLabel.rx.textColor ])
            .bind({ UIColor($0.primaryDark) }, to: [ statusLabel.rx.textColor ])
            .bind({ (UIColor($0.primaryExtraLight), UIColor($0.primary)) }, to: [ statusView.rx.theme ])
            .bind({ UIColor($0.primary) }, to: [ actionButton.rx.enabledBackgroundColor ])
            .bind({ UIColor($0.greyDark) }, to: [ actionButton.rx.disabledBackgroundColor ])
            .disposed(by: rx.disposeBag)
        
        guard let backButton = backButton else { return }
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [ backButton.rx.tintColor ])
            .disposed(by: rx.disposeBag)
    }

    func setupLanguageStrings() {
        viewModel.outputs.localizedStrings.withUnretained(self)
            .subscribe(onNext: { `self`, strings in
                self.title = strings.title
                self.cardTypeLabel.text = strings.subTitle
                self.statusLabel.text = strings.message
                self.statusView.strings = [strings.status.order, strings.status.build, strings.status.ship]
                self.actionButton.setTitle(strings.action, for: .normal)
            })
            .disposed(by: rx.disposeBag)
    }

    func setupBindings() {
        viewModel.outputs.completedSteps.bind(to: statusView.rx.progress).disposed(by: rx.disposeBag)
        viewModel.outputs.isEnabled.bind(to: actionButton.rx.isEnabled).disposed(by: rx.disposeBag)

        actionButton.rx.tap.bind(to: viewModel.inputs.nextObserver).disposed(by: rx.disposeBag)
        backButton?.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
    }

    func setupConstraints() {
        spacers[0]
            .alignEdgesWithSuperview([.safeAreaTop, .left, .right])

        cardImage
            .toBottomOf(spacers[0])
            .widthEqualToSuperView(multiplier: 175 / 375)
            .aspectRatio(242 / 152)
            .centerHorizontallyInSuperview()

        cardTypeLabel
            .toBottomOf(cardImage, constant: 25)
            .centerHorizontallyInSuperview()
            .width(constant: 150)
            .height(constant: 30)

        spacers[1]
            .toBottomOf(cardTypeLabel)
            .alignEdgesWithSuperview([.left, .right])

        statusLabel
            .toBottomOf(spacers[1])
            .alignEdgesWithSuperview([.left, .right], constant: 25)

        spacers[2]
            .toBottomOf(statusLabel)
            .alignEdgesWithSuperview([.left, .right])

        statusView
            .toBottomOf(spacers[2])
            .alignEdgesWithSuperview([.left, .right], constant: 25)

        spacers[3]
            .toBottomOf(statusView)
            .alignEdgesWithSuperview([.left, .right])

        actionButton
            .toBottomOf(spacers[3])
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.safeAreaBottom, constant: 25)
            .height(constant: 52)
            .width(constant: 152)

        spacers[0]
            .heightEqualTo(view: spacers[1], multiplier: 1)
            .heightEqualTo(view: spacers[2], multiplier: 2)
            .heightEqualTo(view: spacers[3], multiplier: 1)
    }
}

class CardStatusView: UIView {

    // User Interface
    var icons: [UIImage?] {
        get { iconViews.map({ $0.image }) }
        set {
            for index in 0..<newValue.count { iconViews[index].image = newValue[index] }
            updateProgress()
        }
    }
    var strings: [String?] {
        get { statusLabels.map({ $0.text }) }
        set {
            for index in 0..<newValue.count { statusLabels[index].text = newValue[index] }
            updateProgress()
        }
    }
    var theme: (light: UIColor, dark: UIColor) = (.gray, .blue) { didSet {
        updateProgress()
    } }
    var progress: Int = 0 { didSet {
        updateProgress()
    } }

    // private properties
    private let iconViews = [UIFactory.makeImageView(contentMode: .scaleAspectFit),
                             UIFactory.makeImageView(contentMode: .scaleAspectFit),
                             UIFactory.makeImageView(contentMode: .scaleAspectFit)]
    private let iconContainers = [UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView()]
    private let statusLines = [UIFactory.makeView().setCornerRadius(3),
                               UIFactory.makeView().setCornerRadius(3)]
    private let statusLabels = [UIFactory.makeLabel(font: .small),
                                UIFactory.makeLabel(font: .small),
                                UIFactory.makeLabel(font: .small)]

    convenience init() { self.init(frame: .zero) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        makeUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        iconContainers.forEach { $0.layer.cornerRadius = $0.frame.size.height / 2 }
    }

    private func makeUI() {
        initialSetup()
        setupViews()
        setupConstraints()
    }

    private func initialSetup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
    }

    private func setupViews() {
        addSubviews(iconContainers)
        addSubviews(statusLabels)
        addSubviews(statusLines)
        for index in 0..<iconContainers.count {
            iconContainers[index].addSub(view: iconViews[index])
        }
    }

    private func setupConstraints() {
        iconContainers[0]
            .alignEdgesWithSuperview([.top, .left], constant: 10)
            .height(constant: 32)
            .aspectRatio()

        statusLines[0]
            .toRightOf(iconContainers[0], constant: 10)
            .centerVerticallyWith(iconContainers[0])
            .height(constant: 6)

        iconContainers[1]
            .toRightOf(statusLines[0], constant: 10)
            .alignEdgeWithSuperview(.top, constant: 10)
            .height(constant: 32)
            .aspectRatio()

        statusLines[1]
            .toRightOf(iconContainers[1], constant: 10)
            .centerVerticallyWith(iconContainers[1])
            .height(constant: 6)

        iconContainers[2]
            .toRightOf(statusLines[1], constant: 10)
            .alignEdgesWithSuperview([.top, .right], constant: 10)
            .height(constant: 32)
            .aspectRatio()

        for index in 0..<iconViews.count {
            iconViews[index].alignEdgesWithSuperview([.top, .bottom, .right, .left], constant: 6)
        }

        for index in 0..<statusLabels.count {
            statusLabels[index]
                .toBottomOf(iconContainers[index], constant: 10)
                .centerHorizontallyWith(iconContainers[index])
                .alignEdgeWithSuperview(.bottom)
        }

        iconContainers[0]
            .widthEqualTo(view: iconContainers[1])
            .widthEqualTo(view: iconContainers[2])
        statusLines[0]
            .widthEqualTo(view: statusLines[1])
    }

    func updateProgress() {
        guard progress <= 5 else { return }

        // Image
        for index in 0...progress where index % 2 == 1  {
            iconViews[index / 2].tintColor = .white
            // iconViews[index].backgroundColor = self.theme.dark
            iconContainers[index / 2].backgroundColor = self.theme.dark
        }
        for index in ((progress + 1) / 2)..<iconViews.count {
            iconViews[index].tintColor = self.theme.dark.withAlphaComponent(0.3)
            // iconViews[index].backgroundColor = self.theme.light
            iconContainers[index].backgroundColor = self.theme.light
        }
        // Line
        let pLine = (progress) / 2
        let progressLine = pLine <= statusLines.count ? pLine: statusLines.count
        for index in progressLine..<statusLines.count { statusLines[index].backgroundColor = self.theme.light }
        for index in 0..<progressLine { statusLines[index].backgroundColor = self.theme.dark }
    }
}

extension UIFactory {
    static func makeCardStatusView() -> CardStatusView {
        let view = CardStatusView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
