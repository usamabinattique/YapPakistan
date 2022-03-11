//
//  TopupCardCVVViewController.swift
//  YAP
//
//  Created by Zain on 14/11/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift
import RxTheme

class TopupCardCVVViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var cardImage = UIFactory.makeImageView(contentMode: .scaleAspectFit )
    
    private lazy var cardTitle = UIFactory.makeLabel(font: .large, alignment: .center)
    
    private lazy var cardNumber = UIFactory.makeLabel(font: .micro, alignment: .center)
    
    private lazy var amount = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0,lineBreakMode: .byWordWrapping)
    
    private lazy var cvv: CodeVerificationTextField = {
        let textField = CodeVerificationTextField()
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var confirm = AppRoundedButtonFactory.createAppRoundedButton(title: "common_button_confirm".localized)
    private var backButton: UIButton!
    
    // MARK: Properties
    
    private var confirmBottom: NSLayoutConstraint!
    private var viewModel: TopupCardCVVViewModelType!
    private let disposeBag = DisposeBag()
    private var themeService: ThemeService<AppTheme>
    
    // MARK: Initialization
    init(themeService: ThemeService<AppTheme>, viewModel: TopupCardCVVViewModelType) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: \(coder) has not been implemented")
    }
    
    // MARK: View cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton = addBackButton(of: .backEmpty)
        title = "screen_topup_card_cvv_display_text_title".localized
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        
        if UIScreen.screenType != .iPhone5 {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        setupViews()
        setupTheme()
        setupConstraints()
        bindViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cvv.becomeFirstResponder()
    }
    
    // MARK: Actions
    
    @objc
    func tapped() {
        view.endEditing(true)
    }
    
//    override func onTapBackButton() {
//        navigationController?.popViewController(animated: true)
//        viewModel.inputs.back.onNext(())
//    }
}

// MARK: View setup

private extension TopupCardCVVViewController {
    func setupViews() {
        view.addSubview(cardImage)
        view.addSubview(cardTitle)
        view.addSubview(cardNumber)
        view.addSubview(amount)
        view.addSubview(cvv)
        view.addSubview(confirm)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to:  view.rx.backgroundColor )
            .bind({ UIColor($0.primaryDark) }, to: [cardTitle.rx.textColor, backButton.rx.tintColor])
            .bind({ UIColor($0.greyDark) }, to: [cardNumber.rx.textColor, amount.rx.textColor])
            
//            .bind({ UIColor($0.greyLight) }, to: textField.rx.bottomLineColorNormal)
//            .bind({ UIColor($0.primary) }, to: textField.rx.bottomLineColorWhileEditing)
//            .bind({ UIColor($0.greyDark) }, to: tipsLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: confirm.rx.backgroundColor)
            .bind({ UIColor($0.primary) }, to: confirm.rx.enabledBackgroundColor)
            .bind({ UIColor($0.greyDark) }, to: confirm.rx.disabledBackgroundColor)
            .disposed(by: rx.disposeBag)
    }
    
    func setupConstraints() {
        cardImage
            .alignEdgeWithSuperview(.safeAreaTop, constant: 40)
            //.alignEdgeWithSuperview(.safeAreaTop, .lessThanOrEqualTo, constant: 30)
            //.alignEdgeWithSuperview(.safeAreaTop, .greaterThanOrEqualTo, constant: 15)
            .centerHorizontallyInSuperview()
            .width(constant: 90)
            .height(constant: 56)
        
        cardTitle
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .toBottomOf(cardImage, .lessThanOrEqualTo, constant: 20)
            .toBottomOf(cardImage, .greaterThanOrEqualTo, constant: 10)
        
        cardNumber
            .toBottomOf(cardTitle)
            .alignEdgesWithSuperview([.left, .right], constant: 25)
        
        amount
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .toBottomOf(cardNumber, .lessThanOrEqualTo, constant: 15)
            .toBottomOf(cardNumber, .greaterThanOrEqualTo, constant: 10)
        
        cvv
            .toBottomOf(amount, .lessThanOrEqualTo, constant: 38)
            .toBottomOf(amount, .greaterThanOrEqualTo, constant: 20)
            .height(constant: 64)
            .centerHorizontallyInSuperview()
        
        confirm
            .toBottomOf(cvv, .greaterThanOrEqualTo, constant: 25)
            .centerHorizontallyInSuperview()
            .height(constant: 52)
            .width(constant: 190)
        
        confirmBottom = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: confirm.bottomAnchor, constant: 25)
        confirmBottom.isActive = true
    }
}

// MARK: Binding

private extension TopupCardCVVViewController {
    func bindViews() {
        viewModel.outputs.cardImage.bind(to: cardImage.rx.image).disposed(by: disposeBag)
        viewModel.outputs.cardTitle.bind(to: cardTitle.rx.text).disposed(by: disposeBag)
        viewModel.outputs.cardNumber.bind(to: cardNumber.rx.text).disposed(by: disposeBag)
        viewModel.outputs.amount.bind(to: amount.rx.attributedText).disposed(by: disposeBag)
        viewModel.outputs.cvvCount.subscribe(onNext: { [weak self] in self?.cvv.numberOfTextFields = $0 }).disposed(by: disposeBag)
        viewModel.outputs.confirmEnabled.bind(to: confirm.rx.isEnabled).disposed(by: disposeBag)
        viewModel.outputs.error.bind(to: rx.showErrorMessage).disposed(by: disposeBag)
        cvv.rx.text.bind(to: viewModel.inputs.cvvObserver).disposed(by: disposeBag)
        confirm.rx.tap
            .do(onNext: { [weak self] _ in self?.view.endEditing(true) })
            .bind(to: viewModel.inputs.confirmObserver)
            .disposed(by: disposeBag)
                
        backButton.rx.tap
                .do(onNext: { [weak self] _ in self?.view.endEditing(true) })
                .bind(to: viewModel.inputs.back)
                    .disposed(by: disposeBag)
    }
}

// MARK: Keyboard handling

private extension TopupCardCVVViewController {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            confirmBottom.constant = keyboardSize.height + 15
            UIView.animate(withDuration: 0.25) { [unowned self] in
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.confirmBottom.constant = 25
        UIView.animate(withDuration: 0.25) { [unowned self] in
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: Text field delegate

extension TopupCardCVVViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < cvv.numberOfTextFields
    }
}
