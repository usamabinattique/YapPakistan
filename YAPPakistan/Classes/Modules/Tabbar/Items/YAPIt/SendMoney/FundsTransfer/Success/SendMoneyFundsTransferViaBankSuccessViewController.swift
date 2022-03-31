//
//  SendMoneyFundsTransferViaBankSuccessViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 30/03/2022.
//

import UIKit
import YAPComponents
import RxSwift
import RxTheme

class SendMoneyFundsTransferViaBankSuccessViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var userImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private lazy var userName = UIFactory.makeLabel(font: .large, alignment: .center)
    private lazy var transferLabel = UIFactory.makeLabel(font: .micro, alignment: .center)
    private lazy var amountLabel = UIFactory.makeLabel(font: .title2, alignment: .center)
    private lazy var confirmButton = AppRoundedButtonFactory.createAppRoundedButton(title: "screen_y2y_funds_transfer_success_button_back".localized)
    
    private lazy var bankImageContainerView = UIFactory.makeCircularView(  borderColor: UIColor(Color(hex: "#F1F5FE")), borderWidth: 0.7)
    private lazy var bankImage =  UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private lazy var bankName = UIFactory.makeLabel(font: .regular,alignment: .center)
    
    private lazy var referenceNumber =  UIFactory.makeLabel(font: .micro, alignment: .center)
    private lazy var phoneNumber = UIFactory.makeLabel(font: .micro,alignment: .center)
    private lazy var date = UIFactory.makeLabel(font: .micro,alignment: .center)
    private lazy var detailsStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 8, arrangedSubviews: [bankImageContainerView,bankName,phoneNumber,referenceNumber,date])
    
    
    private lazy var checkView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var detailsStackContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var checkImage = UIFactory.makeImageView(contentMode: .center)

    // MARK: Properties
    
    private var viewModel: SendMoneyFundsTransferViaBankSuccessViewModelType!
    private var themeService : ThemeService<AppTheme>!
    private let disposeBag = DisposeBag()
    
    // MARK: Initialization
    
    init(theme: ThemeService<AppTheme>, viewModel: SendMoneyFundsTransferViaBankSuccessViewModelType) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.themeService = theme
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "screen_send_money_bank_transfer_success_display_text_title".localized
        navigationItem.hidesBackButton = true
        setupSubViews()
        setupConstraints()
        setupBindings()
        setupTheme()
        setupResources()
        addShareButton()
    }
    
    func addShareButton() {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        button.setImage(UIImage.init(named: "icon_qr_share", in: .yapPakistan), for: .normal)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.addTarget(self, action: #selector(onTapShare), for: .touchUpInside)
        
        let backButton = UIBarButtonItem()
        backButton.customView = button
        navigationItem.rightBarButtonItem  = backButton
    }
    
    @objc func onTapShare() {
        self.takeScreenshotAndShare(nil, nil)
    }
}

// MARK: View setup

extension SendMoneyFundsTransferViaBankSuccessViewController: ViewDesignable {
    
    public func setupSubViews() {
        view.backgroundColor = .white
        bankImageContainerView.addSubview(bankImage)
        view.addSubview(userImage)
        view.addSubview(userName)
        view.addSubview(transferLabel)
        view.addSubview(amountLabel)
        view.addSubview(checkView)
        view.addSubview(confirmButton)
        view.addSubview(detailsStackContainer)
        detailsStackContainer.addSubview(detailsStack)
        
        checkView.addSubview(checkImage)
        
        userImage.layer.cornerRadius = 32
        userImage.clipsToBounds = true
        detailsStackContainer.layer.cornerRadius = 12
        detailsStackContainer.layer.borderWidth = 0.7
        detailsStackContainer.layer.borderColor = UIColor(Color(hex: "#DAE0F0")).cgColor
        checkView.layer.cornerRadius = checkView.frame.size.height / 2
    }
    
    public func setupConstraints() {
        
        userImage
            .alignEdgeWithSuperview(.top, constant: 25)
            .centerHorizontallyInSuperview()
            .height(constant: 64)
            .width(with: .height, ofView: userImage)
        
        userName
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .toBottomOf(userImage, constant: 12)
        
        transferLabel
            .toBottomOf(userName, constant: 16)
            .centerHorizontallyInSuperview()
        
        amountLabel
            .toBottomOf(transferLabel, constant: 2)
            .centerHorizontallyInSuperview()
        
        checkView
            .toTopOf(detailsStackContainer, constant: 40)
            .width(constant: 82)
            .height(constant: 82)
            .centerHorizontallyInSuperview()
        
        checkImage
            .centerInSuperView()
        
        bankImage
            .height(constant: 32)
            .width(constant: 32)
            .centerHorizontallyInSuperview()
            .centerVerticallyInSuperview()
        
        bankImageContainerView
            .height(constant: 44)
            .width(constant: 44)
        
        detailsStackContainer
            .toTopOf(confirmButton, .equalTo, constant: 34)
           
            .alignEdgeWithSuperviewSafeArea(.left, constant: 24)
            .alignEdgeWithSuperviewSafeArea(.right, constant: 24)
            .centerHorizontallyInSuperview()
            .height(constant: 170)
        
        detailsStack
            .centerHorizontallyInSuperview()
            .centerVerticallyInSuperview()
        
        confirmButton
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 15)
            .centerHorizontallyInSuperview()
            .width(constant: 240)
            .height(constant: 52)
    }
    
    public func setupBindings() {
        viewModel.outputs.userImage.bind(to: userImage.rx.loadImage()).disposed(by: disposeBag)
        viewModel.outputs.userName.bind(to: userName.rx.text).disposed(by: disposeBag)
        viewModel.outputs.amount.bind(to: amountLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.outputs.phone.bind(to: phoneNumber.rx.text).disposed(by: disposeBag)
        viewModel.outputs.reference.bind(to: referenceNumber.rx.text).disposed(by: disposeBag)
        viewModel.outputs.date.bind(to: date.rx.text).disposed(by: disposeBag)
        viewModel.outputs.firstName.bind(to: transferLabel.rx.text).disposed(by: disposeBag)
      //  viewModel.outputs.userPhoneNumber.bind(to: userPhoneLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.bankImage.bind(to: bankImage.rx.loadImage()).disposed(by: rx.disposeBag)
        viewModel.outputs.bankName.bind(to: bankName.rx.text).disposed(by: rx.disposeBag)
        
        confirmButton.rx.tap.bind(to: viewModel.inputs.confirmObsever).disposed(by: disposeBag)
        
    }
    
    public func setupTheme() {
        self.themeService.rx
            .bind({ UIColor($0.greyDark) }, to: [transferLabel.rx.textColor,phoneNumber.rx.textColor,referenceNumber.rx.textColor,date.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [userName.rx.textColor,amountLabel.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [confirmButton.rx.backgroundColor])
            .disposed(by: rx.disposeBag)
    }
    
    public func setupResources() {
        self.checkImage.image = UIImage(named: "icon_completion", in: .yapPakistan)
    }
    
}
