//
//  InitialsImageView.swift
//  YAP
//
//  Created by Muhammad Hassan on 05/10/2018.
//  Copyright © 2018 YAP. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit
import YAPComponents

public class InitialsImageView: UIView {

    // MARK: Views

    private lazy var backgroundView: UIView = UIView()

    fileprivate lazy var initialsLabel = UIFactory.makeLabel(textStyle: .title2)

    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var addButtonContainer: UIView = UIView()

    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    internal func commonInit() {
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Lifecycle

    override public func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = bounds.width / 2.0
    }
    
    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(backgroundView)
        addSubview(initialsLabel)
        addSubview(imageView)
        addSubview(addButtonContainer)
        addButtonContainer.addSubview(addButton)
    }
    
    private func setupConstraints() {
        backgroundView.alignAllEdgesWithSuperview()
        initialsLabel.centerInSuperView()
        imageView.centerInSuperView()

        addButtonContainer
            .width(constant: 32)
            .height(constant: 32)

        addButton
            .centerInSuperView()
            .pinEdge(.centerX, toEdge: .right, ofView: addButtonContainer, constant: 0)
            .pinEdge(.centerY, toEdge: .bottom, ofView: addButtonContainer, constant: 0)
    }
}

// MARK: Rx

extension Reactive where Base: InitialsImageView {
    var image: Binder<UIImage> {
        return Binder(self.base) { initialsImageView, image in
            initialsImageView.imageView.isHidden = false
            initialsImageView.imageView.image = image
            initialsImageView.initialsLabel.isHidden = true
        }
    }

    var photoUrl: Binder<URL?> {
        return Binder(self.base) { initialsImageView, url in
            initialsImageView.imageView.isHidden = false
            initialsImageView.imageView.sd_setImage(with: url)
            initialsImageView.initialsLabel.isHidden = true
        }
    }

    var initials: Binder<String> {
        return Binder(self.base) { initialsImageView, initials in
            initialsImageView.imageView.isHidden = initialsImageView.imageView.image == nil
            initialsImageView.initialsLabel.isHidden = initialsImageView.imageView.image != nil
            let parts = initials.uppercased().split(separator: " ")
            if parts.count > 1 {
                let firstPart = parts[0]
                let secondPart = parts[1]
                if let first = firstPart.first {
                 initialsImageView.initialsLabel.text = "\(first)"
                }
                if let second = secondPart.first {
                    initialsImageView.initialsLabel.text = "\(initialsImageView.initialsLabel.text ?? "")\(second)"
                }
            } else if parts.count > 0 {
                let firstPart = parts[0]
                if let first = firstPart.first {
                    initialsImageView.initialsLabel.text = "\(first)"
                }
            }
        }
    }
}
