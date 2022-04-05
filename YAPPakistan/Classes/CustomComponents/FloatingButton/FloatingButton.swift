//
//  FloatingButton.swift
//  YAPPakistan
//
//  Created by Yasir on 04/04/2022.
//

import Foundation
import RxSwift
import UIKit
import RxCocoa
import YAPComponents

public class FloatingButton: NSObject {
    private static var currentButton: FloatingButton?
    
    private lazy var badge: PaddedLabel = UIFactory.makePaddingLabel(font: .regular, alignment: .center, numberOfLines: 1, lineBreakMode: .byWordWrapping) //UILabelFactory.createUILabel(with: .white, textStyle: .regular, alignment: .center, numberOfLines: 1, lineBreakMode: .byWordWrapping)

    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var imageView: UIImageView = UIFactory.makeImageView(image: UIImage.init(named: "icon_floating_chat", in: .yapPakistan)) //UIImageViewFactory.createImageView(mode: .scaleAspectFit, image: UIImage.init(named: "icon_floating_chat", in: yapKitBundle, compatibleWith: nil))
    
    //MARK: - Properties
    private var window: UIWindow?
    private var windowSize : CGFloat = 80
    fileprivate var tappSubject = PublishSubject<Void>()
    lazy var  badgeView: Badge =  Badge(view: imageView)
    
    //MARK: - Init
    public override init() {
        super.init()
        setup()
    }
    
    private func setup() {
        badge.backgroundColor = UIColor(red: 227/255, green: 86/255, blue: 117/255, alpha: 1.0)
        containerView.addSubview(imageView)
        setupViews()
        let badgeView =  Badge(view: imageView)
        badgeView.setCount(99)
        
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    @objc
    func tapped() {
        tappSubject.onNext(())
      //  sendActions(for: .valueChanged)
    }
    private func render(){
        badge.layer.cornerRadius = badge.frame.height/2
        badge.clipsToBounds = true
        badge.layer.borderWidth = 2
        badge.layer.borderColor = UIColor.white.cgColor
    }
    
    private func setupViews(){
        containerView.frame = CGRect(x: 0, y: 0, width: windowSize, height: windowSize)

        imageView.bounds.size.width = windowSize - 10
        imageView.bounds.size.height = windowSize - 10
        imageView.center = containerView.center
        
        badge.text = "99"
        var textSize = badge.textSize(constrainedToWidth: 30)
        textSize.width = textSize.width + 8
       // textSize.height = textSize.height
        
        badge.bounds.size = textSize
        badge.center = CGPoint(x: imageView.frame.maxX - badge.bounds.height/2 - 3 , y: imageView.frame.minY + badge.bounds.height/2 + 1)
    }
    
    
    private func showButton(bottomSpacing: CGFloat) {
        FloatingButton.currentButton = self
        
        let screenBounds = UIScreen.main.bounds
        let screenWidth = screenBounds.width
        let screenHeight = screenBounds.height
        
        window = UIWindow(frame: CGRect(x: screenWidth - windowSize - 20, y: screenHeight - windowSize - bottomSpacing, width: windowSize, height: 50))
        window?.backgroundColor = .clear
        window?.windowLevel = .normal + 1
        window?.addSubview(containerView)
        window?.isHidden = false
        
        render()
    }
    
    public func show(bottomSpacing: CGFloat = 65) {
        FloatingButton.currentButton?.hide()
        showButton(bottomSpacing: bottomSpacing)
       // FloatingButton().showButton()
    }
}
// MARK: Private functions

public extension FloatingButton {
    func hide() {
        self.containerView.removeFromSuperview()
        self.window = nil
    }
}

public extension Reactive where Base: FloatingButton {
    
    var tap: Observable<Void> {
        return self.base.tappSubject.asObservable()
    }
    
    var count: Binder<Int> {
        return Binder(self.base) { floatingButton, badgeCount -> Void in
            floatingButton.badgeView.setCount(badgeCount)
        }
    }

}
