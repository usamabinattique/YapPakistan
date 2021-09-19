//
//  InitialsImageView.swift
//  YAP
//
//  Created by Muhammad Hassan on 05/10/2018.
//  Copyright © 2018 YAP. All rights reserved.
//

import UIKit
import YAPComponents

public class InitialsImageView: UIView {

    // MARK: Views

    fileprivate lazy var initialsLabel = UIFactory.makeLabel(font: .title2)

    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var addButtonContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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

    func commonInit() {
        setupViews()
        setupConstraints()
    }

    // MARK: Lifecycle

    public override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = bounds.width / 2.0
    }

    // MARK: View Setup

    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(initialsLabel)
        addSubview(imageView)
        addSubview(addButtonContainer)
        addButtonContainer.addSubview(addButton)
    }

    private func setupConstraints() {
        initialsLabel.centerInSuperView()
        imageView.centerInSuperView()

        addButtonContainer
            .width(constant: 32)
            .height(constant: 32)

        addButton
            .centerInSuperView()
    }

    // MARK: Public

    public func setImage(_ image: UIImage?) {
        imageView.isHidden = false
        imageView.image = image
        initialsLabel.isHidden = true
    }

    public func setPhotoURL(_ url: URL?) {
        imageView.isHidden = false
        imageView.sd_setImage(with: url)
        initialsLabel.isHidden = true
    }

    public func setLabelFont(_ font: UIFont) {
        initialsLabel.font = font
    }

    public func setLabelColor(_ color: UIColor?) {
        initialsLabel.textColor = color
    }

    public func setInitials(_ initials: String) {
        imageView.isHidden = imageView.image == nil
        initialsLabel.isHidden = imageView.image != nil

        let parts = initials.uppercased().split(separator: " ")
        if parts.count > 1 {
            let firstPart = parts[0]
            let secondPart = parts[1]
            if let first = firstPart.first {
             initialsLabel.text = "\(first)"
            }
            if let second = secondPart.first {
                initialsLabel.text = "\(initialsLabel.text ?? "")\(second)"
            }
        } else if parts.count > 0 {
            let firstPart = parts[0]
            if let first = firstPart.first {
                initialsLabel.text = "\(first)"
            }
        }
    }
}
