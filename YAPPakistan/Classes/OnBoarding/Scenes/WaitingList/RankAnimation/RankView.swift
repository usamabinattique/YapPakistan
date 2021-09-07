//
//  RankView.swift
//  OnBoarding
//
//  Created by Janbaz Ali on 18/04/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation
import UIKit
import YAPComponents

public class RankView: UIView {
    private lazy var hStack: UIStackView = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 10)

    public var minimumDigits: Int = 4

    public var minimumBoxWidth: CGFloat = 45.0
    public var maximumBoxWidth: CGFloat = 60.0

    public var boxSpacing: CGFloat {
        get { hStack.spacing }
        set { hStack.spacing = newValue }
    }

    public var digitColor: UIColor! = .black
    public var digitBackgroundColor: UIColor! = .black

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

    public func animate(rank string: String) {
        createViews(string)
    }
}

extension RankView {
    func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        addSubview(hStack)
    }

    func setupConstraints() {
        hStack
            .alignEdgesWithSuperview([.top, .bottom])
            .centerHorizontallyInSuperview()
    }

    func createViews(_ string: String) {
        hStack.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }

        let array = createDigitString(string)
        var delay = 0.0

        let multiplier = (minimumBoxWidth * CGFloat(array.count)) / 375.0
        var boxWidth = (UIScreen.main.bounds.width * multiplier) / CGFloat(array.count)
        boxWidth = min(maximumBoxWidth, boxWidth)

        array.forEach { string in
            let view = RollingAnimationView()
            hStack.addArrangedSubview(view)

            view.labelColor = digitColor
            view.backgroundColor = digitBackgroundColor
            view
                .width(constant: boxWidth)
                .height(with: .height, ofView: hStack)

            let duration = 0.1
            let labels = createLabels(string)

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                view.animate(labels: labels, singleAnimationDuration: duration, bounce: true )
            }

            delay += (duration * Double(labels.count / 5))
        }
    }
}

extension RankView {
    func createDigitString(_ string: String) -> [String] {
        if string.count >= minimumDigits {
            return string.map { String($0) }
        }

        return createDigitString("0" + string)
    }
    
    func createLabels(_ string: String) -> [String] {
        let number = (Int(string) ?? 0) - 1 /// add an extra value for bouncing effect
        var array: [String] = []
        for i in number...9 {
            array.insert(String(i >= 0 ? i : 9), at: 0)
        }
        array.insert("0", at: 0)

        return array
    }
}
