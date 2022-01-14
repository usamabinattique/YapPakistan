//
//  Y2YContactCell.swift
//  YAP
//
//  Created by Zain on 17/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import YAPComponents
import RxSwift
import RxTheme

class Y2YContactCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var name = UIFactory.makeLabel(font: .small)
    
    private lazy var phoneNumber = UIFactory.makeLabel(font: .micro)
    
    private lazy var nameStack = UIFactory.makeStackView(axis: .vertical, alignment: .leading, distribution: .fill, spacing: 4, arrangedSubviews: [name, phoneNumber])
    
    private lazy var badgeStack = UIFactory.makeStackView(axis: .horizontal, alignment: .center, distribution: .fill, spacing: 0, arrangedSubviews: [primaryBadge, goldBadge, blackBadge])
    
    private lazy var primaryBadge = UIFactory.makeImageView(contentMode: .scaleAspectFill)
    private lazy var goldBadge = UIFactory.makeImageView(contentMode: .scaleAspectFill)
    private lazy var blackBadge = UIFactory.makeImageView(contentMode: .scaleAspectFill)
    
    private lazy var inviteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("screen_y2y_display_button_invite".localized, for: .normal)
        button.titleLabel?.font = .small
        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: Properties
    
    var viewModel: Y2YContactCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
        
        setupViews()
        setupConstraints()
    }
    
    // MARK: View cycle
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        render()
    }
    
    // MARK: Configurations
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? Y2YContactCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
        setupTheme()
        setupResources()
    }
    
}

// MARK: View setup

private extension Y2YContactCell {
    func setupViews() {
        contentView.addSubview(userImage)
        contentView.addSubview(nameStack)
        contentView.addSubview(badgeStack)
        contentView.addSubview(inviteButton)
    }
    
    func setupConstraints() {
        userImage
            .alignEdgesWithSuperview([.top, .left, .bottom], constants: [10, 25, 10])
            .height(constant: 42)
            .width(constant: 42)
        
        nameStack
            .toRightOf(userImage, constant: 15)
            .alignEdge(.centerY, withView: userImage)
        
        badgeStack
            .alignEdgeWithSuperview(.right, constant: 25)
            .centerVerticallyInSuperview()
        
        primaryBadge
            .height(constant: 24)
            .width(constant: 24)
        
        goldBadge
            .height(with: .height, ofView: primaryBadge)
            .width(with: .width, ofView: primaryBadge)
        
        blackBadge
            .height(with: .height, ofView: primaryBadge)
            .width(with: .width, ofView: primaryBadge)
        
        inviteButton
            .alignEdgeWithSuperview(.right, constant: 25)
            .centerVerticallyInSuperview()
            .toRightOf(name, constant: 10)
            .width(constant: 40)
    }
    
    func render() {
        userImage.roundView()
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [name.rx.textColor])
            .bind({ UIColor($0.grey) }, to: [phoneNumber.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [inviteButton.rx.titleColor(for: .normal)])
            .disposed(by: rx.disposeBag)
    }
    
    func setupResources() {
        primaryBadge.image = UIImage(named: "icon_primary_badge", in: .yapPakistan)
        goldBadge.image = UIImage(named: "icon_gold_badge", in: .yapPakistan)
        blackBadge.image = UIImage(named: "icon_black_badge", in: .yapPakistan)
    }
}

// MARK: Binding

private extension Y2YContactCell {
    func bindViews() {
        let thumbnail = viewModel.outputs.thumbnail(forIndexPath: indexPath)
        userImage.loadImage(with: thumbnail.0, placeholder: thumbnail.1)
        
        viewModel.outputs.name.bind(to: name.rx.text).disposed(by: disposeBag)
        viewModel.outputs.phoneNubmer.bind(to: phoneNumber.rx.text).disposed(by: disposeBag)
        viewModel.outputs.isYapUser.bind(to: inviteButton.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.isYapUser.map { !$0 }.bind(to: badgeStack.rx.isHidden).disposed(by: disposeBag)
        
        inviteButton.rx.tap.bind(to: viewModel.inputs.inviteObserver).disposed(by: disposeBag)
        
        let badgeCount = viewModel.outputs.badgeCount
        badgeCount.map { $0 <= 0 }.bind(to: primaryBadge.rx.isHidden).disposed(by: disposeBag)
        badgeCount.map { $0 <= 1 }.bind(to: goldBadge.rx.isHidden).disposed(by: disposeBag)
        badgeCount.map { $0 <= 2 }.bind(to: blackBadge.rx.isHidden).disposed(by: disposeBag)
        
        viewModel.outputs.shimmering.bind(to: name.rx.isShimmerOn).disposed(by: disposeBag)
        viewModel.outputs.shimmering.bind(to: phoneNumber.rx.isShimmerOn).disposed(by: disposeBag)
        viewModel.outputs.shimmering.bind(to: userImage.rx.isShimmerOn).disposed(by: disposeBag)
        viewModel.outputs.shimmering.subscribe(onNext: { [weak self] (value) in
            if value {
                self?.primaryBadge.isHidden = true
                self?.goldBadge.isHidden = true
                self?.blackBadge.isHidden = true
                self?.inviteButton.isHidden = true
            }
        }).disposed(by: disposeBag)
    }
}
