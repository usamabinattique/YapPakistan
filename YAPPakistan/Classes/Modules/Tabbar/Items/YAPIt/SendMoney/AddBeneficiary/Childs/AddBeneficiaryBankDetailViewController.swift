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
        label.font = .title3
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bankImageContainerView = UIFactory.makeCircularView(  borderColor: UIColor(Color(hex: "#F1F5FE")), borderWidth: 0.7)
    private lazy var bankImage =  UIFactory.makeImageView(contentMode: .scaleAspectFill)
    private lazy var bankName = UIFactory.makeLabel(font: .regular,alignment: .center)
    private lazy var accountNumber = UIFactory.makeLabel(font: .micro,alignment: .center)
    
    private lazy var detailsStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fillEqually, spacing: 2, arrangedSubviews: [bankImageContainerView,bankName,accountNumber])
    private lazy var detailsStackContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //Account number/IBAN
    private lazy var titleField: UILabel = UIFactory.makeLabel(font: .small, numberOfLines: 0)
    
    private lazy var textField: AppTextField = {
        let textField = AppTextField()
        textField.delegate = self
        textField.returnKeyType = .next
        textField.isValidationErrorShow = false
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.bottomBarColor = UIColor(themeService.attrs.greyLight) // greyLight
        return textField
    }()
    
    private lazy var infoButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
       // button.tintColor = .primaryDark
        button.setImage(UIImage.init(named: "icon_help",in: .yapPakistan)?.asTemplate, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var toolbar: UIView = {
        return getToolBar(target: self, done: #selector(doneAction), cancel: #selector(cancelAction))
    }()
    
    private lazy var infoLabel = UIFactory.makeLabel(font: .small, alignment: .left, numberOfLines: 0, lineBreakMode: .byWordWrapping)
    
    private lazy var doneButton: AppRoundedButton = AppRoundedButtonFactory.createAppRoundedButton(font: .large)
    
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

    private var viewModel: AddBeneficiaryBankDetailViewModelType!
    private var themeService:ThemeService<AppTheme>!
    private var sendButtonBottomConstraint: NSLayoutConstraint!

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
        viewModel?.inputs.poppedObserver.onNext(())
        textField.resignFirstResponder()
    }
    
    @objc
    private func doneAction() {
        viewModel.inputs.resigneObserver.onNext(())
        textField.resignFirstResponder()
    }
    
    @objc
    private func cancelAction() {
        textField.resignFirstResponder()
    }
    
    public func getToolBar(target: Any?, done: Selector?, cancel: Selector?) -> UIToolbar {
        
        let toolBar = UIToolbar()
        toolBar.autoresizingMask = .flexibleHeight
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
       // toolBar.tintColor = UIColor(Color(hex: "#272262")) // primary dark
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: target, action: done)
        
        var items: [UIBarButtonItem] = [doneButton]
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        items.insert(spaceButton, at: 0)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: target, action: cancel)
        items.insert(cancelButton, at: 0)
        
        toolBar.setItems(items, animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }

}

// MARK: View setup

extension AddBeneficiaryBankDetailViewController {
    func setupViews() {
        doneButton.setTitle("Find account", for: .normal)
        titleField.text = "Account number/IBAN"
        textField.placeholder = "Enter account number/IBAN"
        
        view.addSubview(scrollView)
       scrollView.addSubview(contentView)
        scrollView.addSubview(headingLabel)
       scrollView.addSubview(detailsStackContainer)
        
        bankImageContainerView.addSubview(bankImage)
        detailsStackContainer.addSubview(detailsStack)
        detailsStackContainer.layer.cornerRadius = 12
        detailsStackContainer.layer.borderWidth = 0.7
        
       scrollView.addSubview(textField)
       scrollView.addSubview(infoButton)
       scrollView.addSubview(doneButton)
       scrollView.addSubview(titleField)
        
        bankImage.clipsToBounds = true
        bankImage.layer.cornerRadius = bankImage.frame.size.height / 2
        
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor, bankImageContainerView.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark    ) }, to: [headingLabel.rx.textColor, bankName.rx.textColor, infoLabel.rx.textColor,titleField.rx.textColor, infoButton.rx.tintColor, toolbar.rx.tintColor])
            .bind({ UIColor($0.greyLight    ) }, to: [detailsStackContainer.rx.borderColor])
            .bind({ UIColor($0.primary    ) }, to: [doneButton.rx.enabledBackgroundColor])
            .bind({ UIColor($0.primaryLight    ) }, to: [doneButton.rx.disabledBackgroundColor])
            .bind({ UIColor($0.primaryDark).withAlphaComponent(0.50) }, to: [textField.rx.placeholderColor])
            .bind({ UIColor($0.greyDark    ) }, to: [accountNumber.rx.textColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupResources() {
       
    }
    
    func setupConstraints() {
        
        scrollView
            .alignEdgesWithSuperview([.top,.left,.right])
            .alignEdgeWithSuperviewSafeArea(.bottomAvoidingKeyboard, constant: 0)
            .centerHorizontallyInSuperview()
            .widthEqualTo(view: view)
        contentView
            .alignEdgesWithSuperview([.top,.bottom, .left,.right])
            .centerHorizontallyInSuperview()
            .widthEqualTo(view: scrollView)
            .heightEqualTo(view: scrollView)
        
        headingLabel
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .alignEdgeWithSuperviewSafeArea(.top, constant: 32)
        
        detailsStackContainer
            .toBottomOf(headingLabel, .equalTo, constant: 20)
            .alignEdgeWithSuperviewSafeArea(.left, constant: 24)
            .alignEdgeWithSuperviewSafeArea(.right, constant: 24)
            .centerHorizontallyInSuperview()
            .height(constant: 136)
        detailsStack
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.top,constant: 20)
            .alignEdgeWithSuperview(.bottom,.greaterThanOrEqualTo)
            //.centerVerticallyInSuperview()
        
        bankImage
            .height(constant: 32)
            .width(constant: 32)
            .centerHorizontallyInSuperview()
            .centerVerticallyInSuperview()
        
        bankImageContainerView
            .height(constant: 44)
            .width(constant: 44)
        
        titleField
            .alignEdgesWithSuperview([.left, .right], constants: [24, 24])
            .toBottomOf(detailsStackContainer,constant: 28)
        
        textField
            .alignEdgesWithSuperview([.left, .right], constants: [24, 24])
            .toBottomOf(titleField, constant: -20)
            .height(constant: 80)
        
        infoButton
            .alignEdgeWithSuperview(.right, constant: 25)
            .alignEdge(.centerY, withView: textField)
            .width(constant: 30)
            .height(constant: 30)
        
        doneButton
            .alignEdgeWithSuperviewSafeArea(.bottomAvoidingKeyboard, constant: 34)
            .toBottomOf(textField, .greaterThanOrEqualTo, constant: 12)
            .centerHorizontallyInSuperview()
            .height(constant: 52)
            .width(constant: 190)

//        sendButtonBottomConstraint = view.safeAreaLayoutGuide.bottomAnchor
//            .constraint(equalTo: doneButton.bottomAnchor, constant: 12)
//        sendButtonBottomConstraint.isActive = true
    }
}

