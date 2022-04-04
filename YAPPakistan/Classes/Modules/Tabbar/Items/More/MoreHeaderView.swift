//
//  MoreHeaderView.swift
//  YAP
//
//  Created by Zain on 19/09/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme

class MoreHeaderView: UIView {
    
    // MARK: Views
    
    private lazy var profileImageView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    fileprivate lazy var nameLabel: UILabel = UIFactory.makeLabel(font: .large, alignment: .center) //.primaryDark
    
    fileprivate lazy var ibanLabel: UILabel = UIFactory.makeLabel(font: .micro, alignment: .center) //.greyDark
    fileprivate lazy var bicLabel: UILabel = UIFactory.makeLabel(font: .micro, alignment: .center) //.greyDark
    
    fileprivate lazy var accountNumberLabel = UIFactory.makeLabel(font: .micro, alignment: .center) //.white
    
    private lazy var accountStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 3, arrangedSubviews: [ibanLabel, bicLabel, accountNumberLabel])
    
    
    public lazy var bankDetailsButton = AppRoundedButtonFactory.createAppRoundedButton(title: "screen_more_home_display_text_your_bank_details".localized)
    
    private lazy var bankDetailsStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 8, arrangedSubviews: [accountStack, bankDetailsButton])
    
    
    fileprivate lazy var stackView: UIStackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .fill, distribution: .fillProportionally, spacing: 4)
    
    // MARK: Properties
    fileprivate let imageTappedSubject = PublishSubject<Void>()
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    
    public init(theme: ThemeService<AppTheme>) {
        super.init(frame: CGRect.zero)
        self.themeService = theme
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        clipsToBounds = false
        setupSubViews()
        setupTheme()
        setupConstraints()
        setupSensitiveViews()
    }
    
    // MARK: Drawing
    
    override func draw(_ rect: CGRect) {
        render()
    }
    
    func setupSensitiveViews() {
//        UIView.markSensitiveViews([nameLabel, ibanLabel, accountNumberLabel, profileImageView, bicLabel])
    }
    
    // MARK: Actions
    
    @objc
    func imageTapped() {
        imageTappedSubject.onNext(())
    }
}

extension MoreHeaderView: ViewDesignable {
    func setupSubViews() {
        addSubview(profileImageView)
        profileImageView.addSubview(profileImage)
        addSubview(nameLabel)
        bankDetailsButton.titleLabel?.font = .small
        addSubview(bankDetailsStack)
    }
    
    func setupBindings() { }
    
    func setupTheme() {
        self.themeService.rx
            .bind( { UIColor($0.primary) }, to: nameLabel.rx.textColor)
            .bind( { UIColor($0.greyDark) }, to: ibanLabel.rx.textColor)
            .bind( { UIColor($0.greyDark) }, to: bicLabel.rx.textColor)
            .bind( { UIColor($0.backgroundColor) }, to: accountNumberLabel.rx.textColor)
            .bind( { UIColor($0.primary) }, to: bankDetailsButton.rx.enabledBackgroundColor)
            .disposed(by: rx.disposeBag)
    }
    
    func setupConstraints() {
        
        profileImageView
            .centerHorizontallyInSuperview()
            .width(constant: 75)
            .height(constant: 75)
            .alignEdgeWithSuperview(.top, constant: 20)
        
        profileImage
            .centerInSuperView()
            .alignEdgesWithSuperview([.left, .top], constants: [5, 5])
        
        nameLabel
            .toBottomOf(profileImage, constant: 19)
            .centerHorizontallyInSuperview()
            .alignEdgesWithSuperview([.left, .right], constant: 20)
        
        bankDetailsStack
            .toBottomOf(nameLabel, constant: 8)
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.left, constant: 25)
            .alignEdgeWithSuperview(.bottom, constant: 15)
        
        bankDetailsButton
            .height(constant: 24)
            .width(constant: 152)
        
    }
    
    func render() {
        profileImageView.roundView()
        profileImage.roundView()
    }
}

// MARK: Reactive

extension Reactive where Base: MoreHeaderView {
    var profileImage: Binder<(String?, UIImage?)> {
        return self.base.profileImage.rx.loadImage()
    }
    
    var name: Binder<String?> {
        return self.base.nameLabel.rx.text
    }
    
    var iban: Binder<NSAttributedString?> {
        return self.base.ibanLabel.rx.attributedText
    }
    
    var bic: Binder<NSAttributedString?> {
        return self.base.bicLabel.rx.attributedText
    }
    
    var accountNumber: Binder<String?> {
        return self.base.accountNumberLabel.rx.text
    }
    
    var bankDetailsTap: ControlEvent<Void> {
        return self.base.bankDetailsButton.rx.tap
    }
    
    var imageTapped: Observable<Void> {
        return self.base.imageTappedSubject.asObservable()
    }
}
