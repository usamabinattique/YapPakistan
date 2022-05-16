//
//  BarGraphCollectionViewCell.swift
//  YAPPakistan
//
//  Created by Yasir on 16/05/2022.
//

import UIKit

class BarGraphCollectionViewCell: RxUICollectionViewCell {
    
    // MARK: - Views
    lazy var barView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var barViewHeightConstraint: NSLayoutConstraint = {
        let constraint = barView.heightAnchor.constraint(equalToConstant: 0)
        return constraint
    }()
    
    lazy var selectedBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        self.contentView.addSubview(barView)
        barViewHeightConstraint.isActive = true
        barView.alignEdgesWithSuperview([.left, .bottom, .right])
        barView.addSubview(selectedBarView)
        barView.roundCorners(corners: [.topLeft, .topRight], radius: 2)
        selectedBarView.alignAllEdgesWithSuperview()
    }
    
    // MARK: - Selection
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 1) { [weak self] in
                self?.selectedBarView.backgroundColor = self!.isSelected ? .blue /*UIColor.appColor(ofType: .primary )*/  : UIColor.clear
            }
        }
    }
    
    func configure(with amountPercentage: Double) {
        barView.removeGradientBackground()
        let barHeight = max(1, CGFloat(amountPercentage) * 70)
        barViewHeightConstraint.constant = barHeight
        layoutIfNeeded()
        barView.setGradientBackground(colors: [#colorLiteral(red: 0.937254902, green: 0.9490196078, blue: 0.9764705882, alpha: 1), #colorLiteral(red: 0.8549019608, green: 0.8784313725, blue: 0.9411764706, alpha: 1)])
    }
}
