//
//  BadgedBarButtonItem.swift
//  YAPKit
//
//  Created by Ahmer Hassan on 20/10/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation
import UIKit

public class BadgedButtonItem: UIBarButtonItem {

    public func setBadge(with value: String) {
        self.badgeValue = value
    }

    private var badgeValue: String? {
        didSet {
            if let value = Int(badgeValue ?? "0"),
                value > 0 {
                lblBadge.isHidden = false
                lblBadge.text = "\(value)"
            } else {
                lblBadge.isHidden = true
            }
        }
    }

    public var tapAction: (() -> Void)?

    private let filterBtn = UIButton()
    private let lblBadge = UILabel()

    override init() {
        super.init()
        setup()
    }

    public init(with image: UIImage?) {
        super.init()
        setup(image: image)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup( image: UIImage? = nil) {

        self.filterBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.filterBtn.adjustsImageWhenHighlighted = false
        self.filterBtn.setImage(image, for: .normal)
        self.filterBtn.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)

        self.lblBadge.frame = CGRect(x: 15, y: 0, width: 15, height: 15)
        self.lblBadge.backgroundColor = UIColor(hexString: "F44774")//.secondaryMagenta
        self.lblBadge.clipsToBounds = true
        self.lblBadge.layer.cornerRadius = 7
        self.lblBadge.textColor = UIColor.white
        self.lblBadge.font = UIFont.systemFont(ofSize: 10)
        self.lblBadge.textAlignment = .center
        self.lblBadge.isHidden = true
        self.lblBadge.minimumScaleFactor = 0.1
        self.lblBadge.adjustsFontSizeToFitWidth = true
        self.filterBtn.addSubview(lblBadge)
        self.customView = filterBtn
    }

    @objc func buttonPressed() {
        if let action = tapAction {
            action()
        }
    }

}
