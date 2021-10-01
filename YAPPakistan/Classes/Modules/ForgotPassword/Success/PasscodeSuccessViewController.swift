//
//  PasscodeSuccessViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 30/09/2021.
//

import YAPComponents
import RxSwift
import RxTheme

class PasscodeSuccessViewController: UIViewController {

    // MARK: - Views
    fileprivate lazy var backgroundImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    lazy var heading = UIFactory.makeLabel(font: .title2, alignment: .center, numberOfLines: 0)
    fileprivate lazy var subHeading = UIFactory.makeLabel(font: .regular,
                                                          alignment: .center,
                                                          numberOfLines: 0,
                                                          lineSpace: 8)
    fileprivate lazy var actionButton = UIFactory.makeAppRoundedButton(with: .regular)

    // MARK: - Properties
    fileprivate var themeService: ThemeService<AppTheme>
    let viewModel: PasscodeSuccessViewModelType

    // MARK: - Init
    init(themeService: ThemeService<AppTheme>, viewModel: PasscodeSuccessViewModelType) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("coder not implemented") }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupResources()
        setupTranslations()
        setupTheme()
        setupBindings()
        setupConstraints()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: - Setup
fileprivate extension PasscodeSuccessViewController {

    func setupViews() {
        view.backgroundColor = .white
        hideBackButton()
        view.addSubview(backgroundImage)
        view.addSubview(heading)
        view.addSubview(subHeading)
        view.addSubview(actionButton)
    }

    func setupResources() {
        backgroundImage.image = UIImage(named: "image_backgound", in: .yapPakistan)
    }

    func setupTranslations() {
        viewModel.outputs.headingTitle.bind(to: heading.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.subHeadingTitle.bind(to: subHeading.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.actionButtonTitle.bind(to: actionButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: heading.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: subHeading.rx.textColor)
            .bind({ UIColor($0.primary) }, to: actionButton.rx.enabledBackgroundColor)
            .bind({ UIColor($0.greyDark) }, to: subHeading.rx.textColor)
            .disposed(by: rx.disposeBag)
    }

    func setupConstraints() {
        backgroundImage.alignEdges([.left, .right], withView: view)
        backgroundImage.alignEdge(.top, withView: view)

        heading.alignEdge(.top, withView: view, constant: 200)
        heading.alignEdges([.left, .right], withView: view, constant: 10)

        subHeading.toBottomOf(heading, constant: 11)
        subHeading.alignEdges([.left, .right], withView: view, constant: 10)

        actionButton.alignEdgeWithSuperviewSafeArea(.bottom, constant: 30)
        actionButton.height(constant: 52)
        actionButton.width(constant: 192)
        actionButton.horizontallyCenterWith(view)

    }
}

// MARK: - Bind
fileprivate extension PasscodeSuccessViewController {
    func setupBindings() {
        actionButton.rx.tap.bind(to: viewModel.inputs.actionObserver).disposed(by: rx.disposeBag)
    }
}
