//
//  PhoneNumberView.swift
//  YAPComponents
//
//  Created by Awais on 13/04/2022.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import PhoneNumberKit
import RxTheme

open class PhoneNumberView: UIView {

    fileprivate lazy var title: UILabel = {
        let label = UILabel()
        label.font = .small
        label.textAlignment = .left
        label.textColor =  UIColor(Color(hex: "#272262")) //UIColor.darkGray //UIColor(themeService.attrs.primaryDark) //.primaryDark
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public lazy var textField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .left
        textField.textColor = UIColor.darkGray //UIColor.darkGray //UIColor(themeService.attrs.primaryDark) //.primaryDark.withAlphaComponent(0.5)
        textField.keyboardType = .asciiCapableNumberPad
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var bottomBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(Color(hex: "#272262")) //UIColor.gray //UIColor(themeService.attrs.grey) //.grey
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    fileprivate lazy var error: UILabel = {
        let label = UILabel()
        label.font = .micro
        label.textAlignment = .left
        label.textColor = UIColor.gray // UIColor.gray //UIColor(themeService.attrs.grey) //.grey
        label.isHidden = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var stateImage: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    //MARK: Properties
    private let phoneNumberKit = PhoneNumberKit()
    public var currencyCode: Int = 0

    // MAKR: - Control properties
    public var invalidInputImage: UIImage? = UIImage.init(named: "icon_invalid", in: .yapPakistan, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    public var validInputImage: UIImage? = UIImage.init(named: "icon_check", in: .yapPakistan, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

    public var validationState: PhoneNumberView .ValidationState = .normal {
        didSet {
            guard oldValue != validationState else { return }
            stateImage.isHidden = validationState == .normal
            stateImage.image = validationState == .valid ? validInputImage : validationState == .invalid ? invalidInputImage : nil
            stateImage.tintColor = validationState == .valid ? UIColor(Color(hex: "#272262")) : validationState == .invalid ? UIColor.red : .clear
            bottomBar.backgroundColor = validationState == .invalid ? UIColor.red : UIColor(Color(hex: "#272262")) //.primary
            bottomBar.backgroundColor = validationState == .normal ? UIColor.red : UIColor(Color(hex: "#272262")) //.primary
            
            error.isHidden = validationState != .invalid
        }
    }
    
    public var errorText: String? {
        get { return error.text }
        set (newValue) { error.text = newValue }
    }

    public var titleText: String? {
        get { return title.text }
        set (newValue) { title.text = newValue }
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
}

// MARK: - View setup
private extension PhoneNumberView {
    func setupViews() {
        addSubview(title)
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(stateImage)
        addSubview(stackView)

        addSubview(bottomBar)
        addSubview(error)

    }

    func setupConstraints() {

        title
            .alignEdgeWithSuperview(.top)
            .alignEdgesWithSuperview([.left, .right], constants: [0, 0])
            .height(constant: 20)

        stackView
            .toBottomOf(title, constant: 3)
            .alignEdgesWithSuperview([.left, .right])
            .height(constant: 26)

        stateImage
            .alignEdgeWithSuperview(.right)
            .width(constant: 30)

        bottomBar
            .alignEdgeWithSuperview(.bottom, constant: 3)
            .alignEdgesWithSuperview([.left, .right])
            .height(constant: 1)

        error
            .toBottomOf(bottomBar, constant: 2)
            .alignEdgesWithSuperview([.left, .right])
            .height(constant: 20)
    }
}

extension PhoneNumberView: UITextFieldDelegate {

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        bottomBar.backgroundColor = UIColor.red //UIColor(Color(hex: "#272262"))  //UIColor(themeService.attrs.primary) //.primary
        title.textColor = UIColor.red //UIColor.darkGray //UIColor(themeService.attrs.greyDark) //.greyDark
        animateFocus()
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        bottomBar.backgroundColor = UIColor.lightGray //UIColor(Color(hex: "#272262")) //UIColor.darkGray //UIColor.gray //UIColor(themeService.attrs.grey) //.grey
        title.textColor = (textField.text == nil || textField.text?.count ?? 0 == 0) ? UIColor(Color(hex: "#272262")) : UIColor.darkGray //.greyDark
        if textField.text?.count ?? 0 == 0 {
            deanimateFocus()
        }
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if range.location < currencyCode {
            return false
        }
        if string == "" {
            if let t = textField.text {
                if t.count <= currencyCode { return false }
            }
        } else {
            do {
                _ = try phoneNumberKit.parse(textField.text!)
                return false
            } catch {
                if let t = textField.text {
                    if t.count >= 16 { return false } else { return true }
                }
            }
        }
        return true
    }
}

// MARK: Animations
private extension PhoneNumberView {
    func animateFocus() {
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.title.textColor = UIColor.darkGray //UIColor(themeService.attrs.greyDark) //.greyDark
        }
    }

    func deanimateFocus() {
        UIView.animate(withDuration: 0.3, animations: { [unowned self] in
            self.title.textColor = UIColor(Color(hex: "#272262")) // UIColor.gray //UIColor(themeService.attrs.primaryDark) //.primaryDark
        })
    }
}

// MARK: - Validation
extension PhoneNumberView {
    public enum ValidationState {
        case normal
        case valid
        case invalid
    }
}
// MARK: - Reactive
public extension Reactive where Base: PhoneNumberView {

    var validationState: Binder<PhoneNumberView.ValidationState> {
        return Binder(self.base) { textField, validation -> Void in
            textField.validationState = validation
        }
    }

    var attributedText: Binder<NSAttributedString> {
        return Binder(self.base) { phoneNumberView, text -> Void in
            phoneNumberView.textField.attributedText = text
        }
    }

    var errorText: Binder<String?> {
        return self.base.error.rx.text
    }

    var titleText: Binder<String?> {
        return self.base.title.rx.text
    }

    var countryCode: Binder<String?> {
        return Binder(self.base) { phoneNumberView, text -> Void in
            phoneNumberView.textField.text = text
            phoneNumberView.currencyCode = text?.count ?? 4
        }
    }

}
