//
//  UIViewController+Extension.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 20/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
// import AppAnalytics

public enum BackButtonType {
    case backCircled
    case backEmpty
    case closeCircled
    case closeEmpty
}

public extension UIViewController {
// Avoid usind this method sometime it creats issues use this method avoidKeyboard(_ avoid: Bool) for keyboard dismissing
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}

public extension UIViewController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Alert view
public extension UIViewController {
    func showAlert(title: String = "",
                   message: String,
                   defaultButtonTitle: String = "common_button_ok".localized,
                   secondayButtonTitle: String? = nil,
                   defaultButtonHandler: ((UIAlertAction) -> Void)? = nil,
                   secondaryButtonHandler: ((UIAlertAction) -> Void)? = nil,
                   completion: (() -> Void)? = nil) {

        let alert = UIAlertController(title: title.localized, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: defaultButtonTitle, style: .default, handler: defaultButtonHandler)
        alert.addAction(defaultAction)

        if secondayButtonTitle != nil {
            let action = UIAlertAction(title: secondayButtonTitle, style: .cancel, handler: secondaryButtonHandler)
            alert.addAction(action)
        }

        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: completion)
        }
    }

    func showAddBeneficiaryCancelAlert(title: String = "",
                                       message: String,
                                       cancelButtonTitle: String = "common_button_ok".localized,
                                       confirmButtonTitle: String? = nil,
                                       cancelButtonHandler: ((UIAlertAction) -> Void)? = nil,
                                       confirmButtonHandler: ((UIAlertAction) -> Void)? = nil,
                                       completion: (() -> Void)? = nil) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .default, handler: cancelButtonHandler)
        alert.addAction(cancelAction)

        if confirmButtonHandler != nil {
            let confirmAction = UIAlertAction(title: confirmButtonTitle, style: .default, handler: confirmButtonHandler)
            alert.addAction(confirmAction)
        }

        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: completion)
        }
    }

    func hideAlertView() {
        (presentedViewController as? UIAlertController)?.dismiss(animated: true)
    }

    func showActionSheet(title: String = "",
                         message: String,
                         defaultButtonTitle: String = "common_button_ok".localized,
                         secondayButtonTitle: String? = nil,
                         style: UIAlertController.Style = .actionSheet,
                         secondaryButtonStyle: UIAlertAction.Style = .default,
                         defaultButtonHandler: ((UIAlertAction) -> Void)? = nil,
                         secondaryButtonHandler: ((UIAlertAction) -> Void)? = nil,
                         completion: (() -> Void)? = nil) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let defaultAction = UIAlertAction(title: defaultButtonTitle, style: .cancel, handler: defaultButtonHandler)
        alert.addAction(defaultAction)

        if secondayButtonTitle != nil {
            let secondaryAction = UIAlertAction(title: secondayButtonTitle, style: secondaryButtonStyle, handler: secondaryButtonHandler)
            alert.addAction(secondaryAction)
        }

        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: completion)
        }
    }
}

extension Reactive where Base: UIViewController {
    public var showErrorMessage: Binder<String> {
        return Binder(base) { viewController, error in
            viewController.showAlert(message: error)
        }
    }
}

