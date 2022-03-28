//
//  SMFTNoteCell.swift
//  YAP
//
//  Created by Zain on 15/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import YAPComponents
import RxTheme

class SMFTNoteCell: RxUITableViewCell {

    // MARK: Views
    
    private lazy var textField: AppTextField = {
        let textField = AppTextField()
        textField.delegate = self
        textField.autocorrectionType = .no
        textField.placeholder = "screen_international_funds_transfer_input_text_note_hint".localized
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // MARK: Properties
    
    private var viewModel: SMFTNoteCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
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
    }
    
    // MARK: Configurations
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? SMFTNoteCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
    }
}

// MARK: View setup

private extension SMFTNoteCell {
    func setupViews() {
        contentView.addSubview(textField)
    }
    
    func setupConstraints() {
        textField
            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constants: [25, 0, 25, 0])
            .height(constant: 70)
    }
}

// MARK: Binding

private extension SMFTNoteCell {
    func bindViews() {
        viewModel.outputs.text.bind(to: textField.rx.text).disposed(by: disposeBag)
        textField.rx.text.bind(to: viewModel.inputs.textObserver).disposed(by: disposeBag)
        viewModel.outputs.error.bind(to: textField.rx.errorText).disposed(by: disposeBag)
        viewModel.outputs.error.map{ $0 == nil ? .normal : .invalid }
            .bind(to: textField.rx.validationState).disposed(by: disposeBag)
    }
}

// MARK: Textfield delegate

extension SMFTNoteCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        return ValidationService.shared.validateTransactionRemarks(newString) || string.count == 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.inputs.textObserver.onNext(textField.text)
    }
}
