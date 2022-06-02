//
//  YAPToast.swift
//  YAPKit
//
//  Created by Zain on 31/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import YAPComponents
import UIKit

public class YAPToast: NSObject {
    
    private static var currentToast: YAPToast?
    
    private lazy var toast: Label = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping) //.white
    
    private var window: UIWindow?
    
    private override init() {
        super.init()
        toast.textColor = .white
    }
    
    private func show(_ text: String, duration: TimeInterval = 2.5, animated: Bool) {
        YAPToast.currentToast = self
        toast.text = text
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        toast.alpha = 0
        
        let screenBounds = UIScreen.main.bounds
        var textSize = toast.textSize(constrainedToWidth: screenBounds.width - 80)
        textSize.width = textSize.width + 30
        textSize.height = textSize.height + 20
        
        toast.frame = CGRect(x: 0, y: 0, width: textSize.width, height: textSize.height)
        toast.layer.cornerRadius = toast.frame.height/2
        toast.clipsToBounds = true
        
        window = UIWindow(frame: CGRect(x: (screenBounds.width - textSize.width)/2, y: screenBounds.height - textSize.height - 50 - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0), width: textSize.width, height: textSize.height))
        window?.backgroundColor = .clear
        window?.windowLevel = .statusBar + 0xdeadbeef
        window?.addSubview(toast)
        window?.isHidden = false
        
        UIView.animate(withDuration: 0.5) {
            self.toast.alpha = 1
        }
        
        showWithAnimation()
        hideWithAnimation(duration)
    }
    
    public static func show(_ text: String, duration: TimeInterval = 2.5) {
        YAPToast.currentToast?.hideWithoutAnimation()
        YAPToast().show(text, duration: duration, animated: YAPToast.currentToast == nil)
    }
}

// MARK: Private functions

private extension YAPToast {
    func showWithAnimation() {
        UIView.animate(withDuration: 0.5) {
            self.toast.alpha = 1
        }
    }
    
    func hideWithAnimation(_ duration: TimeInterval) {
        UIView.animate(withDuration: 0.5, delay: duration, animations: {
            self.toast.alpha = 0
        }) { (completed) in
            guard completed else { return }
            self.toast.removeFromSuperview()
            self.window = nil
            YAPToast.currentToast = nil
        }
    }
    
    func showWithoutAnimation() {
        self.toast.alpha = 1
    }
    
    func hideWithoutAnimation() {
        self.toast.removeFromSuperview()
        self.window = nil
    }
}
