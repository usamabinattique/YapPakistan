//
//  AppSearchTextField.swift
//  YAPKit
//
//  Created by Zain on 22/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

// swiftlint:disable line_length

import Foundation

public class AppSearchTextField: UITextField {

    public lazy var searchIconView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.init(named: "icon_search", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        image.contentMode = .center
        // image.tintColor = .greyDark
        return image
    }()

    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        leftView = searchIconView
        leftViewMode = .always
    }
}

// MARK: Drawing

extension AppSearchTextField {
    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return isFirstResponder ? rect(forBounds: bounds) : CGRect(x: bounds.size.width / 2 - (((placeholder as NSString?)?.size(withAttributes: [.font: font ?? .small]).width ?? 0)/2), y: 0, width: bounds.width, height: bounds.height)
    }
    
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return rect(forBounds: bounds)
    }
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return rect(forBounds: bounds)
    }
    
    private func rect(forBounds bounds: CGRect) -> CGRect {
        var rect = bounds
        rect.origin.x += bounds.height
        rect.size.width -= 1.5 * bounds.height
        return rect
    }
    
    public override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let x = isFirstResponder || text?.count ?? 0 > 0 ? 0 : bounds.size.width/2 - (((placeholder as NSString?)?.size(withAttributes: [.font: font ?? .small]).width ?? 0)/2) - bounds.height
        
        return CGRect(x: x, y: 0, width: bounds.height, height: bounds.height)
    }
}
