//
//  SendMoneyConfirmFundsTransferViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 30/03/2022.
//

import YAPComponents
import RxSwift
import RxTheme
import UIKit

class SendMoneyConfirmFundsTransferViewController: UIViewController {
    
    //MARK: Properties
    private lazy var userImage: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var name: UILabel = UIFactory.makeLabel(font: .large, alignment: .center, numberOfLines: 0)
    private lazy var balance = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0)
    private lazy var feeLabel = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0)
    private lazy var doneButton: AppRoundedButton = AppRoundedButtonFactory.createAppRoundedButton(title: "common_button_confirm".localized)
    
    private lazy var stackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 20, arrangedSubviews: [userImage, name])
    private var backButton: UIButton!
    
    private var themeService: ThemeService<AppTheme>!
    var viewModel: SendMoneyConfirmFundsTransferViewModelType!
    private let disposeBag = DisposeBag()

    convenience init(themeService: ThemeService<AppTheme>, viewModel: SendMoneyConfirmFundsTransferViewModelType) {
        self.init(nibName: nil, bundle: nil)
        self.themeService = themeService
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton = makeAndAddBackButton(of: .backEmpty)
        navigationItem.title = "screen_send_money_otp_display_text_title".localized
        setupViews()
        setupResources()
        setupTheme()
        setupBindings()
        setupConstraints()
    }
    
    override func onTapBackButton() {
        viewModel.inputs.backObserver.onNext(())
    }
}

private extension SendMoneyConfirmFundsTransferViewController {
    func setupViews() {
        
        view.addSubview(stackView)
        view.addSubview(balance)
        view.addSubview(feeLabel)
        view.addSubview(doneButton)
        userImage.roundView()
    }

    func setupResources() {
      
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primary) }, to: [ doneButton.rx.backgroundColor ])
            .bind({ UIColor($0.primaryDark) }, to: [ backButton.rx.tintColor ])
            .bind({ UIColor($0.greyDark) }, to: [ balance.rx.textColor,feeLabel.rx.textColor])
            .disposed(by: rx.disposeBag)
    }

    func setupBindings() {
        viewModel.outputs.image.bind(to: userImage.rx.loadImage()).disposed(by: disposeBag)
        viewModel.outputs.name.bind(to: name.rx.text).disposed(by: disposeBag)
        
        viewModel.outputs.balance.bind(to: balance.rx.attributedText).disposed(by: disposeBag)
        viewModel.outputs.fee.bind(to: feeLabel.rx.attributedText).disposed(by: disposeBag)
        doneButton.rx.tap.bind(to: viewModel.inputs.nextObserver).disposed(by: disposeBag)
        
        viewModel.outputs.error.subscribe(onNext: { [weak self] in
            self?.showAlert(message: $0, defaultButtonHandler: { [weak self] _ in
                self?.onTapBackButton()
            })
        }).disposed(by: disposeBag)
    }

    func setupConstraints() {
        
        userImage
            .height(constant: 64)
            .width(constant: 64)
        
        stackView
            .alignEdgeWithSuperview(.top, constant: 32)
            .centerHorizontallyInSuperview()
            
        balance
            .toBottomOf(stackView, constant: 40)
            .alignEdgesWithSuperview([.left,.right],constants: [24,24])
        
        feeLabel
            .toBottomOf(balance, constant: 24)
            .alignEdgesWithSuperview([.left,.right],constants: [24,24])
        
        doneButton
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 28)
            .centerHorizontallyInSuperview()
            .height(constant: 52)
            .width(constant: 190)
    }
}
