//
//  SecureByYapView.swift
//  YAPPakistan
//
//  Created by Yasir on 09/02/2022.
//

import UIKit
import YAPCore
import YAPComponents
import RxTheme

public class SecureByYAPView: UIView {
    
    private lazy var imageView: UIImageView = UIFactory.makeImageView( contentMode: .scaleAspectFit)
    lazy var textLable: UILabel = UIFactory.makeLabel(font: .micro) 
    
    private lazy var stackView: UIStackView = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 9, arrangedSubviews: [imageView, textLable])
    
    
    // MARK: - Init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    internal func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "icon_secure", in: .yapPakistan)
        textLable.text = "screen_topup_secure_title".localized
        setupViews()
        setupConstraints()
    }
    
    fileprivate func setupViews() {
        addSubview(stackView)
    }
    
    fileprivate func setupConstraints() {
        
        stackView
            .alignAllEdgesWithSuperview()
        
        imageView
            .width(with: .height, ofView: imageView)
            .height(constant: 16)
//            .width(constant: 20)
    }
    
}
