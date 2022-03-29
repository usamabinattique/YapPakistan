//
//  SMFTReasonCell.swift
//  YAP
//
//  Created by Zain on 15/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import YAPComponents
import RxSwift
import RxTheme

class SMFTReasonCell: RxUITableViewCell {
    // MARK: Views
    
    private lazy var selectionField: AppTextField = {
        let textField = AppTextField()
        textField.tintColor = .clear
        textField.placeholder = "screen_international_funds_transfer_display_text_reson".localized
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    private lazy var dropDown: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor.gray // ?
        imageView.image = UIImage.sharedImage(named: "icon_drop_down")?.withRenderingMode(.alwaysTemplate)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: Properties
    
    private var viewModel: SMFTReasonCellViewModelType!
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
        guard let viewModel = viewModel as? SMFTReasonCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
    }
}

// MARK: View setup

private extension SMFTReasonCell {
    func setupViews() {
        contentView.addSubview(selectionField)
        contentView.addSubview(dropDown)
    }
    
    func setupConstraints() {
        selectionField
            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constants: [25, 0, 25, 0])
            .height(constant: 80)
        
        dropDown
            .alignEdgeWithSuperview(.right, constant: 25)
            .alignEdge(.centerY, withView: selectionField)
        
    }
}

// MARK: Binding

private extension SMFTReasonCell {
    func bindViews() {
        viewModel.outputs.text.bind(to: selectionField.rx.text).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: selectionField.rx.titleText).disposed(by: disposeBag)
        viewModel.outputs.endEditting.bind(to: rx.endEditting).disposed(by: disposeBag)
    }
}

// MARK: Text field delegate

extension SMFTReasonCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        viewModel.inputs.selectReasonObserver.onNext(())
        textField.resignFirstResponder()
        return false
    }
}