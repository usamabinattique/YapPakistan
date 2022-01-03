//
//  MenuView.swift
//  YAPKit
//
//  Created by Zain on 21/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

class MenuView: UIView {
    
    var initialX: CGFloat = 0
    var finalX: CGFloat = 0
    var widthMultiplier: CGFloat = 0.8
    
    var container: UIView? = nil {
        didSet {
            setupConstraints()
        }
    }
    
    func updateViewConstraints() {
        alignEdgesWithSuperview([.top, .bottom])
        alignEdgeWithSuperview(.left, constant: superview?.bounds.width ?? 0)
        width(constant: superview!.bounds.width * widthMultiplier)
    }
    
}

// MARK: View setup

private extension MenuView {
    func setupConstraints() {
        guard let container = container else { return }
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        container.alignAllEdgesWithSuperview()
    }
}
