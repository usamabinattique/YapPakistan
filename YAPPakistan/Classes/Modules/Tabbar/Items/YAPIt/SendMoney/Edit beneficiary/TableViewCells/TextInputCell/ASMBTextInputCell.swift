//
//  ASMBTextInputCell.swift
//  YAPPakistan
//
//  Created by Muhammad Sohaib on 16/03/2022.
//

import UIKit
import YAPCore
import YAPComponents
import RxSwift
import RxCocoa
import RxDataSources
import RxTheme

public class ASMBTextInputCell: RxUITableViewCell {

    // MARK: Views
    
    private lazy var textField: AppTextField = {
        let textField = AppTextField()
        textField.font = .large
        textField.title.font = .small
        textField.delegate = self
        textField.returnKeyType = .next
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var infoButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var crossButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var toolbar: UIView = {
        return UIToolbar.getToolBar(target: self, done: #selector(doneAction), cancel: #selector(cancelAction))
    }()
    
    // MARK: Properties
    private var themeService: ThemeService<AppTheme>!
    private var viewModel: ASMBTextInputCellViewModelType!
    
    // MARK: Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
        
        setupViews()
        setupConstraints()
        setupSensitiveViews()
    }
    
    // MARK: Configurations
    
    override public func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? ASMBTextInputCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
        setupTheme()
    }
    
    // MARK: Actions
    
    @objc
    private func doneAction() {
        textField.resignFirstResponder()
        viewModel.inputs.resigneObserver.onNext(())
    }
    
    @objc
    private func cancelAction() {
        textField.resignFirstResponder()
    }

}

// MARK: View setup

private extension ASMBTextInputCell {
    func setupViews() {
        contentView.addSubview(textField)
        contentView.addSubview(infoButton)
        contentView.addSubview(crossButton)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark)}, to: [infoButton.rx.tintColor])
            .bind({ UIColor($0.separatorColor) }, to: [textField.rx.bottomBarColor])
            .bind({ UIColor($0.greyDark) }, to: [textField.rx.titleColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupConstraints() {
        textField
            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constants: [25, 0, 25, 0])
            .height(constant: 80)
        
        infoButton
            .alignEdge(.right, withView: textField, constant: 5)
            .alignEdge(.centerY, withView: textField)
            .width(constant: 30)
            .height(constant: 30)
        
        crossButton
            .alignEdge(.right, withView: textField, constant: 5)
            .alignEdge(.centerY, withView: textField)
            .width(constant: 16)
            .height(constant: 16)
    }
    
    func setupSensitiveViews()  {
//        UIView.markSensitiveViews([textField])
    }
}

// MARK: Binding

private extension ASMBTextInputCell {
    func bindViews() {
        viewModel.inputs.configObserver.onNext(())
        viewModel.outputs.title.bind(to: textField.rx.titleText).disposed(by: disposeBag)
        viewModel.outputs.animatesTitleOnEditingBegin.bind(to: textField.rx.animatesTitleOnEditingBegin).disposed(by: disposeBag)
        viewModel.outputs.icon.bind(to: textField.rx.icon).disposed(by: disposeBag)
        viewModel.outputs.placeholder.subscribe(onNext: { [weak self] in self?.textField.placeholder = $0 }).disposed(by: disposeBag)
        viewModel.outputs.attributedText.subscribe(onNext: { [weak self] in
            let selectedRange = self?.textField.selectedTextRange
            self?.textField.attributedText = $0
            self?.textField.selectedTextRange = selectedRange
        }).disposed(by: disposeBag)
        viewModel.outputs.isEnabled.bind(to: textField.rx.isEnabled).disposed(by: disposeBag)
        viewModel.outputs.infoButtonImage.bind(to: infoButton.rx.image(for: .normal)).disposed(by: disposeBag)
        viewModel.outputs.crossButtonImage.bind(to: crossButton.rx.image(for: .normal)).disposed(by: disposeBag)
        viewModel.outputs.showsInfoButton.map { !$0 }.bind(to: infoButton.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.showsCrossButton.map { !$0 }.bind(to: crossButton.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.textFieldTextFont.bind(to: textField.rx.font).disposed(by: disposeBag)
        viewModel.outputs.crossButtonTapped.map{ "" }.bind(to: viewModel.inputs.textObserver).disposed(by: disposeBag)
        
        viewModel.outputs.returnType.subscribe(onNext: { [weak self] in self?.textField.returnKeyType = $0 }).disposed(by: disposeBag)
        viewModel.outputs.keyboardType.subscribe(onNext: { [weak self] in self?.textField.keyboardType = $0 }).disposed(by: disposeBag)
        viewModel.outputs.captalizationType.subscribe(onNext: { [weak self] in self?.textField.autocapitalizationType = $0 }).disposed(by: disposeBag)
        viewModel.outputs.showsAccessory.filter { $0 }.subscribe(onNext: { [weak self] _ in self?.textField.inputAccessoryView = self?.toolbar }).disposed(by: disposeBag)
        
        /*viewModel.outputs.showInfo.unwrap().subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            YAPInfoView.show(info: $0, fromView: self.infoButton)
        }).disposed(by: disposeBag)*/
        
        textField.rx.text.bind(to: viewModel.inputs.textObserver).disposed(by: disposeBag)
        infoButton.rx.tap.bind(to: viewModel.inputs.infoTappedObserver).disposed(by: disposeBag)
        crossButton.rx.tap.bind(to: viewModel.inputs.crossTappedObserver).disposed(by: disposeBag)
        
        viewModel.outputs.becomeResponder.filter { $0 }.subscribe(onNext: { [weak self] _ in _ = self?.textField.becomeFirstResponder() }).disposed(by: disposeBag)
        
        viewModel.outputs.valid
            .map{ [weak self] in self?.infoButton.isHidden ?? true && $0 ? .valid : .normal }
            .bind(to: textField.rx.validationState).disposed(by: disposeBag)
//        viewModel.outputs.inputError.bind(to: textField.rx.errorText).disposed(by: disposeBag)
//        viewModel.outputs.inputError.map{ $0 == nil ? .normal : .invalid }
//            .bind(to: textField.rx.validationState).disposed(by: disposeBag)
    }
}

// MARK: Textfield delegate

extension ASMBTextInputCell: UITextFieldDelegate {
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
