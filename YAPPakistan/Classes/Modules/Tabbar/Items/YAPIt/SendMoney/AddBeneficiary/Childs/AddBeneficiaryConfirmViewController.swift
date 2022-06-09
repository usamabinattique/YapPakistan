//
//  AddBeneficiaryConfirmViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 17/03/2022.
//

import UIKit
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme
import RxDataSources

class AddBeneficiaryConfirmViewController: AddBeneficiaryBankListContainerChildViewController {

    private lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.text = "screen_add_beneficiary_detail_display_text_bank_account_confirm_heading".localized
        label.font = .title3
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bankImageContainerView = UIFactory.makeCircularView(  borderColor: UIColor(Color(hex: "#F1F5FE")), borderWidth: 0.7)
    private lazy var bankImage =  UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private lazy var bankName = UIFactory.makeLabel(font: .regular,alignment: .center)
    private lazy var bankAccount = UIFactory.makeLabel(font: .micro,alignment: .center)
    
    private lazy var beneficiaryFountLabel =  UIFactory.makeLabel(font: .regular,alignment: .center)
    
    
   // private lazy var imageStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fillEqually, spacing: 0, arrangedSubviews: [bankImageContainerView])
    private lazy var detailsStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fillEqually, spacing: 0, arrangedSubviews: [bankName,bankAccount])
    private lazy var detailsStackContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    //Account number/IBAN
    private lazy var titleField: UILabel = UIFactory.makeLabel(font: .micro, numberOfLines: 0)
    
    // MARK: Views
    private lazy var userImage: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var name = UIFactory.makeLabel(font: .small)
    
    private lazy var nameStack = UIFactory.makeStackView(axis: .vertical, alignment: .leading, distribution: .fill, spacing: 4, arrangedSubviews: [name])
    
    private lazy var textField: AppTextField = {
        let textField = AppTextField()
        textField.delegate = self
        textField.returnKeyType = .next
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.bottomBarColor = UIColor(themeService.attrs.greyLight) //UIColor(Color(hex: "#DAE0F0")) // greyLight
        return textField
    }()
    
    private lazy var toolbar: UIView = {
        return getToolBar(target: self, done: #selector(doneAction), cancel: #selector(cancelAction))
    }()
    
    private lazy var infoLabel = UIFactory.makeLabel(font: .large, alignment: .left, numberOfLines: 0, lineBreakMode: .byWordWrapping)
    
    private lazy var doneButton: AppRoundedButton = AppRoundedButtonFactory.createAppRoundedButton()
    
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


    private var viewModel: AddBeneficiaryConfirmViewModelType!
    private var themeService:ThemeService<AppTheme>!

    init(themeService:ThemeService<AppTheme>, viewModel: AddBeneficiaryConfirmViewModelType?) {
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
       // viewModel?.inputs.poppedObserver.onNext(())
    }
    
    @objc
    private func doneAction() {
        textField.resignFirstResponder()
        viewModel.inputs.resigneObserver.onNext(())
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
        toolBar.tintColor = UIColor(themeService.attrs.primaryDark) // primary dark
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

extension AddBeneficiaryConfirmViewController {
    func setupViews() {
        view.addSubview(headingLabel)
        view.addSubview(detailsStackContainer)
        bankImageContainerView.addSubview(bankImage)
        detailsStackContainer.addSubview(bankImageContainerView)
        detailsStackContainer.addSubview(detailsStack)
        detailsStackContainer.layer.cornerRadius = 12
        detailsStackContainer.layer.borderWidth = 0.7
        
        view.addSubview(textField)
        view.addSubview(infoLabel)
        view.addSubview(doneButton)
        view.addSubview(titleField)
        doneButton.setTitle("Add", for: .normal)
        titleField.text = "screen_add_beneficiary_detail_display_text_transfer_nick_name".localized
        textField.placeholder = "screen_add_beneficiary_detail_input_text_nick_name_hint".localized
        infoLabel.text = "The beneficiary found:"
        
        userImage.roundView()
        view.addSubview(userImage)
        view.addSubview(name)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor, bankImageContainerView.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark    ) }, to: [headingLabel.rx.textColor, bankName.rx.textColor, infoLabel.rx.textColor,titleField.rx.textColor,name.rx.textColor])
            .bind({ UIColor($0.greyLight    ) }, to: [detailsStackContainer.rx.borderColor])
            .bind({ UIColor($0.primary    ) }, to: [doneButton.rx.enabledBackgroundColor])
            .bind({ UIColor($0.primaryLight    ) }, to: [doneButton.rx.disabledBackgroundColor])
            .bind({ UIColor($0.primaryDark).withAlphaComponent(0.50) }, to: [textField.rx.placeholderColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupResources() {
       
    }
    
    func setupConstraints() {
        
        headingLabel
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .alignEdgeWithSuperviewSafeArea(.top, constant: 32)
        
        detailsStackContainer
            .toBottomOf(headingLabel, .equalTo, constant: 20)
            .alignEdgeWithSuperviewSafeArea(.left, constant: 24)
            .alignEdgeWithSuperviewSafeArea(.right, constant: 24)
            .centerHorizontallyInSuperview()
            .height(constant: 136)
        
           
        
        bankImage
            .height(constant: 32)
            .width(constant: 32)
            .centerHorizontallyInSuperview()
            .centerVerticallyInSuperview()
        
        bankImageContainerView
            .height(constant: 44)
            .width(constant: 44)
            .alignEdgeWithSuperview(.top,constant: 16)
            .centerHorizontallyInSuperview()
        
        detailsStack
            .centerHorizontallyInSuperview()
            .toBottomOf(bankImageContainerView, constant: 16)
            .alignEdgeWithSuperview(.bottom, .greaterThanOrEqualTo ,constant: 0)
        
        infoLabel
            .alignEdgesWithSuperview([.right, .left], constants: [24, 24])
            .toBottomOf(detailsStackContainer, constant: 20)
        
        userImage
            .alignEdgesWithSuperview([ .left], constants: [24])
            .toBottomOf(infoLabel, constant: 20)
            .height(constant: 42)
            .width(constant: 42)
        
        name
            .toRightOf(userImage, constant: 20)
            .alignEdge(.centerY, withView: userImage)
        
        titleField
            .alignEdgesWithSuperview([.left, .right], constants: [24, 24])
            .toBottomOf(userImage,constant: 32)
        
        textField
            .alignEdgesWithSuperview([.left, .right], constants: [24, 24])
            .toBottomOf(titleField, constant: -20)
            .height(constant: 80)
        
       
        
        doneButton
            .alignEdgeWithSuperviewSafeArea(.bottomAvoidingKeyboard, constant: 34)
            .toBottomOf(textField, .greaterThanOrEqualTo)
            .centerHorizontallyInSuperview()
            .height(constant: 52)
            .width(constant: 190)
    }
}

// MARK: Binding

private extension AddBeneficiaryConfirmViewController {
    func bindViews() {
        guard let viewModel = viewModel else { return }
        
        viewModel.outputs.bankImage.bind(to: bankImage.rx.loadImage()).disposed(by: rx.disposeBag)
        viewModel.outputs.name.bind(to: bankName.rx.text).disposed(by: rx.disposeBag)
        
        viewModel.outputs.showError.subscribe(onNext: { [weak self] error in
            self?.showAlert(title: "", message: error, defaultButtonTitle: "common_button_ok".localized)
        }).disposed(by: rx.disposeBag)
        
        bindAccountInfo()
       
    }
    
    func bindAccountInfo() {
        viewModel.inputs.configObserver.onNext(())
        viewModel.outputs.title.bind(to: textField.rx.titleText).disposed(by: rx.disposeBag)
        viewModel.outputs.animatesTitleOnEditingBegin.bind(to: textField.rx.animatesTitleOnEditingBegin).disposed(by: rx.disposeBag)
        viewModel.outputs.icon.bind(to: textField.rx.icon).disposed(by: rx.disposeBag)
      //  viewModel.outputs.placeholder.subscribe(onNext: { [weak self] in self?.textField.placeholder = $0 }).disposed(by: rx.disposeBag)
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
        
        
        
        textField.rx.text.bind(to: viewModel.inputs.textObserver).disposed(by: rx.disposeBag)
        
        
        viewModel.outputs.becomeResponder.filter { $0 }.subscribe(onNext: { [weak self] _ in _ = self?.textField.becomeFirstResponder() }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.accountNumber.bind(to:  bankAccount.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.accountTitle.bind(to:  name.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.userImage.bind(to: userImage.rx.loadImage()).disposed(by: rx.disposeBag)
    }
}

// MARK: Textfield delegate
extension AddBeneficiaryConfirmViewController: UITextFieldDelegate {
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
