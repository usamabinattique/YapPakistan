//
//  TopUpCardDetailsViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 03/03/2022.
//

import UIKit
import RxSwift
import YAPComponents
import YAPCore
import RxTheme

class TopUpCardDetailsViewController: UIViewController {

    // MARK: - Views
    private lazy var cardImageView = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private lazy var secureByYAPView: SecureByYAPView = SecureByYAPView(frame: CGRect.zero)
    private lazy var vStackViewCardImage = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 25)
    private lazy var cardNicknameField = UIFactory.makeStaticTextField(titleFont: .small, textFont: .large)
    private lazy var cardNumberField = UIFactory.makeStaticTextField(titleFont: .small, textFont: .large)
    private lazy var cardTypeField = UIFactory.makeStaticTextField(titleFont: .small, textFont: .large)
    private lazy var cardExpiryField = UIFactory.makeStaticTextField(titleFont: .small, textFont: .large, fieldIcon: UIImage(named: "exclamation-icon", in: .yapPakistan)!)
    private lazy var hStackViewFields = UIStackViewFactory.createStackView(with: .horizontal, alignment: .fill, distribution: .fillEqually, spacing: 14)
    private lazy var vStackViewFields = UIStackViewFactory.createStackView(with: .vertical, alignment: .fill, distribution: .fill, spacing: 19)
    private lazy var marginView = UIView()
    private lazy var removeCardButton = UIFactory.makeButton(with: .small, backgroundColor: .clear)
    private lazy var contentStackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 20)

    private var backButton: UIButton!
    
    // MARK: - Properties
    let viewModel: TopUpCardDetailsViewModelType
    let disposeBag: DisposeBag
    let themeService: ThemeService<AppTheme>

    // MARK: - Initializer
    
    init(themeService: ThemeService<AppTheme>, viewModel: TopUpCardDetailsViewModelType) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton = makeAndAddBackButton(of:.closeEmpty)
        setupSubViews()
        setupConstraints()
        setupBindings()
        setupTheme()
    }
    
    override public func onTapBackButton() {
        viewModel.inputs.closeObserver.onNext(ResultType.cancel)
        viewModel.inputs.closeObserver.onCompleted()
    }
}

extension TopUpCardDetailsViewController: ViewDesignable {
    func setupSubViews() {
        view.backgroundColor = .white
        marginView.backgroundColor = .clear
        navigationItem.title = "screen_topup_card_details_display_text_title".localized
//        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_close", in: .yapPakistan), style: .plain, target: self, action: #selector(closeAction))
        view.addSubview(contentStackView)

        // Setup stackviews
        _ = [cardImageView, secureByYAPView].map { [weak self] imageView in self?.vStackViewCardImage.addArrangedSubview(imageView) }
        _ = [cardTypeField, cardExpiryField].map { [weak self] field in self?.hStackViewFields.addArrangedSubview(field) }
        _ = [cardNicknameField, cardNumberField, hStackViewFields].map { [weak self] field in self?.vStackViewFields.addArrangedSubview(field) }
        _ = [vStackViewCardImage, vStackViewFields, marginView, removeCardButton].map { [weak self] view in self?.contentStackView.addArrangedSubview(view) }
    }
    
    func setupConstraints() {
        cardImageView.height(constant: 140)
        contentStackView.alignEdgesWithSuperview([.left, .safeAreaTop, .right, .safeAreaBottom], constants: [25, 20, 25, 15])
        vStackViewFields.alignEdgesWithSuperview([.left, .right])
    }
    
    func setupBindings() {
        bindTitle()
        bindCardImage()
        bindCardNickname()
        bindCardNumber()
        bindCardType()
        bindCardExpiry()
        bindRemoveCardButton()
        bindRemoveCardConfirmation()
        bindError()
        bindActivityIndicator()
        bindSuccessMessage()
    }
    
