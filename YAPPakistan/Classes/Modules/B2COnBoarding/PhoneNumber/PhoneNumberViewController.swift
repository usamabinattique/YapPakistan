//
//  PhoneNubmerViewController.swift
//  YAP
//
//  Created by Zain on 21/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme


class PhoneNumberViewController: OnBoardinContainerChildViewController {
    
    private lazy var headingLabel = UIFactory.makeLabel(font: .title2, alignment: .center, text: "screen_phone_number_display_text_title".localized, adjustFontSize: true)
    
    private lazy var mobileNumber = UIFactory.makeAppRoundedTextField(with: .regular, errorFont: .micro, validImage: UIImage(named: "icon_check", in: .yapPakistan), inValidImage: UIImage(named: "icon_invalid", in: .yapPakistan), leftIcon: nil, displaysIcon:true, returnKeyType:.send, autocorrectionType:.no, keyboardType:.asciiCapableNumberPad, delegate:self)
    
    private lazy var countryPicker: RxAppPickerView = {
        return RxAppPickerView()
    }()
    
    private lazy var countryTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.inputView = countryPicker
        return textField
    }()
    
    override var firstReponder: UITextField? {
        return mobileNumber
    }
    
    private var viewModel: PhoneNumberViewModelType!
    private var themeService:ThemeService<AppTheme>!
    
    init(themeService:ThemeService<AppTheme>, viewModel: PhoneNumberViewModelType) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTheme()
        setupConstraint()
        bindViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.viewAppearedObserserver.onNext(true)
        viewModel.inputs.stageObserver.onNext(.phone)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.inputs.viewAppearedObserserver.onNext(false)
    }
    
    override func didPopFromNavigationController() {
        viewModel.inputs.poppedObserver.onNext(())
    }

}

// MARK: View setup

private extension PhoneNumberViewController {
    func setupViews() {
        view.addSubview(headingLabel)
        view.addSubview(mobileNumber)
        view.addSubview(countryTextField)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor )}, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark     )}, to: [headingLabel.rx.textColor])
            .bind({ UIColor($0.primary         )}, to: [mobileNumber.rx.primaryColor])
            .bind({ UIColor($0.primaryDark     )}, to: [mobileNumber.rx.secondaryColor])
            .bind({ UIColor($0.greyLight       )}, to: [mobileNumber.rx.bgColor])
            .bind({ UIColor($0.error           )}, to: [mobileNumber.rx.errorBorderColor])
            .bind({ UIColor($0.grey            )}, to: [mobileNumber.rx.errorTextColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupConstraint() {
        
        headingLabel
            .alignEdgesWithSuperview([.right, .left, .top], constants: [25, 25, 30])
        
        mobileNumber
            .toBottomOf(headingLabel, .lessThanOrEqualTo, constant: 90)
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .height(constant: 86)
            .alignEdgeWithSuperview(.bottom, .greaterThanOrEqualTo, constant: 20)
    }
}

// MARK: Binding

private extension PhoneNumberViewController {
    func bindViews() {
        viewModel.outputs.text.map({$0?.string}).bind(to: mobileNumber.rx.text).disposed(by: rx.disposeBag)
        mobileNumber.rx.text.bind(to: viewModel.inputs.textObserver).disposed(by: rx.disposeBag)
        mobileNumber.leftIcon.rx.tap.bind(to: viewModel.inputs.iconTapObserver).disposed(by: rx.disposeBag)
        viewModel.outputs.inputValidation.bind(to: mobileNumber.rx.validation).disposed(by: rx.disposeBag)
        viewModel.outputs.icon.bind(to: mobileNumber.leftIcon.rx.image(for: .normal)).disposed(by: rx.disposeBag)
        
        Observable.merge(countryPicker.rx.cancel, countryPicker.rx.done.map {_ in }).subscribe(onNext: { [unowned self] in
            _ = self.mobileNumber.becomeFirstResponder()
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.countries.bind(to: countryPicker.rx.itemTitles) { _, text in return text}.disposed(by: rx.disposeBag)
        
        countryPicker.rx.itemSelected.map { $0.row }.bind(to: viewModel.inputs.countrySelectionObserver).disposed(by: rx.disposeBag)
        
        viewModel.outputs.showError.bind(to: mobileNumber.errorLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.showError.map { _ in AppRoundedTextFieldValidation.invalid }.bind(to: mobileNumber.rx.validation).disposed(by: rx.disposeBag)
        viewModel.outputs.endEditting.bind(to: view.rx.endEditting).disposed(by: rx.disposeBag)
    }
}

// MARK: Text field delegate

extension PhoneNumberViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        viewModel.inputs.textWillChangeObserver.onNext((string, range, textField.text))
        return viewModel.outputs.shouldChange
    }
}
