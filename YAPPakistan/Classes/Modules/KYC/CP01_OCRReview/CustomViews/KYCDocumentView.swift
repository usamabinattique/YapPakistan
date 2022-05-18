//
//  KYCDocumentView.swift
//  YAPKit
//
//  Created by Zain on 06/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import YAPComponents

public class KYCDocumentView: UIView {

    private lazy var iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 21
        imageView.tintColor = UIColor(hexString: "5E35B1")
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var validationImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.setAttributedTitle(self.attributedString("common_button_edit".localized ), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var rightView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    private lazy var horizontalStack: UIStackView = UIFactory.makeStackView(
        axis: .horizontal, alignment: .center, distribution: .fill, spacing: 15)

    private lazy var mainStack: UIStackView = UIFactory.makeStackView(
        axis: .vertical, spacing: 20)

    private lazy var topStack: UIStackView = UIFactory.makeStackView(
        axis: .vertical, spacing: 5)

    private lazy var bottomStack: UIStackView = UIFactory.makeStackView(
        axis: .vertical, spacing: 5)

    private lazy var titleLabel: UILabel = UIFactory.makeLabel(
        font: .large, alignment: .left, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var detailsLabel: UILabel = UIFactory.makeLabel(
        font: .small, alignment: .left, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var subTitleLabel: UILabel = UIFactory.makeLabel(
        font: .small, alignment: .left, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var subDetailsLabel: UILabel = UIFactory.makeLabel(
        font: .large, alignment: .left, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    fileprivate let tapSubject = PublishSubject<Void>()

    // MARK: Control properties

    public var iconTintColor: UIColor! {
        get { iconImage.tintColor }
        set { iconImage.tintColor = newValue }
    }

    public var titleColor: UIColor! {
        get { titleLabel.textColor }
        set { titleLabel.textColor = newValue }
    }

    public var detailsColor: UIColor! {
        get { detailsLabel.textColor }
        set { detailsLabel.textColor = newValue }
    }

    public var subTitleColor: UIColor! {
        get { subTitleLabel.textColor }
        set { subTitleLabel.textColor = newValue }
    }

    public var subDetailsColor: UIColor! {
        get { subDetailsLabel.textColor }
        set { subDetailsLabel.textColor = newValue }
    }

    public var viewType: KYCDocumentView.ViewType = .detailsAndSubDetails {
        didSet {
            bottomStack.isHidden = viewType == .detailsOnly
            editButton.isHidden = viewType == .detailsOnly
        }
    }

    public var validation: KYCDocumentView.Validation = .notDetermined {
        didSet {
            validationImage.isHidden = validation == .notDetermined
            rightView.isHidden = validation == .notDetermined
            switch validation {
            case .valid:
                validationImage.image = UIImage(named: "icon_check_mark_clear", in: .yapPakistan, compatibleWith: nil)
            case .invalid:
                validationImage.image = UIImage(named: "icon_invalid_document", in: .yapPakistan, compatibleWith: nil)
            case .notDetermined:
                validationImage.image = nil
            }
        }
    }

    public var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    public var details: String? {
        didSet {
            detailsLabel.text = details
        }
    }

    public var subTitle: String? {
        didSet {
            subTitleLabel.text = subTitle
        }
    }

    public var subDetails: String? {
        didSet {
            subDetailsLabel.text = subDetails
        }
    }

    public var icon: UIImage? {
        didSet {
            iconImage.image = icon
        }
    }

    // MAKR: Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(_tapped(_:))))
        setupViews()
        setupConstraints()
    }
}

// MARK: View setup

private extension KYCDocumentView {
    func setupViews() {
        addSubview(iconImage)
        addSubview(validationImage)
        addSubview(editButton)
        addSubview(horizontalStack)

        horizontalStack.addArrangedSubview(mainStack)
        horizontalStack.addArrangedSubview(rightView)

        mainStack.addArrangedSubview(topStack)
        mainStack.addArrangedSubview(bottomStack)

        topStack.addArrangedSubview(titleLabel)
        topStack.addArrangedSubview(detailsLabel)

        bottomStack.addArrangedSubview(subTitleLabel)
        bottomStack.addArrangedSubview(subDetailsLabel)
    }

    func setupConstraints() {
        iconImage
            .alignEdgeWithSuperview(.left, constant: 20)
            .width(constant: 42)
            .height(constant: 42)
            .centerVerticallyInSuperview()

        validationImage
            .alignEdgeWithSuperview(.right, constant: 20)
            .alignEdge(.centerY, withView: iconImage)
            .width(constant: 32)
            .height(constant: 32)
        
        horizontalStack
            .toRightOf(iconImage, constant: 23)
            .alignEdgesWithSuperview([.right], constants: [20])
            .alignEdgesWithSuperview([.top, .bottom], constants: [33, 33])
            .centerVerticallyInSuperview()

        titleLabel
            .height(constant: 28)
        detailsLabel
            .height(.greaterThanOrEqualTo, constant: 20)
        
        editButton
            .alignEdge(.centerX, withView: validationImage)
            .alignEdge(.centerY, withView: bottomStack)
            .width(constant: 40)
            .height(constant: 25)

        rightView
            .height(with: .height, ofView: validationImage)
            .width(with: .width, ofView: validationImage)
    }
}

// MARK: Drawing

extension KYCDocumentView {
    public override func draw(_ rect: CGRect) {
        layer.cornerRadius = 10
        clipsToBounds = true
    }
}

// MARK: Helper functions

extension KYCDocumentView {
    private func attributedString(_ string: String) -> NSAttributedString? {
        let attribute: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.micro,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let attributedString = NSAttributedString(string: string, attributes: attribute)
        return attributedString
    }

    @objc
    private func _tapped(_ sender: UIGestureRecognizer) {
        tapSubject.onNext(())
    }
}

// MARK: Enums

public extension KYCDocumentView {
    enum ViewType {
        case detailsOnly
        case detailsAndSubDetails
    }

    enum Validation {
        case valid
        case invalid
        case notDetermined
    }
}

// MARK: Reactive

extension Reactive where Base: KYCDocumentView {
    public var viewType: Binder<KYCDocumentView.ViewType> {
        return Binder(self.base) { docView, viewType in
            docView.viewType = viewType
        }
    }

    public var validation: Binder<KYCDocumentView.Validation> {
        return Binder(self.base) { docView, validation in
            docView.validation = validation
        }
    }

    public var title: Binder<String?> {
        return Binder(self.base) { docView, title in
            docView.title = title
        }
    }

    public var titleColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.titleColor = attr
        }
    }

    public var subTitle: Binder<String?> {
        return Binder(self.base) { docView, subTitle in
            docView.subTitle = subTitle
        }
    }

    public var subTitleColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.subTitleColor = attr
        }
    }

    public var details: Binder<String?> {
        return Binder(self.base) { docView, details in
            docView.details = details
        }
    }

    public var detailsColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.detailsColor = attr
        }
    }

    public var subDetails: Binder<String?> {
        return Binder(self.base) { docView, subDetails in
            docView.subDetails = subDetails
        }
    }

    public var subDetailsColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.subDetailsColor = attr
        }
    }

    public var icon: Binder<UIImage?> {
        return Binder(self.base) { docView, icon in
            docView.icon = icon
        }
    }

    public var iconTintColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.iconTintColor = attr
        }
    }

    public var tap: Observable<Void> {
        return self.base.tapSubject.asObservable()
    }
}
