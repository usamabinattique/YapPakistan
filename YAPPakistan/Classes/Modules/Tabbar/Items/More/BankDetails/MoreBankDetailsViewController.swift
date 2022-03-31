//
//  MoreBankDetailsViewController.swift
//  YAPPakistan
//
//  Created by Awais on 28/03/2022.
//

import UIKit
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme

class MoreBankDetailsViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var background: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var name: MoreBankDetailsInfoView = {
        let view = MoreBankDetailsInfoView()
        view.titleText = "screen_more_bank_details_display_text_name".localized
        view.detailText = "Hello From World"
        view.canCopy = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var swift: MoreBankDetailsInfoView = {
        let view = MoreBankDetailsInfoView()
        view.titleText = "screen_more_bank_details_display_text_swift".localized
        view.detailText = "Hello From World"
        view.canCopy = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var iban: MoreBankDetailsInfoView = {
        let view = MoreBankDetailsInfoView()
        view.titleText = "screen_more_bank_details_display_text_iban".localized
        view.detailText = "Hello From World"
        view.canCopy = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var account: MoreBankDetailsInfoView = {
        let view = MoreBankDetailsInfoView()
        view.titleText = "screen_more_bank_details_display_text_account".localized
        view.detailText = "screen_more_bank_details_display_text_account".localized
        view.translatesAutoresizingMaskIntoConstraints = false
        view.canCopy = true
        return view
    }()
    
    private lazy var bank: MoreBankDetailsInfoView = {
        let view = MoreBankDetailsInfoView()
        view.titleText = "screen_more_bank_details_display_text_bank".localized
        view.detailText = "Hello From World"
        view.translatesAutoresizingMaskIntoConstraints = false
        view.canCopy = true
        return view
    }()
    
    private lazy var address: MoreBankDetailsInfoView = {
        let view = MoreBankDetailsInfoView()
        view.titleText = "screen_more_bank_details_display_text_address".localized
        view.detailText = "Hello From World"
        view.translatesAutoresizingMaskIntoConstraints = false
        view.canCopy = true
        return view
    }()
    
    private lazy var shareButton: AppRoundedButton = {
        let button = AppRoundedButtonFactory
            .createAppRoundedButton(title: "screen_more_bank_details_button_share".localized)
        button.titleLabel?.font = UIFont.large
        button.tintColor = UIColor.white
        return button
    }()
    
    // MARK: Properties
    
    private var viewModel: MoreBankDetailsViewModelType!
    private let disposeBag = DisposeBag()
    private var themeService: ThemeService<AppTheme>
    
    // MARK: Initialization
    
    init(themeService: ThemeService<AppTheme>,viewModel: MoreBankDetailsViewModelType) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back", in: .yapPakistan, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(closeAction))
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back", in: .yapPakistan, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(openProfile))
        
        navigationItem.title = "screen_more_bank_details_display_text_title".localized
        
        setupViews()
        setupTheme()
        setupConstraints()
        bindViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        render()
    }
    
    // MARK: Actions
//    @objc func openProfile() {
//        viewModel.inputs.settingsObserver.onNext(())
//    }
//
    @objc
    func closeAction() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: View setup

private extension MoreBankDetailsViewController {
    func setupTheme() {
        
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [name.rx.titleColor, swift.rx.titleColor, iban.rx.titleColor, account.rx.titleColor, address.rx.titleColor, bank.rx.titleColor])
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [name.rx.detailsColor, swift.rx.detailsColor, iban.rx.detailsColor, account.rx.detailsColor, address.rx.detailsColor, bank.rx.detailsColor, shareButton.rx.backgroundColor])
        
//        themeService.rx
//            .bind({ UIColor($0.primaryDark)}, to: [heading.rx.textColor, allBeneficiaryLabel.rx.textColor])
//            .bind({ UIColor($0.greyDark)}, to: [subHeading.rx.textColor])//[searchBarButtonItem.barItem.rx.tintColor])
//            .bind({ UIColor($0.primary)}, to: [addNowButton.rx.backgroundColor, navigationItem.rightBarButtonItem!.rx.tintColor, navigationItem.leftBarButtonItem!.rx.tintColor])
//            .bind({ UIColor($0.greyDark)}, to: [searchButton.rx.titleColor(for: .normal)])
//            .bind({ UIColor($0.greyDark)}, to: [searchButton.rx.tintColor])
//            .disposed(by: rx.disposeBag)
    }
    
    func setupViews() {
        view.backgroundColor = .white
        //background.backgroundColor = UIColor.red
        view.addSubview(background)
        background.addSubview(stackView)
        stackView.addArrangedSubview(name)
        stackView.addArrangedSubview(iban)
        stackView.addArrangedSubview(account)
        stackView.addArrangedSubview(bank)
        stackView.addArrangedSubview(swift)
        stackView.addArrangedSubview(address)
        
        view.addSubview(shareButton)
    }
    
    func setupConstraints() {
        
        background
            .alignEdgeWithSuperviewSafeArea(.top, constant: 20)
            .alignEdgesWithSuperview([.left, .right])
        
        stackView
            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constants: [25, 25, 25, 25])
        
        shareButton
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 15)
            .height(constant: 52)
            .width(constant: 190)
            .centerHorizontallyInSuperview()
    }
    
    func render() {
        shareButton.roundView()
//        profileImage.roundView(withBorderColor: .white, withBorderWidth: 3)
//        profileImage.layer.cornerRadius = 34
    }
}

// MARK: Binding

private extension MoreBankDetailsViewController {
    func bindViews() {
        //viewModel.outputs.profileImage.bind(to: profileImage.rx.loadImage()).disposed(by: disposeBag)
        viewModel.outputs.name.bind(to: name.rx.details).disposed(by: disposeBag)
        viewModel.outputs.iban.bind(to: iban.rx.details).disposed(by: disposeBag)
        viewModel.outputs.swift.bind(to: swift.rx.details).disposed(by: disposeBag)
        viewModel.outputs.account.bind(to: account.rx.details).disposed(by: disposeBag)
        viewModel.outputs.bank.bind(to: bank.rx.details).disposed(by: disposeBag)
        viewModel.outputs.address.bind(to: address.rx.details).disposed(by: disposeBag)
        viewModel.outputs.canShare.map{ !$0 }.bind(to: shareButton.rx.isHidden).disposed(by: disposeBag)
        
        shareButton.rx.tap.bind(to: viewModel.inputs.shareObserver).disposed(by: disposeBag)
        
        viewModel.outputs.shareInfo.subscribe(onNext: { [unowned self] text in
            //AppAnalytics.shared.logEvent(MoreEvent.shareBankDetails())
            let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        
    }
}
