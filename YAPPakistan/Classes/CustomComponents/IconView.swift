//
//  IconView.swift
//  YAPHousehold
//
//  Created by Janbaz Ali on 24/02/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import UIKit

public class IconView: UIView {
    // MARK: Views

    public lazy var imageView: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.contentMode = .scaleAspectFit
        imageview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageview.tintColor = UIColor.darkGray //.initials
        return imageview
    }()
    
    // MARK: Parameters

    public var biggerIcon: Bool = false
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        layoutIfNeeded()
        translatesAutoresizingMaskIntoConstraints = false
        setupViews()
    }
    
    override public func layoutSubviews() {
        setupConstraints()
        backgroundColor = .white
        layer.cornerRadius = bounds.height / 2
        clipsToBounds = true
    }
}

// MARK: View setup

private extension IconView {
    func setupViews() {
        addSubview(imageView)
    }
    
    func setupConstraints() {
        if biggerIcon {
            imageView
                .alignAllEdgesWithSuperview()
        } else {
            imageView
                .height(constant: bounds.height * 0.50)
                .width(constant: bounds.width * 0.50)
                .centerInSuperView()
        }
    }
}
