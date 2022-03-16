//
//  BankDetailViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 16/03/2022.
//

import UIKit
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme
import RxDataSources

class AddBeneficiaryBankDetailViewController: AddBeneficiaryBankListContainerChildViewController {

    private lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.text = "screen_add_beneficiary_detail_display_text_bank_account_detail_heading".localized
        label.font = UIFont.title3
        // label.textColor = UIColor.blue //.appColor(ofType: .primaryDark)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var accountAlert: YAPAlert = {
        return YAPAlert()
    }()
//    override var firstReponder: UITextField? {
//        return searchTextField
//    }

    private var viewModel: AddBeneficiaryBankDetailViewModelType!
    private var themeService:ThemeService<AppTheme>!

    init(themeService:ThemeService<AppTheme>, viewModel: AddBeneficiaryBankDetailViewModelType?) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        viewModel?.inputs.viewAppearedObserver.onNext(true)
//        viewModel?.inputs.stageObserver.onNext(.otp)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupViews()
        setupResources()
        setupConstraints()
        setupTheme()
        bindViews()

    }

    override func didPopFromNavigationController() {
       // viewModel?.inputs.poppedObserver.onNext(())
    }
}

// MARK: View setup

extension AddBeneficiaryBankDetailViewController {
    func setupViews() {
        view.addSubview(headingLabel)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark    ) }, to: [headingLabel.rx.textColor])
//            .bind({ UIColor($0.greyDark       ) }, to: [subHeadingLabel.rx.textColor])
//            .bind({ UIColor($0.greyDark       ) }, to: [timerLabel.rx.textColor])
//            .bind({ UIColor($0.primary        ) }, to: [resendButton.rx.titleColor(for: .normal)])
            .disposed(by: rx.disposeBag)
    }
    
    func setupResources() {
       
    }
    
    func setupConstraints() {

        headingLabel
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .alignEdgeWithSuperviewSafeArea(.top, constant: 16)
        
//        beneficiariesView
//            .alignEdgesWithSuperview([.right,.left,.bottom])
//            .toBottomOf(headingLabel,constant: 20)
//
//        searchButton
//            .alignEdgesWithSuperview([.left, .right,.top], constants: [24, 24,0])
//            .height(constant: 30)
//
//        tableView
//            .toBottomOf(searchButton, constant: 0)//24)
//            .alignEdgesWithSuperview([.left, .right, .bottom])
    }
}

// MARK: Binding

private extension AddBeneficiaryBankDetailViewController {
    func bindViews() {
        guard let viewModel = viewModel else { return }
        
        /*codeTextField.rx.text.bind(to: viewModel.inputs.textObserver).disposed(by: rx.disposeBag)
        viewModel.outputs.timerText.bind(to: timerLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.phoneNumber.bind(to: subHeadingLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.endEditting.bind(to: view.rx.endEditting).disposed(by: rx.disposeBag)
        viewModel.outputs.showError.bind(to: rx.showErrorMessage).disposed(by: rx.disposeBag)
        viewModel.outputs.showError.map{ _ in }.bind(to: codeTextField.rx.clear).disposed(by: rx.disposeBag)
        viewModel.outputs.showAlert.do(onNext: { [weak self] text in
            self?.showAlert(title: "",
                            message: text,
                            defaultButtonTitle: "common_button_ok".localized,
                            secondayButtonTitle: nil,
                            defaultButtonHandler: { [weak self] _ in _ = self?.codeTextField.becomeFirstResponder() },
                            secondaryButtonHandler: nil,
                            completion: nil )
        }).subscribe().disposed(by: rx.disposeBag)

        viewModel.outputs.resendActive.bind(to: resendButton.rx.isEnabled).disposed(by: rx.disposeBag)
        viewModel.outputs.resendActive.map { $0 ? 1.0 : 0.3 }.bind(to: resendButton.rx.alpha).disposed(by: rx.disposeBag)
        resendButton.rx.tap.bind(to: viewModel.inputs.resendObserver).disposed(by: rx.disposeBag) */
        
        
        viewModel.outputs.showError.subscribe(onNext: { [weak self] error in
            self?.showAlert(title: "", message: error, defaultButtonTitle: "common_button_ok".localized)
        }).disposed(by: rx.disposeBag)
        
       // viewModel.outputs.enableSearch.bind(to: searchButton.rx.isEnabled).disposed(by: rx.disposeBag)
    }
}
