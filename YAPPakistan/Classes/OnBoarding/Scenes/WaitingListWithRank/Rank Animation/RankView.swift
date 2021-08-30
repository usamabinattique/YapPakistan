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
    
    private lazy var hStack: UIStackView = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 14)
    
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
        let array = create7digitString(string)
        var delay = 0.0
        hStack.arrangedSubviews.forEach{
            $0.removeFromSuperview()
        }
        
        let minBoxSize = CGFloat(35.0)
        let multiplier = (minBoxSize * CGFloat(array.count)) / 375
        var boxWidth = (UIScreen.main.bounds.width * multiplier) / CGFloat(array.count)
        boxWidth = boxWidth > 50 ? 50 : boxWidth
        
        array.forEach{ string in
            let view = RollingAnimationView()
            view
                .width(constant: boxWidth)
                .height(constant: 58)
            hStack.addArrangedSubview(view)
            let duration = 0.1
            let labels = self.createLabels(string)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {  view.animate(labels: labels, singleAnimationDuration: duration, bounce: true ) }
            delay += (duration * Double(labels.count/5))
        }
    }
}

extension RankView {
    func create7digitString(_ string: String) -> [String] {
        
        if string.count >= 7 {
            return string.map{String($0)}
        }
        return create7digitString("0"+string)
       
    }
    
    func createLabels(_ string: String) -> [String] {
        let number = (Int(string) ?? 0) - 1 /// add an extra value for bouncing effect
        var array = [String]()
        for i in number...9 {
           
            array.insert(String( i >= 0 ? i : 9), at: 0)
        }
        array.insert("0", at: 0)
        return array
    }
}
