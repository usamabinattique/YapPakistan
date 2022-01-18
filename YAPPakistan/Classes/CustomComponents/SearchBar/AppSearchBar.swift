//
//  AppSearchBar.swift
//  YAPKit
//
//  Created by Zain on 22/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class AppSearchBar: UIView {
    
    lazy var textField: AppSearchTextField = {
        let textField = AppSearchTextField()
        textField.borderStyle = .none
        textField.backgroundColor = .groupTableViewBackground
        textField.placeholder = "Search"
        textField.returnKeyType = .search
        textField.delegate = self
        textField.font = .small
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("common_button_cancel".localized, for: .normal)
        button.titleLabel?.font = .small
        button.setTitleColor(UIColor(red: 0.369, green: 0.208, blue: 0.694, alpha: 1.0), for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(cancelled(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fill
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    public weak var delegate: AppSearchBarDelegate?
    public var autoHidesCancelButton: Bool = true {
        didSet {
            cancelButton.isHidden = autoHidesCancelButton
        }
    }
    
    // MARK: Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        setupViews()
        setupConstraints()
    }
    
    // MARK: Actions
    
    @objc
    private func cancelled(_ sender: UIButton) {
        delegate?.searchBarCancelButtonClicked(self)
    }
    
    // MARK: View actions
    
    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    @discardableResult
    public override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
}

// MARK: Drawing

extension AppSearchBar {
    public override func draw(_ rect: CGRect) {
        textField.layer.cornerRadius = textField.bounds.height/2
    }
}

// MARK: View setup

private extension AppSearchBar {
    func setupViews() {
        addSubview(stack)
        stack.addArrangedSubview(textField)
        stack.addArrangedSubview(cancelButton)
    }
    
    func setupConstraints() {
        stack
            .alignAllEdgesWithSuperview()
        
        cancelButton
            .alignEdgesWithSuperview([.top, .bottom])
            .width(constant: 50)
        
        textField
            .alignEdgesWithSuperview([.top, .bottom])
    }
}

// MARK: Textfield delegate

extension AppSearchBar: UITextFieldDelegate {
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return delegate?.searchBarShouldBeginEditing(searchBar: self) ?? true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        guard autoHidesCancelButton else {
            delegate?.searchBarTextDidBeginEditing(searchBar: self)
            return
        }
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.cancelButton.isHidden = false
            self?.stack.layoutIfNeeded()
        }
        delegate?.searchBarTextDidBeginEditing(searchBar: self)
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return delegate?.searchBarShouldEndEditing(searchBar: self) ?? false
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        guard autoHidesCancelButton else {
            delegate?.searchBarTextDidBeginEditing(searchBar: self)
            return
        }
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.cancelButton.isHidden = true
            self?.stack.layoutIfNeeded()
        }
        delegate?.searchBarTextDidEndEditing(searchBar: self)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let change = delegate?.searchBar(self, shouldChangeTextIn: range, replacementText: string) ?? true
        if change {
            let text = textField.text as NSString?
            delegate?.searchBar(self, textDidChange: text?.replacingCharacters(in: range, with: string) ?? "")
        }
        return change
    }
}
