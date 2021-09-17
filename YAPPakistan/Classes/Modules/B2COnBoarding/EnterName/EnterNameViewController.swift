//
//  EnterNameViewController.swift
//  YAP
//
//  Created by Zain on 27/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit

import YAPComponents
import RxSwift
import RxCocoa
import RxTheme

class EnterNameViewController: OnBoardinContainerChildViewController {
    
    private lazy var headingLabel = UIFactory.makeLabel(font: .title2,
                                                        alignment: .center,
                                                        text: "screeen_name_display_text_title".localized,
                                                        adjustFontSize: true)
    
    private lazy var firstName = UIFactory.makeAppRoundedTextField(with: .regular,
                                                                   errorFont: .micro,
                                                                   placeholder: "screen_name_display_text_first_name".localized,
                                                                   validImage: UIImage(named: "icon_check", in: .yapPakistan),
                                                                   inValidImage:  UIImage(named: "icon_invalid", in: .yapPakistan),
                                                                   returnKeyType: .next,
                                                                   autocorrectionType: .no,
                                                                   autocapitalizationType: .words,
                                                                   keyboardType: .default,
                                                                   delegate: self)
    
    private lazy var lastName = UIFactory.makeAppRoundedTextField(with: .regular,
                                                                  errorFont: .micro,
                                                                  placeholder: "screen_name_display_text_last_name".localized,
                                                                  validImage: UIImage(named: "icon_check", in: .yapPakistan),
                                                                  inValidImage:  UIImage(named: "icon_invalid", in: .yapPakistan),
                                                                  returnKeyType: .next,
                                                                  autocorrectionType: .no,
                                                                  autocapitalizationType: .words,
                                                                  keyboardType: .default,
                                                                  delegate: self)
    
    override var firstReponder: UITextField? { return firstName }
    
    fileprivate var shouldChangeFirstNameText: Bool = true
    fileprivate var shouldChangeLastNameText: Bool = true
    
    fileprivate var viewModel: EnterNameViewModelType!
    fileprivate var themeService:ThemeService<AppTheme>!

    // MARK: Initialization
    
    init(themeService:ThemeService<AppTheme>, viewModel: EnterNameViewModelType) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTheme()
        setupConstraints()
        bindViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.viewAppearedObserver.onNext(true)
        viewModel.inputs.stageObserver.onNext(.name)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.inputs.viewAppearedObserver.onNext(false)
    }
    
    override func didPopFromNavigationController() {
        viewModel.inputs.poppedObserver.onNext(())
    }
}

// MARK: View setup

private extension EnterNameViewController {
    func setupViews() {
        view.addSubview(headingLabel)
        view.addSubview(firstName)
        view.addSubview(lastName)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark)     }, to: [headingLabel.rx.textColor])
            .bind({ UIColor($0.primary)         }, to: [firstName.rx.primaryColor, lastName.rx.primaryColor])
            .bind({ UIColor($0.primaryDark)     }, to: [firstName.rx.secondaryColor, lastName.rx.secondaryColor])
            .bind({ UIColor($0.greyLight)       }, to: [firstName.rx.bgColor, lastName.rx.bgColor])
            .bind({ UIColor($0.error)           }, to: [firstName.rx.errorColor, lastName.rx.errorColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupConstraints() {
        
        headingLabel
            .alignEdgesWithSuperview([.left, .right, .top], constants: [25, 25, 30])
        
        firstName
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .toBottomOf(headingLabel, .lessThanOrEqualTo, constant: UIScreen.screenType == .iPhone5 ? 30 : 90)
            .toBottomOf(headingLabel, .greaterThanOrEqualTo, constant: 20)
            .height(constant: 86)
        
        lastName
            .toBottomOf(firstName, constant: 2)
            .height(with: .height, ofView: firstName)
            .alignEdges([.left, .right], withView: firstName)
            .alignEdgeWithSuperview(.bottom, .greaterThanOrEqualTo, constant: 15)
        
    }
}

// MARK: Binding

private extension EnterNameViewController {
    func bindViews() {
        viewModel.outputs.firstNameError.bind(to: firstName.errorLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.lastNameError.bind(to: lastName.errorLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.firstNameValidation.bind(to: firstName.rx.validation).disposed(by: rx.disposeBag)
        viewModel.outputs.lastNameValidation.bind(to: lastName.rx.validation).disposed(by: rx.disposeBag)
        
        firstName.rx.text.bind(to: viewModel.inputs.firstNameObserver).disposed(by: rx.disposeBag)
        lastName.rx.text.bind(to: viewModel.inputs.lastNameObserver).disposed(by: rx.disposeBag)
        
        viewModel.outputs.allowedFirstNameInput.subscribe(onNext: { [unowned self] allowed in
            self.shouldChangeFirstNameText = allowed
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.allowedLasttNameInput.subscribe(onNext: { [unowned self] allowed in
            self.shouldChangeLastNameText = allowed
        }).disposed(by: rx.disposeBag)
    }
}

// MARK: Text field delegate

extension EnterNameViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text?.count ?? 0) + string.count > 40 && string.count != 0 { return false }
        textField == firstName ? viewModel.inputs.firstNameInputObserver.onNext(string) : viewModel.inputs.lastNameInputObserver.onNext(string)
        return textField == firstName ? shouldChangeFirstNameText : shouldChangeLastNameText
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstName {
            return lastName.becomeFirstResponder()
        }
        if textField == lastName {
            viewModel.inputs.keyboardNextObserver.onNext(())
            return false
        }
        return true
    }
}
