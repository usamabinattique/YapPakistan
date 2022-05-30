//
//  Y2YFundsTransferViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 24/01/2022.
//

import UIKit
import YAPCore
import YAPComponents
import MessageUI
import RxSwift
import RxTheme

class Y2YFundsTransferViewController: UIViewController {

    // MARK: Views

    private lazy var userImage = UIFactory.makeImageView(contentMode: .scaleAspectFill) //UIFactory.createBackgroundImageView(mode: .scaleAspectFill)

    private lazy var userName =  UIFactory.makeLabel(font: .large, alignment: .center) //UIFactory.ma.createUILabel(with: .primaryDark, textStyle: .large, alignment: .center)
    private lazy var phoneNumber = UIFactory.makeLabel(font: .micro,alignment: .center) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .center)
    private lazy var nameStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 8, arrangedSubviews: [userName, phoneNumber])

    private lazy var flagImage = UIFactory.makeImageView() //UIImageViewFactory.createImageView(mode: .scaleAspectFit)
    private lazy var currency = UIFactory.makeLabel(font:.title1) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .title1)
    private lazy var currencyStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 9, arrangedSubviews: [flagImage, currency])
    

    private lazy var amountAlert: YAPAlert = {
        return YAPAlert()
    }()
    
    private lazy var amountView: AmountView = {
        let vm = AmountViewModel(heading:  "custom_view_display_text_amount_view".localized)
        let view = AmountView(viewModel: vm)
        view.amountTextField.placeholder =  "custom_view_display_text_amount_view_initial_value".localized
        view.amountTextField.inputAccessoryView = toolBar
        view.isCurrencyHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var amountStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 10, arrangedSubviews: [currencyStack, paddedView, amountView])
    
    private lazy var paddedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var toolBar =  UIToolbar.getToolBar(target: self, done: #selector(editingDoneAction), cancel: #selector(endEditingAction))

    private lazy var feeLabel = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var balance = UIFactory.makeLabel(font:.micro,alignment: .center,numberOfLines: 0,lineBreakMode: .byWordWrapping) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var noteTextField: AppTextField = {
        let textField = AppTextField()
        textField.delegate = self
        textField.autocorrectionType = .no
        textField.placeholder = "screen_y2y_funds_transfer_display_text_note_placeholder".localized
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var confirmButton = AppRoundedButtonFactory.createAppRoundedButton(title: "common_button_confirm".localized, font: .large)

    // MARK: Properties
    private var themeService: ThemeService<AppTheme>!
    private var viewModel: Y2YFundsTransferViewModelType!
    private let disposeBag = DisposeBag()
    private var confirmBottom: NSLayoutConstraint!
    private var backButton: UIButton!
    
    private var decimalPlaces: Int = 2 {
        didSet {
            amountView.allowedDecimal = decimalPlaces
        }
    }
    
    // MARK: Initialization
    init(themeService: ThemeService<AppTheme>, viewModel: Y2YFundsTransferViewModelType) {

        super.init(nibName: nil, bundle: nil)

        self.viewModel = viewModel
        self.themeService = themeService
    }


    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton = makeAndAddBackButton(of: viewModel.outputs.isPresented ? .closeEmpty : .backEmpty)
     //   navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.sharedImage(named: "icon_back"), style: .plain, target: self, action: #selector(closeAction))
        navigationItem.title = "screen_y2y_funds_transfer_display_text_title".localized

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditingAction)))

        setupViews()
        setupConstraints()
        render()
        bindViews()
        setupTheme()

        if UIScreen.screenType != .iPhone5 {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }

    // MARK: Actions

    @objc
    func endEditingAction() {
        view.endEditing(true)
    }

    @objc
    func editingDoneAction() {
        noteTextField.becomeFirstResponder()
    }

    @objc
    func closeAction() {
        viewModel.inputs.backObserver.onNext(())
    }

      func showAlert(msg message: String) {

          let attributedString = NSMutableAttributedString(string: "Psst…\n\n" + message)


          let paragraphStyle0 = NSMutableParagraphStyle()
          paragraphStyle0.alignment = .center

          let attributes0: [NSAttributedString.Key : Any] = [
            .foregroundColor: UIColor(themeService.attrs.primaryDark),//UIColor(Color(hex: "#272262")),//UIColor.primaryDark,
              .font: UIFont.title3,
              .paragraphStyle: paragraphStyle0
          ]
          attributedString.addAttributes(attributes0, range: NSRange(location: 0, length: 4))

          let paragraphStyle2 = NSMutableParagraphStyle()
          paragraphStyle2.alignment = .center

          let attributes2: [NSAttributedString.Key : Any] = [
            .foregroundColor: UIColor(themeService.attrs.greyDark),//UIColor(Color(hex: "#9391B1")),//UIColor.greyDark,
              .font: UIFont.small,
              .paragraphStyle: paragraphStyle2
          ]
          attributedString.addAttributes(attributes2, range: NSRange(location: 5, length: message.count))

      /*  let alertView = YAPAlert() //YAPAlertView(icon: UIImage.sharedImage(named: "icon_card_expired_purple"), text: attributedString, primaryButtonTitle: "OK, got it!".localized, cancelButtonTitle:nil)

          alertView.rx.cancelTap.subscribe(onNext: {_ in
          }).disposed(by: disposeBag)

          alertView.rx.primaryTap.subscribe(onNext: {_ in

          }).disposed(by: disposeBag)


          alertView.show(inView: self.view, type: .notificaiton, text: attributed) */
      }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
          // .bind({ UIColor( $0.greyLightSecondary ).withAlphaComponent(0.36)}, to: [amountView.rx.backgroundColor])
            .bind({ UIColor($0.greyDark) }, to: [feeLabel.rx.textColor,phoneNumber.rx.textColor])
            .bind({ UIColor($0.primaryExtraLight) }, to: [balance.rx.textColor])
            .bind({ UIColor($0.primaryDark)}, to: [backButton.rx.tintColor])
            .bind({ UIColor($0.primary)}, to: [confirmButton.rx.backgroundColor])
            .disposed(by: rx.disposeBag)



    }
    
    override func onTapBackButton() {
        viewModel.inputs.closeObserver.onNext(())
    }

}

