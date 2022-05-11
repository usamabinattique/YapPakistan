//
//  HelpAndSupportTableViewCell.swift
//  YAPPakistan
//
//  Created by Awais on 11/05/2022.
//

import UIKit
import YAPComponents
import RxSwift
import RxTheme
import RxCocoa

class HelpAndSupportTableViewCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center //SessionManager.current.currentAccountType == .b2cAccount ? UIColor.primary.withAlphaComponent(0.14) : .primary
        //imageView.tintColor = UIColor(themeService.attrs.primary)  //SessionManager.current.currentAccountType == .b2cAccount ? .primary : .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = UIFactory.makeLabel(font: .small, numberOfLines: 0, lineBreakMode: .byWordWrapping)  //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small, numberOfLines: 0, lineBreakMode: .byWordWrapping)
    
    private lazy var nextImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.sharedImage(named: "icon_forward")?.withRenderingMode(.alwaysTemplate)
        //imageView.tintColor = UIColor(themeService.attrs.primary)  //.primary
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: Properties
    
    private var viewModel: HelpAndSupportTableViewCellViewModelType!
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
    
    // MARK: Layouting
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        icon.roundView()
    }
    
    // MARK: Configuration
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? HelpAndSupportTableViewCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        setupTheme()
        bindViews()
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [titleLabel.rx.tintColor])
            .bind({ UIColor($0.primary) }, to: [icon.rx.backgroundColor, icon.rx.tintColor, nextImage.rx.tintColor])
            .disposed(by: rx.disposeBag)
        
        icon.backgroundColor = icon.backgroundColor?.withAlphaComponent(0.14)
    }
    
}

// MARK: View setup

private extension HelpAndSupportTableViewCell {
    func setupViews() {
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(nextImage)
    }
    
    func setupConstraints() {
        icon
            .alignEdgesWithSuperview([.left, .top, .bottom], constants: [20, 10, 10])
            .height(constant: 40)
            .width(constant: 40)
        
        titleLabel
            .toRightOf(icon, constant: 20)
            .centerVerticallyInSuperview()
        
        nextImage
            .centerVerticallyInSuperview()
            .width(constant: 20)
            .alignEdgeWithSuperview(.right, constant: 20)
            .toRightOf(titleLabel, .greaterThanOrEqualTo, constant: 10)
    }
}

// MARK: Bindind

private extension HelpAndSupportTableViewCell {
    func bindViews() {
        viewModel.outputs.icon.bind(to: icon.rx.image).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: titleLabel.rx.text).disposed(by: disposeBag)
    }
}