// MARK: Binding

private extension AddBeneficiaryBankDetailViewController {
    func bindViews() {
        guard let viewModel = viewModel else { return }
        
        viewModel.outputs.bankImage
            .subscribe(onNext:{ [weak self] url, img in
                self?.bankImage.loadImage(with: url, placeholder: img, showsIndicator: true, refreshCachedImage: true)
            })
            .disposed(by: rx.disposeBag)
        viewModel.outputs.name.bind(to: bankName.rx.text).disposed(by: rx.disposeBag)
        
        bindAccountInfo()
       
    }
    
    func bindAccountInfo() {
        viewModel.inputs.configObserver.onNext(())
        viewModel.outputs.title.bind(to: textField.rx.titleText).disposed(by: rx.disposeBag)
        viewModel.outputs.animatesTitleOnEditingBegin.bind(to: textField.rx.animatesTitleOnEditingBegin).disposed(by: rx.disposeBag)
        viewModel.outputs.icon.bind(to: textField.rx.icon).disposed(by: rx.disposeBag)
        viewModel.outputs.attributedText.subscribe(onNext: { [weak self] in
            let selectedRange = self?.textField.selectedTextRange
            self?.textField.attributedText = $0
            self?.textField.selectedTextRange = selectedRange
        }).disposed(by: rx.disposeBag)
        viewModel.outputs.isEnabled.bind(to: textField.rx.isEnabled).disposed(by: rx.disposeBag)
       
        doneButton.rx.tap.bind(to: viewModel.inputs.doneObserver).disposed(by: rx.disposeBag)
        
        viewModel.outputs.returnType.subscribe(onNext: { [weak self] in self?.textField.returnKeyType = $0 }).disposed(by: rx.disposeBag)
        viewModel.outputs.keyboardType.subscribe(onNext: { [weak self] in self?.textField.keyboardType = $0 }).disposed(by: rx.disposeBag)
        viewModel.outputs.captalizationType.subscribe(onNext: { [weak self] in self?.textField.autocapitalizationType = $0 }).disposed(by: rx.disposeBag)
        viewModel.outputs.showsAccessory.filter { $0 }.subscribe(onNext: { [weak self] _ in self?.textField.inputAccessoryView = self?.toolbar }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.showInfo.unwrap().subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            YAPInfoView.show(info: $0, fromView: self.infoButton, infoLabel: self.infoLabel)
        }).disposed(by: rx.disposeBag)
        
        textField.rx.text.bind(to: viewModel.inputs.textObserver).disposed(by: rx.disposeBag)
        infoButton.rx.tap.bind(to: viewModel.inputs.infoTappedObserver).disposed(by: rx.disposeBag)
        
        viewModel.outputs.becomeResponder.filter { $0 }.subscribe(onNext: { [weak self] _ in _ = self?.textField.becomeFirstResponder() }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.inputError.subscribe(onNext: { [unowned self] isOkay in
            self.textField.bottomBarColor = UIColor(self.themeService.attrs.greyLight)
            self.infoButton.setTintColor(UIColor(self.themeService.attrs.primaryDark))
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.inputError.bind(to: doneButton.rx.isEnabled).disposed(by: rx.disposeBag)
        doneButton.isEnabled = false
    }
}

// MARK: Textfield delegate
extension AddBeneficiaryBankDetailViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return viewModel.outputs.canEdit(text: textField.text ?? "", replacementText: string, inRange: range)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel.inputs.resigneObserver.onNext(())
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.inputs.editingEndObserver.onNext(())
    }
}
