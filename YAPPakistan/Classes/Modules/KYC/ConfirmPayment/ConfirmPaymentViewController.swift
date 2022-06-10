//
//  ConfirmPaymentViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 16/02/2022.
//

import YAPComponents
import RxSwift
import RxTheme
import UIKit

class ConfirmPaymentViewController: UIViewController {

    private lazy var cardImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private lazy var cardTypeLabel = UIFactory.makeLabel(font: .small, alignment: .center).setCornerRadius(15)
    
    private lazy var cardFeeLabel = UIFactory.makeLabel(font: .small, alignment: .left)
    private lazy var cardFeeValueLabel = UIFactory.makeLabel(font: .regular, alignment: .right)
    private lazy var cardFeeStack = UIFactory.makeStackView(axis: .horizontal, alignment: .center, distribution: .fill, spacing: 2, arrangedSubviews: [cardFeeLabel,cardFeeValueLabel])
    
    private lazy var fedLabel = UIFactory.makeLabel(font: .small, alignment: .left)
    private lazy var fedValueLabel = UIFactory.makeLabel(font: .regular, alignment: .right)
    private lazy var fedStack = UIFactory.makeStackView(axis: .horizontal, alignment: .center, distribution: .fill, spacing: 2, arrangedSubviews: [fedLabel,fedValueLabel])
    
    private lazy var spacer : UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var orderTotalLabel = UIFactory.makeLabel(font: .small, alignment: .left)
    private lazy var orderTotalValueLabel = UIFactory.makeLabel(font: .regular, alignment: .right)
    private lazy var orderTotalStack = UIFactory.makeStackView(axis: .horizontal, alignment: .center, distribution: .fill, spacing: 2, arrangedSubviews: [orderTotalLabel,orderTotalValueLabel])
    
    private lazy var cardFEDFeeStack = UIFactory.makeStackView(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 7, arrangedSubviews: [cardFeeStack, fedStack, spacer, orderTotalStack])
    
    private lazy var payWithLabel = UIFactory.makeLabel(font: .micro, alignment: .center)
    