// MARK: View setup

private extension Y2YFundsTransferViewController {
    func setupViews() {
        view.backgroundColor = .white

        view.addSubview(userImage)
        view.addSubview(nameStack)
        view.addSubview(amountStack)
//        view.addSubview(flagImage)
//        view.addSubview(amountView)
        view.addSubview(feeLabel)
        view.addSubview(balance)
        view.addSubview(noteTextField)
        view.addSubview(confirmButton)
    }

    func setupConstraints() {

        userImage
            .alignEdgeWithSuperview(.top, .lessThanOrEqualTo, constant: 32)
            .alignEdgeWithSuperview(.top, .greaterThanOrEqualTo, constant: 0)
            .centerHorizontallyInSuperview()
            .height(constant: 64)
            .width(with: .height, ofView: userImage)

        nameStack
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .toBottomOf(userImage, .lessThanOrEqualTo, constant: 20)
            .toBottomOf(userImage, .greaterThanOrEqualTo, constant: 5)
        
        amountStack
            .toBottomOf(nameStack, .lessThanOrEqualTo, constant: 25)
            .toBottomOf(nameStack, .greaterThanOrEqualTo, constant: 5)
            .centerHorizontallyInSuperview()
//            .alignEdgesWithSuperview([.left, .right], constant: 25)
        
        amountView
            .width(constant: 150)
            .alignEdgeWithSuperview(.right)
        
        currency
            .width(constant: 56)
        
        flagImage
            .width(constant: 25)
            .height(constant: 25)
        
        currencyStack
            .alignEdgeWithSuperview(.left)
        
        paddedView
            .height(constant: 10)
            .width(constant: UIScreen.main.bounds.width - 300)
        
        feeLabel
            .alignEdgeWithSuperview(.left, constant: 25)
            .centerHorizontallyInSuperview()
            .toBottomOf(amountStack, .lessThanOrEqualTo, constant: 30)
            .toBottomOf(amountStack, .greaterThanOrEqualTo, constant: 8)

        balance
            .alignEdgeWithSuperview(.left, constant: 25)
            .centerHorizontallyInSuperview()
            .toBottomOf(feeLabel, constant: 10)

        noteTextField
            .toBottomOf(balance, .lessThanOrEqualTo, constant: 45)
            .toBottomOf(balance, .greaterThanOrEqualTo, constant: 10)
            .alignEdgesWithSuperview([.left, .right], constant: 25)

        confirmButton
            .toBottomOf(noteTextField, .greaterThanOrEqualTo, constant: 10)
            .centerHorizontallyInSuperview()
            .width(constant: 190)
            .height(constant: 52)
        
        currency.setContentHuggingPriority(.defaultLow, for: .horizontal)

        confirmBottom = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: 15)
        confirmBottom.isActive = true
    }

    func render() {
        userImage.layer.cornerRadius = 32
        userImage.clipsToBounds = true
    }
}

// MARK: Binding

