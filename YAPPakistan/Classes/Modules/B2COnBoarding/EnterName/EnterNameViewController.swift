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

class EnterNameViewController: OnBoardinContainerChildViewController {
    
    private lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.text =  "screeen_name_display_text_title".localized
        label.font = UIFont.appFont(forTextStyle: .title2)
        label.textColor = UIColor.blue //.appColor(ofType: .primaryDark)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var firstName: AppRoundedTextField = {
        let textField = AppRoundedTextField()
        textField.placeholder =  "screen_name_display_text_first_name".localized
        textField.delegate = self
        textField.autocorrectionType = .no
        textField.returnKeyType = .next
        textField.keyboardType = .default
        textField.autocapitalizationType = .words
        return textField
    }()
    
    private lazy var lastName: AppRoundedTextField = {
        let textField = AppRoundedTextField()
        textField.placeholder =  "screen_name_display_text_last_name".localized
        textField.delegate = self
        textField.autocorrectionType = .no
        textField.returnKeyType = .next
        textField.keyboardType = .default
        textField.autocapitalizationType = .words
        return textField
    }()
    
    override var firstReponder: UITextField? {
        return firstName
    }
    
    private var viewModel: EnterNameViewModelType!
    
    private var shouldChangeFirstNameText: Bool = true
    private var shouldChangeLastNameText: Bool = true

    // MARK: Initialization
    
    init(viewModel: EnterNameViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
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
        view.backgroundColor = .white
        
        view.addSubview(headingLabel)
        view.addSubview(firstName)
        view.addSubview(lastName)
    }
    
    func setupConstraints() {
        
        headingLabel
            .alignEdgesWithSuperview([.left, .right, .top], constants: [25, 25, 30])
        
        firstName
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .toBottomOf(headingLabel, .lessThanOrEqualTo, constant: /*UIScreen.screenType == .iPhone5 ? 30 :*/ 90)
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
        viewModel.outputs.firstNameError.bind(to: firstName.rx.errorText).disposed(by: rx.disposeBag)
        viewModel.outputs.lastNameError.bind(to: lastName.rx.errorText).disposed(by: rx.disposeBag)
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
