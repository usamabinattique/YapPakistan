//
//  ConfirmPaymentViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 16/02/2022.
//

import YAPComponents
import RxSwift
import RxTheme

class ConfirmPaymentViewController: UIViewController {

    private lazy var cardImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private lazy var cardTypeLabel = UIFactory.makeLabel(font: .small, alignment: .center).setCornerRadius(15)
    
    private lazy var statusLabel = UIFactory.makeLabel(font: .regular, alignment: .center)
    private lazy var cardFeeLabel = UIFactory.makeLabel(font: .micro, alignment: .center)
    private lazy var cardFeeValueLabel = UIFactory.makeLabel(font: .title2, alignment: .center)
    private lazy var cardFeeStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 2, arrangedSubviews: [cardFeeLabel,cardFeeValueLabel])
    
    private lazy var spacer : UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(Color(hex: "#979797")).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var payWithLabel = UIFactory.makeLabel(font: .micro, alignment: .center)
    
    private lazy var cardTypeImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private lazy var cardMasksLabel = UIFactory.makeLabel(font: .small, alignment: .center)
    private lazy var cardMasksStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 12, arrangedSubviews: [cardTypeImage,cardMasksLabel])

    private lazy var payWithContainerStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 2, arrangedSubviews: [payWithLabel,cardMasksStack])
    
    private lazy var addressImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    
    private lazy var addressTitleLabel = UIFactory.makeLabel(font: .regular, alignment: .center)
    private lazy var addressDescLabel = UIFactory.makeLabel(font: .micro, alignment: .center)
    private lazy var addressStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .leading, distribution: .fill, spacing: 2, arrangedSubviews: [addressTitleLabel,addressDescLabel])
    private lazy var editButton = UIFactory.makeButton(with: .small, backgroundColor: .clear, title: "common_button_edit".localized)
    
    private lazy var addressContainerStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fillProportionally, spacing: 20, arrangedSubviews: [addressImage,addressStack,editButton])
    
    
    private lazy var actionButton = AppRoundedButtonFactory.createAppRoundedButton(title: "Place order for PKR 1,000")
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var backButton: UIButton!

    private var themeService: ThemeService<AppTheme>!
    var viewModel: ConfirmPaymentViewModelType!

    convenience init(themeService: ThemeService<AppTheme>, viewModel: ConfirmPaymentViewModelType) {
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
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubviews([cardImage, cardTypeLabel, cardFeeStack, spacer, payWithContainerStack, addressContainerStack, actionButton])
        backButton = addBackButton(of: .closeCircled)
        editButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        cardFeeLabel.text = "Card fee"
        cardFeeValueLabel.text = "PKR 1,000.00"
        payWithLabel.text = "Pay with"
        cardMasksLabel.text = "**** **** **** 1234"
        addressTitleLabel.text = "12 Street Road 10"
        addressDescLabel.text = "Suite 102. lahore"
       
        addressContainerStack.layer.borderWidth = 1
        addressContainerStack.layer.cornerRadius = 10
        actionButton.setTitle("Place order for PKR 1,000", for: .normal)
    }

    func setupResources() {
        cardImage.image = UIImage(named: "payment_card", in: .yapPakistan)
        cardTypeImage.image = UIImage(named: "logo_visa_secondary", in: .yapPakistan)
        addressImage.image = UIImage(named: "location_icon_with_bg", in: .yapPakistan)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primaryExtraLight) }, to: [ cardTypeLabel.rx.backgroundColor ])
            .bind({ UIColor($0.separatorColor).withAlphaComponent(0.10) }, to: [ spacer.rx.borderColor ])
            .bind({ UIColor($0.primary) }, to: [ cardTypeLabel.rx.textColor, editButton.rx.titleColor(for: .normal) ])
            .bind({ UIColor($0.primary) }, to: [ actionButton.rx.backgroundColor ])
           // .bind({ UIColor($0.greyDark) }, to: [ actionButton.rx.disabledBackgroundColor ])
            .bind({ UIColor($0.primaryDark) }, to: [ cardMasksLabel.rx.textColor, cardFeeValueLabel.rx.textColor ])
            .bind({ UIColor($0.greyDark) }, to: [ payWithLabel.rx.textColor, cardFeeLabel.rx.textColor ])
            .bind({ UIColor($0.greyLight) }, to: [  addressContainerStack.rx.borderColor ])
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
              //  self.statusView.strings = [strings.status.order, strings.status.build, strings.status.ship]
               // self.actionButton.setTitle(strings.action, for: .normal)
            })
            .disposed(by: rx.disposeBag)
    }

    func setupBindings() {
//        viewModel.outputs.completedSteps.bind(to: statusView.rx.progress).disposed(by: rx.disposeBag)
//        viewModel.outputs.isEnabled.bind(to: actionButton.rx.isEnabled).disposed(by: rx.disposeBag)

        actionButton.rx.tap.bind(to: viewModel.inputs.nextObserver).disposed(by: rx.disposeBag)
        editButton.rx.tap.bind(to: viewModel.inputs.editObserver).disposed(by: rx.disposeBag)
        backButton?.rx.tap.bind(to: viewModel.inputs.closeObserver).disposed(by: rx.disposeBag)
    }

    func setupConstraints() {

        scrollView
            .alignEdgesWithSuperview([.top,.bottom])
            .centerHorizontallyInSuperview()
            .widthEqualTo(view: view)
        contentView
            .alignEdgesWithSuperview([.top,.bottom])
            .centerHorizontallyInSuperview()
            .widthEqualTo(view: scrollView)
        
        cardImage
            .alignEdgeWithSuperview(.safeAreaTop, constant: 40)
            .widthEqualToSuperView(multiplier: 175 / 375)
            .aspectRatio(242 / 152)
            .centerHorizontallyInSuperview()
        
        cardTypeLabel
            .toBottomOf(cardImage, constant: 18)
            .centerHorizontallyInSuperview()
            .width(constant: 150)
            .height(constant: 30)
        
        cardFeeStack
            .toBottomOf(cardTypeLabel, constant: 20)
            .centerHorizontallyInSuperview()
            
        
        spacer
            .toBottomOf(cardFeeStack, constant: 26)
            .alignEdgesWithSuperview([.left,.right], constant: 28)
            .height(constant: 1)
        
        payWithContainerStack
            .toBottomOf(spacer, constant: 20)
            .centerHorizontallyInSuperview()
        
        addressContainerStack
            .toBottomOf(payWithContainerStack, constant: 40)
            .centerHorizontallyInSuperview()
            .alignEdgesWithSuperview([.left,.right], constant: 28)
            .height(constant: 86)
        
        actionButton
            .alignEdgesWithSuperview([.left,.right], constant: 28)
            .height(constant: 52)
            .toBottomOf(addressContainerStack , constant: 40)
            .alignEdgeWithSuperview(.safeAreaBottom, .greaterThanOrEqualTo ,constant: 40)
    }
}