private extension Y2YFundsTransferViewController {
    func bindViews() {
        viewModel.outputs.userImage.bind(to: userImage.rx.loadImage()).disposed(by: disposeBag)
        viewModel.outputs.userName.bind(to: userName.rx.text).disposed(by: disposeBag)
        viewModel.outputs.balance.bind(to: balance.rx.attributedText).disposed(by: disposeBag)
       // viewModel.outputs.confirmEnabled.bind(to: confirmButton.rx.isEnabled).disposed(by: disposeBag)
        
        viewModel.outputs.confirmEnabled.subscribe(onNext: { [weak self] isEnabled in
            print("isConfirmEnabled \(isEnabled)")
            self?.confirmButton.isEnabled = isEnabled
            self?.confirmButton.backgroundColor = isEnabled ? UIColor(Color(hex: "#5E35B1")) : UIColor(Color(hex: "#5E35B1")).withAlphaComponent(0.50)
        }).disposed(by: disposeBag)

        
//        viewModel.outputs.showError.bind(to: view.rx.showAlert(ofType: .error)).disposed(by: disposeBag)
        viewModel.outputs.currency.bind(to: currency.rx.text).disposed(by: disposeBag)
        viewModel.outputs.flag.bind(to: flagImage.rx.image).disposed(by: disposeBag)
        viewModel.outputs.isInputValid.subscribe(onNext: { [weak self] in
            //self?.amountView.amountTextField.layer.borderColor = ($0 ? UIColor.clear : UIColor.error).cgColor
            self?.amountView.amountTextField.layer.borderColor = ($0 ? UIColor.clear : UIColor.red).cgColor
        }).disposed(by: disposeBag)
        viewModel.outputs.fee.bind(to: feeLabel.rx.attributedText).disposed(by: disposeBag)

        viewModel.outputs.amountError
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                $0 == nil ? self.amountAlert.hide() :
                    self.amountAlert.show(inView: self.view, type: .error, text: $0!, autoHides: false) })
            .disposed(by: disposeBag)
        
        amountView.amountTextField.rx.text.map{ $0?.removingGroupingSeparator() }.bind(to: viewModel.inputs.amountObserver).disposed(by: disposeBag)
        noteTextField.rx.text.bind(to: viewModel.inputs.noteObserver).disposed(by: disposeBag)


        let done = confirmButton.rx.tap
            .do(onNext: { [weak self] _ in self?.view.endEditing(true) })
                .withLatestFrom( Observable.just(false) /*SessionManager.current.currentAccount.map{ $0?.restrictions.contains(.otpBlocked) ?? false } */)
//
        done.filter{ $0 }.subscribe(onNext: { _ in
         //   UserAccessRestriction.otpBlocked.showFeatureBlockAlert()
        }).disposed(by: disposeBag)

        done.filter{ !$0 }.map{ _ in }
            .do(onNext: { [weak self] in self?.view.endEditing(true) })
            .bind(to: viewModel.inputs.confirmObserver).disposed(by: disposeBag)
        
        viewModel.outputs.allowedDecimalPlaces.subscribe(onNext: { [weak self] in
            self?.decimalPlaces = $0
        }).disposed(by: disposeBag)

        viewModel.outputs.coolingTransactionReminderAlert.subscribe(onNext: {[weak self] message in
                 guard let `msg` = message else { return }
                 self?.showAlert(msg: msg)
             }).disposed(by: disposeBag)
        
        viewModel.outputs.noteError.bind(to: noteTextField.rx.errorText).disposed(by: disposeBag)
        viewModel.outputs.noteError.map{ $0 == nil ? .normal : .invalid }
            .bind(to: noteTextField.rx.validationState).disposed(by: disposeBag)
        
        viewModel.outputs.showsFlag.subscribe(onNext: { [weak self] in
            self?.currencyStack.isHidden = !$0
            self?.paddedView.isHidden = !$0
            self?.amountView.isCurrencyHidden = $0
            self?.phoneNumber.isHidden = false //$0
        }).disposed(by: disposeBag)
        
        viewModel.outputs.phoneNumber.bind(to: phoneNumber.rx.text).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: navigationItem.rx.title).disposed(by: disposeBag)
    }
}

// MARK: Textfield delegate

extension Y2YFundsTransferViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        return ValidationService.shared.validateTransactionRemarks(newString) || string.count == 0
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.inputs.noteObserver.onNext(textField.text)
    }
}

// MARK: Keyboard handling

fileprivate extension Y2YFundsTransferViewController {

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            confirmBottom.constant = keyboardSize.height + 10 - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
            UIView.animate(withDuration: 0.25) { [unowned self] in
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.confirmBottom.constant = 15
        UIView.animate(withDuration: 0.25) { [unowned self] in
            self.view.layoutIfNeeded()
        }
    }
}

