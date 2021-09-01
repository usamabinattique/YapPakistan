//
//  RankAnimation.swift
//  OnBoarding
//
//  Created by Janbaz Ali on 16/04/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation
import UIKit
import YAPComponents

public class RollingAnimationView: UIView {
    private lazy var label: UILabel = UIFactory.makeLabel(textStyle: .title1, alignment: .center, numberOfLines: 1)

    public var labelColor: UIColor! {
        get { label.textColor }
        set { label.textColor = newValue }
    }

    // MARK: Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.9411764706, blue: 0.9725490196, alpha: 1)
        clipsToBounds = true
        layer.cornerRadius = 4

        addSubview(label)
    }

    private func setupConstraints() {
        label
            .alignAllEdgesWithSuperview()
    }

    public func animate(labels: [String], singleAnimationDuration: Double, bounce: Bool) {
        label.animate(atIndex: 0, labels: labels, interval: singleAnimationDuration, bounce: bounce)
    }
}