    private lazy var cardTypeImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private lazy var cardMasksLabel = UIFactory.makeLabel(font: .small, alignment: .center)
    private lazy var cardMasksStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 12, arrangedSubviews: [cardTypeImage,cardMasksLabel])

    private lazy var payWithContainerStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 2, arrangedSubviews: [payWithLabel,cardMasksStack])
    
    private lazy var addressImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    
    private lazy var addressTitleLabel = UIFactory.makeLabel(font: .regular, alignment: .left, numberOfLines: 0)
    private lazy var addressDescLabel = UIFactory.makeLabel(font: .micro, alignment: .left, numberOfLines: 0)
    private lazy var addressStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .leading, distribution: .fill, spacing: 2, arrangedSubviews: [addressTitleLabel,addressDescLabel])
    private lazy var editButton = UIFactory.makeButton(with: .small, backgroundColor: .clear, title: "common_button_edit".localized)
    
    private lazy var addressContainerStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fillProportionally, spacing: 20, arrangedSubviews: [addressImage,addressStack,editButton])
    
    private lazy var addressContainerView: UIView = UIFactory.makeView()
    private lazy var backBarButtonItem = barButtonItem(image: UIImage(named: "icon_back", in: .yapPakistan), insectBy:.zero)
    
    private lazy var actionButton = AppRoundedButtonFactory.createAppRoundedButton(title: "screen_yap_confirm_payment_display_text_place_order_for".localized, font: .large)
    
    private lazy var doItLaterBtn = UIFactory.makeButton(with: .large, backgroundColor: .clear, title: "Do it later")
    
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
    
    //private var backButton: UIButton!

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
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.leftBarButtonItem = backBarButtonItem.barItem
        self.title = "Order card"
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        addressContainerView.addSubview(addressContainerStack)
        contentView.addSubviews([cardImage, cardTypeLabel, cardFEDFeeStack, payWithContainerStack, addressContainerView, doItLaterBtn ,actionButton])
        
       // backButton = addBackButton(of: .closeCircled)
        editButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        cardFeeLabel.text = "screen_yap_confirm_payment_display_text_Card_fee".localized
        fedLabel.text = "screen_yap_confirm_payment_display_text_fed_fee".localized
        orderTotalLabel.text = "screen_yap_confirm_payment_display_text_order_total_fee".localized
        payWithLabel.text = "screen_yap_confirm_payment_display_text_pay_with".localized
        
        addressContainerView.layer.borderWidth = 1
        addressContainerView.layer.cornerRadius = 10
    }

    func setupResources() {
       // cardImage.image = UIImage(named: "payment_card", in: .yapPakistan)
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
            .bind({ UIColor($0.primaryDark) }, to: [ cardMasksLabel.rx.textColor, cardFeeValueLabel.rx.textColor, fedValueLabel.rx.textColor, orderTotalValueLabel.rx.textColor, addressDescLabel.rx.textColor ])
            .bind({ UIColor($0.greyDark) }, to: [ payWithLabel.rx.textColor, cardFeeLabel.rx.textColor, fedLabel.rx.textColor, addressDescLabel.rx.textColor ])
            .bind({ UIColor($0.primaryDark) }, to: [orderTotalLabel.rx.textColor])
            .bind({ UIColor($0.greyLight) }, to: /*[  addressContainerView.rx.borderColor ])*/ [addressContainerView.rx.borderColor ])
            .disposed(by: rx.disposeBag)
        
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [doItLaterBtn.rx.titleColor(for: .normal)])
            .disposed(by: rx.disposeBag)
    }

    func setupLanguageStrings() {
        viewModel.outputs.localizedStrings.withUnretained(self)
            .subscribe(onNext: { `self`, strings in
                self.title = strings.title
                self.cardTypeLabel.text = strings.subTitle
            })
            .disposed(by: rx.disposeBag)
    }

    func setupBindings() {
//        viewModel.outputs.completedSteps.bind(to: statusView.rx.progress).disposed(by: rx.disposeBag)
//        viewModel.outputs.isEnabled.bind(to: actionButton.rx.isEnabled).disposed(by: rx.disposeBag)

        actionButton.rx.tap.bind(to: viewModel.inputs.nextObserver).disposed(by: rx.disposeBag)
        editButton.rx.tap.bind(to: viewModel.inputs.editObserver).disposed(by: rx.disposeBag)
        //backButton?.rx.tap.bind(to: viewModel.inputs.closeObserver).disposed(by: rx.disposeBag)
        backBarButtonItem.button?.rx.tap.bind(to: viewModel.inputs.closeObserver).disposed(by: rx.disposeBag)
        viewModel.outputs.cardImage.bind(to: cardImage.rx.image).disposed(by: rx.disposeBag)
        /*viewModel.outputs.isPaid.withUnretained(self)
            .subscribe(onNext: { `self`, isPaid in
                self.cardFeeStack.isHidden = isPaid
                self.payWithContainerStack.isHidden = isPaid
                
            })
            .disposed(by: rx.disposeBag) */
        viewModel.outputs.isPaid.bind(to: cardFEDFeeStack.rx.isHidden,payWithContainerStack.rx.isHidden).disposed(by: rx.disposeBag)
        viewModel.outputs.cardFee.bind(to: cardFeeValueLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.fedFee.bind(to: fedValueLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.orderTotalFee.bind(to: orderTotalValueLabel.rx.text).disposed(by: rx.disposeBag)
        
        viewModel.outputs.cardNumber.bind(to: cardMasksLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.address.withUnretained(self)
            .subscribe(onNext: { `self`, address in
                let title = address.address.first ?? ""
                self.addressTitleLabel.text = title //title.count > 20 ? "\(String(title.prefix(20)))..." : title
                if address.address.count > 1 {
                    let suiet = address.address[1]
                    self.addressDescLabel.text = address.address[1]
                  //  self.addressDescLabel.text = suiet //suiet.count > 20 ? "\(String(suiet.prefix(20)))..." : suiet
                }
            })
            .disposed(by: rx.disposeBag)
        viewModel.outputs.buttonTitle.bind(to: actionButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        viewModel.outputs.error.bind(to: rx.showErrorMessage).disposed(by: rx.disposeBag)
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
        
        cardFeeLabel
            .height(constant: 24)
        cardFeeValueLabel
            .height(constant: 24)
        
        fedLabel
            .height(constant: 24)
        fedValueLabel
            .height(constant: 24)
        
        orderTotalLabel
            .height(constant: 24)
        orderTotalValueLabel
            .height(constant: 24)
        
        spacer
            .height(constant: 1)
        
        cardFEDFeeStack
            .alignEdgesWithSuperview([.left, .right], constants: [28, 28])
            .toBottomOf(cardTypeLabel, constant: 20)
            .centerHorizontallyInSuperview()
            .setCustomSpacing(9, after: fedValueLabel)
        
        cardFEDFeeStack
            .setCustomSpacing(17, after: spacer)
        
        payWithContainerStack
            .toBottomOf(cardFEDFeeStack, constant: 47)
            .centerHorizontallyInSuperview()
        
        addressContainerStack
            .alignEdgesWithSuperview([.top, .bottom, .left, .right], constants: [20, 20, 20, 20])
        
        addressContainerView
            .toBottomOf(payWithContainerStack, constant: 40)
            .centerHorizontallyInSuperview()
            .alignEdgesWithSuperview([.left,.right], constant: 25)
//            .height(constant: 86)
        
//        addressContainerView
//            .toBottomOf(payWithContainerStack, constant: 40)
//            .centerHorizontallyInSuperview()
//            .alignEdgesWithSuperview([.left,.right], constant: 28)
//            .height(constant: 86)
        
        actionButton
            .alignEdgesWithSuperview([.left,.right], constant: 28)
            .height(constant: 52)
            .toBottomOf(addressContainerStack , constant: 40)
//            .toBottomOf(addressContainerView , constant: 40)
//            .alignEdgeWithSuperview(.safeAreaBottom, .greaterThanOrEqualTo ,constant: 40)
        
        doItLaterBtn
            .alignEdgesWithSuperview([.left, .right], constant: 28)
            .height(constant: 52)
            .toBottomOf(actionButton, constant: 25)
            .alignEdgeWithSuperview(.safeAreaBottom, .greaterThanOrEqualTo, constant: 40)
    }
}