extension UIViewController {
    public func hideBackButton() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
    }

    public func addBackButton(_ type: BackButtonType = .backCircled, backgroundColor: UIColor, tintColor: UIColor) {

        let button = UIButton()
        button.frame = CGRect(x: 2, y: 0, width: 35, height: 35)
        button.setImage(UIImage(named: type == .backCircled || type == .backEmpty ? "icon_back" : "icon_close", in: .yapPakistan, compatibleWith: nil)?.asTemplate, for: .normal)
        button.tintColor = type == .backCircled || type == .closeCircled /*|| SessionManager.current.currentAccountType != .b2cAccount*/ ? tintColor : backgroundColor
        button.backgroundColor = type == .backCircled || type == .closeCircled ? backgroundColor : .clear
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.addTarget(self, action: #selector(onTapBackButton), for: .touchUpInside)
        
        let view:UIView = {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 37, height: 35))
            view.backgroundColor = .clear
            return view
        }()
        view.addSub(view: button)
        
        let backButton = UIBarButtonItem()
        backButton.customView = view
        navigationItem.leftBarButtonItem = backButton
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }

    public func addBackButton(of type: BackButtonType = .backCircled) -> UIButton? {
        let button = UIButton()
        button.frame = CGRect(x:2, y: 0, width: 35, height: 35)
        button.setImage(UIImage(named: type == .backCircled || type == .backEmpty ? "icon_back" : "icon_close", in: .yapPakistan, compatibleWith: nil)?.asTemplate, for: .normal)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        
        let view:UIView = {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 37, height: 35))
            view.backgroundColor = .clear
            return view
        }()
        view.addSub(view: button)
        
        let backButton = UIBarButtonItem()
        backButton.customView = view
        navigationItem.leftBarButtonItem  = backButton
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        return button
    }

    public func barButtonItem(image: UIImage?, insectBy insect: UIEdgeInsets) -> (button: UIButton?, barItem: UIBarButtonItem) {
        let button = UIButton()
        button.frame = CGRect(x: insect.left, y: 0, width: 35, height: 35)
        button.setImage(image, for: .normal)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width

        let view:UIView = {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 35 + insect.right, height: 35))
            view.backgroundColor = .clear
            return view
        }()
        view.addSub(view: button)

        let backButton = UIBarButtonItem()
        backButton.customView = view
        return (button, backButton)
    }

    /*
    public func addBackButtonWithOutNavBar(_ type: BackButtonType = .backCircled) {
        
        let button = UIButton()
        button.frame = CGRect(x: 20, y: 20, width: 35, height: 35)
        button.setImage(UIImage(named: type == .backCircled || type == .backEmpty ? "icon_back" : "icon_close", in: .YAPPakistan, compatibleWith: nil)?.asTemplate, for: .normal)
        button.tintColor = type == .backCircled || type == .closeCircled || SessionManager.current.currentAccountType != .b2cAccount ? .white : .primary
        button.backgroundColor = type == .backCircled || type == .closeCircled ? .primary : .clear
        
        button.addTarget(self, action: #selector(onTapBackButton), for: .touchUpInside)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.clipsToBounds = true
        view.addSubview(button)
    } */

    @objc open func onTapBackButton() {
        fatalError("Add back action in viewController")
    }
}

// MARK: - Navigation

extension UIViewController {
    @objc open func didPopFromNavigationController() {}

    public var lastPresentedViewController: UIViewController? {
        return presentedViewController?.lastPresentedViewController ?? presentedViewController
    }
}

// MARK: Keyoard avoiding

extension UIViewController {
    public func avoidKeyboard(_ avoid: Bool) {
        if avoid {
            _addKeyboardObserver()
        } else {
            _removeKeyboardObserver()
            _keyboardWillHide(notification: nil)
        }
    }
}

// MARK: Keyboard handli@objc @objc ng

fileprivate extension UIViewController {
    func _addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(_keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func _removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func _keyboardWillShow(notification: NSNotification) {
        guard let responder = _firstResponderView(fromView: view),
              let originY = responder.superview?.convert(responder.frame.origin, to: nil).y,
              let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(_tapped(_:))))

        let responderHeight = (UIApplication.shared.keyWindow?.bounds.size.height ?? 0) - (originY + responder.bounds.size.height)

        let offset = responderHeight - (keyboardSize.height + 10)

        guard offset < 0 else { return }

        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.view.frame.origin.y = offset
        }
    }

    @objc func _tapped(_ sender: UIGestureRecognizer) {
        view.removeGestureRecognizer(sender)
        view.endEditing(true)
    }

    @objc func _keyboardWillHide(notification: NSNotification?) {
        guard view.frame.origin.y != 0 else { return }
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.view.frame.origin.y = 0
        }
    }

    func _firstResponderView(fromView view: UIView) -> UIView? {
        let responder = view.subviews.filter { $0.isFirstResponder }.first
        guard let responderView = responder else {
            for subView in view.subviews {
                guard let subResponder = _firstResponderView(fromView: subView) else { continue }
                return subResponder
            }
            return nil
        }

        return responderView
    }
}
/*
public extension UIViewController {
    
    var leftBarButtonItemCenterInWindow: CGPoint {
        (navigationItem.leftBarButtonItem?.value(forKey: "view") as? UIView)?.centerInWindow ?? .zero
    }
    
    var rightBarButtonItemCenterInWindow: CGPoint {
        (navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView)?.centerInWindow ?? .zero
    }
    
}
*/
