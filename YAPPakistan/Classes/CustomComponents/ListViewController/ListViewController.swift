//
//  ListViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 29/03/2022.
//

import Foundation
import UIKit
import YAPCore
import YAPComponents
import RxTheme

open class ListViewController: UIViewController {
    
    // MARK: Properties
    
    private lazy var listContainer: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height * __heightMutiplier)) //UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 14
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dragView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dragButton: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(Color(hex: "#DAE0F0")) //.greyLight
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var titleLabel: UILabel = UIFactory.makeLabel(font: .large, alignment: .left, numberOfLines: 0, lineBreakMode: .byWordWrapping)
    
    lazy var separator: UIView = {
        let view = UIView()
     //   view.backgroundColor = .red//.greyLight
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public lazy var container: UIView = {
        let container = UIView()
        container.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Private properties
    
    private var __started: Bool = false {
        didSet {
            guard oldValue != __started else { return }
            dragButton.backgroundColor = __started ? UIColor(Color(hex: "#9391B1")) : UIColor(Color(hex: "#DAE0F0")) //__started ? UIColor.darkGray : UIColor.lightGray
            dragButton.transform = CGAffineTransform(scaleX: __started ? 1.05 : 1, y: __started ? 1.05 : 1)
        }
    }
    private var __startPointY: CGFloat = 0.0
    var __heightMutiplier: CGFloat = 0.70//0.85
    
    public func setHeightMultiplier(multiplier: CGFloat) {
        self.__heightMutiplier = multiplier
    }
    
    // MARK: Public properties
    
    public var maxAvailableHeight: CGFloat {
        (view.bounds.height * __heightMutiplier) - container.frame.origin.y
    }
    
    public var listTitle: String? {
        didSet {
            titleLabel.text = listTitle
        }
    }
    
    private (set) public var isCompletlyShown: Bool = false
    
    // MARK: View cycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        __addGestureRecognisers()
        __setupViews()
        __setupConstraints()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.layoutSubviews()
        __completeShow()
    }
    
    // MARK: Public functions
    
    public func show(in viewController: UIViewController) {
        let nav = UINavigationControllerFactory.createTransparentNavigationBarNavigationController(rootViewController: self)
        nav.isNavigationBarHidden = true
       // nav.setNavigationBarHidden(true, animated: false)
        nav.modalPresentationStyle = .overCurrentContext
        viewController.present(nav, animated: false, completion: nil)
    }
    
    public func hide() {
        __completeHide()
    }
    
    public func contentHeightChanged() {
        __completeShow()
    }
    
    // MARK: Touch handling
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: listContainer) else { return }
        __started = dragView.frame.contains(location)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        __started = false
    }
    
}

// MARK: Gestures

private extension ListViewController {
    func __addGestureRecognisers() {
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(__completeHide(_:))))
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.cancelsTouchesInView = false
        listContainer.addGestureRecognizer(pan)
    }
    
    @objc
    func handlePan(_ pan: UIPanGestureRecognizer) {
        
        let location = pan.location(in: listContainer)
        guard dragView.frame.contains(location) || __started else { return }
        
        switch pan.state {
        case .began:
            __started = true
            __startPointY = location.y

        case .changed:
            __changePositionY(pan.location(in: view).y - __startPointY)

        case .ended, .cancelled:
            __started = false
            let progress = ((listContainer.frame.origin.y - (view.bounds.height - listContainer.bounds.height)) / listContainer.bounds.height)
            let velocity = pan.velocity(in: view).y
            if progress < 0.25 {
                velocity < 900 ? __completeShow(velocity) : __completeHide(velocity)
            } else {
                velocity > -900 ? __completeHide(velocity) : __completeShow(velocity)
            }

        default:
            break
        }
    }
}

// MARK: View setup

private extension ListViewController {
    
    func __setupViews() {
        view.backgroundColor = .clear
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0)
        view.addSubview(backgroundView)
        view.addSubview(listContainer)
        listContainer.addSubview(dragView)
        dragView.addSubview(dragButton)
        listContainer.addSubview(titleLabel)
        listContainer.addSubview(separator)
        listContainer.addSubview(container)
        
        titleLabel.textColor = UIColor(Color(hex: "#272262"))
    }
    
    func __setupConstraints() {
        
        backgroundView
            .alignAllEdgesWithSuperview()
        
        listContainer
            .toBottomOf(view)
            .alignEdgesWithSuperview([.left, .right])
            //.height(.lessThanOrEqualTo, constant: UIScreen.main.bounds.height*__heightMutiplier)
            .height( constant: UIScreen.main.bounds.height*__heightMutiplier)
        
        dragView
            .alignEdgeWithSuperview(.top)
            .centerHorizontallyInSuperview()
        
        dragButton
            .alignEdgesWithSuperview([.left, .top], constant: 13)
            .height(constant: 4)
            .width(constant: 60)
            .centerHorizontallyInSuperview()
        
        titleLabel
            .alignEdgesWithSuperview([.left, .top, .right], constants: [25, 35, 25])
        
        separator
            .alignEdge(.bottom, withView: dragView)
            .toBottomOf(titleLabel, constant: 18)
            .alignEdgesWithSuperview([.left, .right])
            .height(constant: 1)
        
        container
            .toBottomOf(separator)
            .alignEdgesWithSuperview([.left, .right, .bottom])
    }
}

// MARK: Animations

private extension ListViewController {
    
    func __changePositionY(_ y: CGFloat) {
        guard y >= (view.bounds.height - listContainer.bounds.height) else { return }
        var frame = listContainer.frame
        frame.origin.y = y
        listContainer.frame = frame
        let progress = ((listContainer.frame.origin.y - (view.bounds.height - listContainer.bounds.height)) / listContainer.bounds.height)
        self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5 * (1 - progress))
    }
    
    func __completeShow(_ velocity: CGFloat = 0) {
        guard isViewLoaded else { return }
        
        let distance = listContainer.frame.origin.y - (view.bounds.height - listContainer.bounds.height)
        
        var time: TimeInterval = abs(velocity) > 0 ? TimeInterval(abs(distance)/abs(velocity)) : 0.3
        time = time > 0.3 ? 0.3 : time
        
        UIView.animate(withDuration: time, animations: { [weak self] in
            self?.listContainer.frame.origin.y = (self?.view.bounds.height ?? UIScreen.main.bounds.height) -
                (self?.listContainer.bounds.height ?? 0)
            self?.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self?.view.layoutSubviews()
        }) { [weak self] completed in
            guard completed else { return }
            self?.isCompletlyShown = true
        }
    }
    
    @objc func __completeHide(_ velocity: CGFloat = 0) {
        
        let distance = view.bounds.height - listContainer.frame.origin.y
        
        var time: TimeInterval = abs(velocity) > 0 ? TimeInterval(abs(distance)/abs(velocity)) : 0.3
        time = time > 0.3 ? 0.3 : time
        
        UIView.animate(withDuration: time, animations: { [weak self] in
            self?.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0)
            self?.listContainer.frame.origin.y = self?.view.bounds.height ?? UIScreen.main.bounds.height
        }) { [weak self] completed in
            guard completed else { return }
            self?.navigationController?.dismiss(animated: false, completion: nil)
        }
    }
}
