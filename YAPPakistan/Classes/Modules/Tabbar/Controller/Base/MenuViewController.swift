//
//  MenuViewController.swift
//  YAPKit
//
//  Created by Zain on 20/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit

/// Class to handle side menu
/// Currently only right side menu is supported
open class MenuViewController: UITabBarController {

    /// Menu width will be ViewController's width mutiplied by this multipler. It should be between 0 to 1.
    public var menuWidth: CGFloat = 0.8 {
        didSet {
            self.menuView.widthMultiplier = menuWidth
        }
    }
    
    /// Specifies alpha of background layout.
    public var blurConstant: CGFloat = 0.5
    
    /// View controller to hold content of menu.
    public var menu: UIViewController? = nil {
        didSet {
            menuView.container = menu?.view
            addGestures()
        }
    }
    
    private var newWindow: UIWindow {
        let viewController = StatusBarHidingViewController()
        viewController.view.backgroundColor = .clear
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.backgroundColor = .clear
        window.windowLevel = .alert
        
        if #available(iOS 13, *) {
            window.windowScene = UIApplication.shared.keyWindow?.windowScene
        }
        
        viewController.view.addSubview(blurView)
        viewController.view.addSubview(menuView)
        menuView.updateViewConstraints()
        
        return window
    }
    
    private var menuWindow: UIWindow?
    
    public var isMenuEnabled: Bool = true
    
    private var panEnabled: Bool = true
    
    private lazy var menuView: MenuView = {
        return MenuView()
    }()
    
    private lazy var blurView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setupContraints()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideMenu()
    }
    private var changeCount = 0
    private let changeFilter = 7
}

// MARK: View setup

private extension MenuViewController {
    func setupContraints() {
        blurView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
}

// MARK: Gesture handling

private extension MenuViewController {
    func addGestures() {
        let rightEdgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleScreenEdgePan(_:)))
        rightEdgePan.edges = .right
        view.addGestureRecognizer(rightEdgePan)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideMenu))
        blurView.addGestureRecognizer(tap)
        
        let menuPan = UIPanGestureRecognizer(target: self, action: #selector(handleMenuPan(_:)))
        menuView.addGestureRecognizer(menuPan)
        
        menuView.initialX = view.bounds.width
        menuView.finalX = view.bounds.width * (1 - menuWidth)
    }
    
    @objc
    func handleScreenEdgePan(_ recognizer: UIPanGestureRecognizer) {
        guard panEnabled && isMenuEnabled else { return }
        
        switch recognizer.state {
        case .began:
            break
            //panBegan()
        case .changed:
            changeCount += 1
            guard changeCount >= changeFilter else { return }
            if changeCount == changeFilter { panBegan() }
            else { panChanged(toPosition: recognizer.translation(in: view).x) }
        case .ended:
            if changeCount >= changeFilter { panEnded(withVelocity: recognizer.velocity(in: view).x) }
            changeCount = 0
        case .cancelled, .failed:
            changeCount = 0
        default:
            break
        }
    }
    
    @objc
    func handleMenuPan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            menuPanChanged(toPoint: recognizer.translation(in: menuView).x)
        case .ended:
            panEnded(withVelocity: recognizer.velocity(in: menuView).x)
        default:
            break
        }
    }
    
    func panBegan() {
        menuWindow = newWindow
        menuWindow?.makeKeyAndVisible()
    }
    
    func panChanged(toPosition position: CGFloat) {
        guard abs(position) < menuView.bounds.size.width else { return }
        menuView.frame.origin.x = view.bounds.width - abs(position)
        guard position < 0 else { return }
        blurView.alpha = ((menuView.initialX - menuView.frame.origin.x)/menuView.bounds.width) * blurConstant
    }
    
    func menuPanChanged(toPoint point: CGFloat) {
        let originX = menuView.finalX + point
        guard originX <= menuView.initialX && originX >= menuView.finalX else { return }
        menuView.frame.origin.x = originX
        blurView.alpha = ((menuView.initialX - menuView.frame.origin.x)/menuView.bounds.width) * blurConstant
    }
    
    func panEnded(withVelocity velocity: CGFloat) {
        if menuView.frame.origin.x < (menuView.initialX - menuView.finalX)/2 + menuView.finalX {
            if velocity < 900 {
                completeShow(abs(velocity))
            } else {
                completeHide(abs(velocity))
            }
        } else {
            if velocity > -900 {
                completeHide(abs(velocity))
            } else {
                completeShow(abs(velocity))
            }
        }
    }
}

// MARK: Animations

private extension MenuViewController {
    func completeShow(_ velocity: CGFloat) {
        let distance = menuView.frame.origin.x - menuView.finalX
        
        var time: TimeInterval = velocity > 0 ? TimeInterval(distance/velocity) : 0.25
        time = time > 0.25 ? 0.25 : time
        
        UIView.animate(withDuration: time, animations: { [unowned self] in
            self.menuView.frame.origin.x = self.menuView.finalX
            self.blurView.alpha = self.blurConstant
        }) { [unowned self] (_) in
            self.panEnabled = false
        }
    }
    
    func completeHide(_ velocity: CGFloat, completionHandler: @escaping () -> Void) {
        let distance = menuView.initialX - menuView.frame.origin.x
        
        var time: TimeInterval = velocity > 0 ? TimeInterval(distance/velocity) : 0.25
        time = time > 0.25 ? 0.25 : time
        
        UIView.animate(withDuration: time, animations: { [unowned self] in
            self.menuView.frame.origin.x = self.menuView.initialX
            self.blurView.alpha = 0
        }) { [weak self] (_) in
            guard let `self` = self else { return }
            self.panEnabled = true
            self.menuWindow?.resignKey()
            self.menuWindow = nil
            completionHandler()
        }
    }
    
    func completeHide(_ velocity: CGFloat) {
        completeHide(velocity) { }
    }
}

// MARK: Menu handling

public extension MenuViewController {
    func showMenu() {
        panEnabled = true
        panBegan()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.completeShow(0)
        }
        
    }
    
    @objc
    func hideMenu() {
        completeHide(0)
    }
    
    func hideMenuWithCompletion(_ completionHandler: @escaping () -> Void) {
        completeHide(0, completionHandler: completionHandler)
    }
}

fileprivate class StatusBarHidingViewController: UIViewController {
    override var prefersStatusBarHidden: Bool { true }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .fade }
}