    func setupTheme() {
        self.themeService.rx
            .bind({ UIColor($0.primaryDark).withAlphaComponent(0.5) }, to: [cardNicknameField.rx.titleColor])
            .bind({ UIColor($0.primaryDark) }, to: [cardNicknameField.rx.textColor])
            .bind({ UIColor($0.primaryDark).withAlphaComponent(0.5) }, to: [cardNumberField.rx.titleColor])
            .bind({ UIColor($0.primaryDark) }, to: [cardNumberField.rx.textColor])
            .bind({ UIColor($0.primaryDark).withAlphaComponent(0.5) }, to: [cardTypeField.rx.titleColor])
            .bind({ UIColor($0.primaryDark) }, to: [cardTypeField.rx.textColor])
            .bind({ UIColor($0.primaryDark).withAlphaComponent(0.5) }, to: [cardExpiryField.rx.titleColor])
            .bind({ UIColor($0.primary) }, to: [removeCardButton.rx.titleColor(for: .normal)])
            .bind({ UIColor($0.primaryDark) }, to: [cardExpiryField.rx.textColor])
            .bind({ UIColor($0.primaryDark)}, to: [backButton.rx.tintColor])
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - Bind
fileprivate extension TopUpCardDetailsViewController {

    func bindTitle() {
        viewModel.outputs.title.bind(to: self.rx.title).disposed(by: disposeBag)
    }

    func bindCardImage() {
        viewModel.outputs.cardImage.bind(to: cardImageView.rx.image).disposed(by: disposeBag)
    }

    func bindCardNickname() {
        viewModel.outputs.cardNicknamePlaceholder.bind(to: cardNicknameField.rx.title).disposed(by: disposeBag)
        viewModel.outputs.cardNickname.bind(to: cardNicknameField.rx.text).disposed(by: disposeBag)
    }

    func bindCardNumber() {
        viewModel.outputs.cardNumberPlaceholder.bind(to: cardNumberField.rx.title).disposed(by: disposeBag)
        viewModel.outputs.cardNumber.bind(to: cardNumberField.rx.text).disposed(by: disposeBag)
    }

    func bindCardType() {
        viewModel.outputs.cardTypePlaceholder.bind(to: cardTypeField.rx.title).disposed(by: disposeBag)
        viewModel.outputs.cardType.bind(to: cardTypeField.rx.text).disposed(by: disposeBag)
    }

    func bindCardExpiry() {
        viewModel.outputs.expiryPlaceholder.bind(to: cardExpiryField.rx.title).disposed(by: disposeBag)
        viewModel.outputs.expiry.bind(to: cardExpiryField.rx.text).disposed(by: disposeBag)
        viewModel.outputs.isExpired.withUnretained(self)
            .subscribe(onNext: { `self`, isExpired in
                if isExpired {
                    self.cardExpiryField.bottomBorder.backgroundColor = UIColor(self.themeService.attrs.error)
                    self.cardExpiryField.shouldShowIcon = true
                } else {
                    self.cardExpiryField.bottomBorder.backgroundColor = UIColor(self.themeService.attrs.greyLight)
                    self.cardExpiryField.shouldShowIcon = false
                    
                }
            })
            .disposed(by: disposeBag)
    }

    func bindRemoveCardButton() {
        viewModel.outputs.removeCardTitle.bind(to: removeCardButton.rx.title(for: .normal)).disposed(by: disposeBag)
        removeCardButton.rx.tap.bind(to: viewModel.inputs.removeCardTapObserver).disposed(by: disposeBag)
    }

    func bindRemoveCardConfirmation() {
        Observable.combineLatest(viewModel.outputs.removeCardConfirmationMessage,
                                 viewModel.outputs.removeCardConfirmationDefaultButtonTitle,
                                 viewModel.outputs.removeCardConfirmationSecondaryButtonTitle)
        .subscribe(onNext: { [weak self] (message, defaultButtonTitle, secondaryButtonTitle) in
            self?.showAlert(message: message, defaultButtonTitle: defaultButtonTitle, secondayButtonTitle: secondaryButtonTitle, defaultButtonHandler: { [weak self] _ in
                self?.viewModel.inputs.removeCardConfirmTapObserver.onNext(())
            })
        }).disposed(by: disposeBag)
    }

    func bindError() {
        viewModel.outputs.error.subscribe(onNext: { [weak self] error in
            self?.showAlert(message: error.localizedDescription)
        }).disposed(by: disposeBag)
    }

    func bindActivityIndicator() {
        viewModel.outputs.isRunning.subscribe(onNext: { isRunning in
            _ = isRunning ? YAPProgressHud.showProgressHud() : YAPProgressHud.hideProgressHud()
        }).disposed(by: disposeBag)
    }

    func bindSuccessMessage() {
        viewModel.outputs.cardRemovedAlert.subscribe(onNext: { [weak self] message in
            self?.showAlert(message: message, defaultButtonHandler: { [weak self] _ in
                self?.viewModel.inputs.closeObserver.onNext(ResultType.success(()))
                self?.viewModel.inputs.closeObserver.onCompleted()
            })
        }).disposed(by: disposeBag)
    }
}

