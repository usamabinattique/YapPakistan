//
//  UserProfileTableViewCell.swift
//  YAPPakistan
//
//  Created by Awais on 30/03/2022.
//

import UIKit
import RxSwift
import RxTheme
import YAPComponents

class UserProfileTableViewCell: RxUITableViewCell {
    
    // MARK: - Views
    lazy var iconBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear //SessionManager.current.currentAccountType == .b2cAccount ? .clear : .primary
        return view
    }()
    
    lazy var appBuildVersion: UILabel = UIFactory.makeLabel(font: .micro, alignment: .center)
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.tintColor = UIColor.red //SessionManager.current.currentAccountType == .b2cAccount ? .primaryDark : .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var titleLabel =  UIFactory.makeLabel(font: .small) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small)
    lazy var warningView = WarningView()
    lazy var accessoryButton = UIButtonFactory.createButton(backgroundColor: .clear)
    
    lazy var accessorySwitch = UIFactory.makeAppSwitch(isOn: false) //UIAppSwitchFactory.createUIAppSwitch()
    lazy var logoutButton = UIButtonFactory.createButton(backgroundColor: .clear, textColor: UIColor.red)
    lazy var contentStackView = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 13)
    
    // MARK: Properties
    private var viewModel: UserProfileTableViewCellViewModelType! {
        didSet {
            Observable.combineLatest(viewModel.outputs.itemType,
                                       viewModel.outputs.accessory)
                  .subscribe(onNext: { [weak self] (type, accessory) in
                      if type == .logout {
                          self?.setupViewsForLogout()
                      } else if let accessory = accessory,
                          case let UserProfileTableViewAccessory.button(title) = accessory {
                          self?.setupViewsForAccessoryTypeButton(with: title)
                      } else if let accessory = accessory,
                      case let UserProfileTableViewAccessory.toggleSwitch(value) = accessory {
                        self?.setupViewsForAccessoryTypeSwitch(value: value)
                      }
                  }).disposed(by: disposeBag)
        }
    }
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
        setupViews()
        setupConstraints()
    }
    
    // MARK: View cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        render()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        render()
    }
    
    // MARK: Configurations
    func configure(with viewModel: Any, themeService: ThemeService<AppTheme>) {
        guard let viewModel = viewModel as? UserProfileTableViewCellViewModelType else {
            return
        }
        self.themeService = themeService
        contentStackView.subviews.forEach { $0.removeFromSuperview() }
        logoutButton.removeFromSuperview()
        self.viewModel = viewModel
        bindViews()
        setupTheme()
    }
}

// MARK: Setup views
private extension UserProfileTableViewCell {
    
    func setupTheme() {
        themeService.rx
            .bind( { UIColor( $0.primaryDark ) } , to: titleLabel.rx.textColor)
        themeService.rx
            .bind( { UIColor( $0.primary ) } , to: accessoryButton.rx.titleColorForNormal)
        themeService.rx
            .bind( { UIColor($0.primaryDark) }, to: iconImageView.rx.tintColor)
            .bind({ UIColor($0.primary        ) }, to: [accessorySwitch.rx.onTintColor])
            .bind({ UIColor($0.greyLight      ) }, to: [accessorySwitch.rx.offTintColor])
    }
    
    func setupViews() {
        contentView.addSubview(contentStackView)
        //accessorySwitch.onTintColor = .primary
        iconBackground.addSubview(iconImageView)
    }
    
    func setupViewsForAccessoryTypeButton(with title: String) {
        accessoryButton.titleLabel?.font = .small
        accessoryButton.setTitle(title, for: .normal)
        [iconBackground, titleLabel, warningView, UIView(), accessoryButton].forEach { [weak self] view in self?.contentStackView.addArrangedSubview(view) }
    }

    func setupViewsForAccessoryTypeSwitch(value: Bool) {
        accessorySwitch.translatesAutoresizingMaskIntoConstraints = false
        [iconBackground, titleLabel, accessorySwitch].forEach { [weak self] view in self?.contentStackView.addArrangedSubview(view) }
        accessorySwitch.isOn = value
    }
    
    func setupViewsForLogout() {
        logoutButton.titleLabel?.font = .large  // UIFont.appFont(forTextStyle: .large)
        contentStackView.removeFromSuperview()
        contentView.addSubview(logoutButton)
        contentView.addSubview(appBuildVersion)
        
        logoutButton
            .alignEdgeWithSuperview(.top, constant: 20)
            .centerHorizontallyInSuperview()
        
        appBuildVersion
            .toBottomOf(logoutButton, constant: 10)
            .horizontallyCenterWith(logoutButton)
        
        viewModel.outputs.title.bind(to: logoutButton.rx.title(for: .normal)).disposed(by: disposeBag)
        viewModel.outputs.versionText.bind(to: appBuildVersion.rx.text).disposed(by: disposeBag)
    }

    
    func setupConstraints() {
        iconBackground.width(constant: 30).height(constant: 30)
        iconImageView.centerInSuperView().alignEdgesWithSuperview([.left, .top], constant: 5)
        warningView.width(constant: 20).height(constant: 20)
        contentStackView.alignEdgesWithSuperview([.safeAreaLeft, .safeAreaTop, .safeAreaRight, .safeAreaBottom], constants: [25, 0, 25, 0])
    }
    
    func render() {
        iconBackground.roundView()
        accessorySwitch.onImage = UIImage(named: "icon_check", in: .yapPakistan)?.asTemplate
    }
}

// MARK: Binding
private extension UserProfileTableViewCell {
    func bindViews() {
        viewModel.outputs.icon.bind(to: iconImageView.rx.image).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: titleLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.warning.not().bind(to: warningView.rx.isHidden).disposed(by: disposeBag)
        
        let accessoryTypeButton = viewModel.outputs.accessory.unwrap()
            .filter { if case UserProfileTableViewAccessory.button = $0 { return true }; return false }.share(replay: 1, scope: .whileConnected)
        
        accessoryTypeButton
            .map { (accessory: UserProfileTableViewAccessory) -> String? in
                if case let UserProfileTableViewAccessory.button(title) = accessory { return title }; return nil }
            .bind(to: accessoryButton.rx.title(for: .normal)).disposed(by: disposeBag)
        
        Observable.from([accessoryButton.rx.tap,
                         logoutButton.rx.tap])
            .merge()
            .map { _ in UserProfileTableViewAction.button(()) }.bind(to: viewModel.inputs.actionObserver).disposed(by: disposeBag)
        
        accessorySwitch.rx
                .controlEvent(.valueChanged)
                .withLatestFrom(accessorySwitch.rx.value).map { value in UserProfileTableViewAction.toggleSwitch(value) }.bind(to: viewModel.inputs.actionObserver).disposed(by: disposeBag)
    }
}
