//
//  PaymentCardOnboardingStatusTableViewCell.swift
//  YAPPakistan
//
//  Created by Yasir on 13/04/2022.
//

import Foundation
import YAPComponents
import RxTheme

open class PaymentCardOnboardingStatusTableViewCell: RxUITableViewCell {
    
    // MARK: - Views
    lazy var iconImageView = UIImageView()
    
    lazy var verticleBreadcrumbView: UIView = {
        let view = UIView()
        //view.backgroundColor = .primary
        view.translatesAutoresizingMaskIntoConstraints = false
        view.width(constant: 1)
            .height(constant: 55)
        return view
    }()
    
    lazy var paddingView = UIView()
    
    lazy var iconStackView = UIStackViewFactory.createStackView(with: .vertical,
                                                                alignment: .center,
                                                                distribution: .fill,
                                                                spacing: 7,
                                                                arrangedSubviews: [iconImageView, verticleBreadcrumbView, paddingView])
    
    lazy var titleLabel = UIFactory.makeLabel(font: .regular) //UILabelFactory.createUILabel(with: .primaryDark,
                                                      // textStyle: .regular)
    
    lazy var completedLabel: PaddedLabel = UIFactory.makePaddingLabel(font: .micro, text: "view_payment_card_onboarding_stage_completed_label_text".localized) /*UILabelFactory.createUILabel(with: .primary,
                                                                        textStyle: .micro,
                                                                        text: "view_payment_card_onboarding_stage_completed_label_text".localized) */
    
    lazy var inProcessLabel: PaddedLabel = UIFactory.makePaddingLabel(font: .micro, text: "view_payment_card_onboarding_stage_in_process_label_text".localized) /*UILabelFactory.createUILabel(with: .primary,
                                                                        textStyle: .micro,
                                                                        text: "view_payment_card_onboarding_stage_in_process_label_text".localized) */
    
    lazy var topStackView = UIStackViewFactory.createStackView(with: .horizontal,
                                                               alignment: .fill,
                                                               distribution: .fill,
                                                               spacing: 5,
                                                               arrangedSubviews: [titleLabel, inProcessLabel, completedLabel])
    
    lazy var subheadingLabel = UIFactory.makeLabel(font: .micro, numberOfLines: 0, lineBreakMode: .byWordWrapping) /*UILabelFactory.createUILabel(with: .greyDark,
                                                            textStyle: .micro,
                                                            numberOfLines: 0,
                                                            lineBreakMode: .byWordWrapping) */
    
    lazy var actionButton = UIButtonFactory.createButton(backgroundColor: .clear,
                                                         textColor: UIColor(themeService.attrs.primary)) //.primary)
    
    lazy var bottomStackView = UIStackViewFactory.createStackView(with: .vertical,
                                                                  alignment: .leading,
                                                                  distribution: .fill,
                                                                  spacing: 5,
                                                                  arrangedSubviews: [subheadingLabel, actionButton])
    
    lazy var topBottomStackView = UIStackViewFactory.createStackView(with: .vertical,
                                                                     alignment: .top,
                                                                     distribution: .fill,
                                                                     spacing: 5,
                                                                     arrangedSubviews: [topStackView, bottomStackView])
    
    lazy var contentStackView = UIStackViewFactory.createStackView(with: .horizontal,
                                                                   alignment: .top,
                                                                   distribution: .fill,
                                                                   spacing: 23,
                                                                   arrangedSubviews: [iconStackView, topBottomStackView])
    
    // MARK: Properties
    private var viewModel: PaymentCardOnboardingStageModel!
    private var themeService: ThemeService<AppTheme>!
    
    
    // MARK: - Init
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
       // commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
       // commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
        
        setupViews()
        setupConstraints()
        setupTheme()
    }
    
    // MARK: - Configurationn
    open override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? PaymentCardOnboardingStageModel else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        commonInit()
        bind()
    }
    
    open override func draw(_ rect: CGRect) {
        completedLabel.clipsToBounds = true
        completedLabel.layer.cornerRadius = completedLabel.bounds.height / 2
        
        inProcessLabel.clipsToBounds = true
        inProcessLabel.layer.cornerRadius = inProcessLabel.bounds.height / 2
    }
}

// MARK: - View setup
private extension PaymentCardOnboardingStatusTableViewCell {
    func setupViews() {
        iconImageView.tintColor = UIColor(themeService.attrs.primary) //.primary
        completedLabel.backgroundColor = #colorLiteral(red: 0.85911268, green: 0.9641109109, blue: 0.9578837752, alpha: 1)
        inProcessLabel.backgroundColor = #colorLiteral(red: 0.9950210452, green: 0.9280350804, blue: 0.8761626482, alpha: 1)
        actionButton.titleLabel?.font = .small
        contentView.addSubview(contentStackView)
    }
    
    func setupConstraints() {
        contentStackView
            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constants: [0, 0, 15, 0])
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView
            .width(constant: 30)
            .height(constant: 30)
        iconStackView.width(constant: 30)
        topStackView.alignEdgesWithSuperview([.left, .right])
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [titleLabel.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [completedLabel.rx.textColor, inProcessLabel.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [subheadingLabel.rx.textColor])
            .disposed(by: rx.disposeBag)
    }
    
    func bind() {
        viewModel.icon.map { iconImageView.image = $0 }
        verticleBreadcrumbView.isHidden = !viewModel.showVerticleBreadcrum
        completedLabel.isHidden = !viewModel.completed
        inProcessLabel.isHidden = !viewModel.inProcess
        titleLabel.text = viewModel.title
        subheadingLabel.text = viewModel.subheading
        viewModel.actionTitle.map { actionButton.setTitle($0, for: .normal) }
        actionButton.titleLabel?.text = viewModel.actionTitle
        setEnabled(isStageEnable: viewModel.isEnabled)
        actionButton.rx.tap.bind(to: viewModel.actionTapObserver).disposed(by: disposeBag)
    }
    
    func setEnabled(isStageEnable: Bool) {
        iconImageView.alpha = isStageEnable ? 1 : 0.5
        verticleBreadcrumbView.alpha = isStageEnable ? 1 : 0.5
        titleLabel.alpha = isStageEnable ? 1 : 0.5
        subheadingLabel.alpha = isStageEnable ? 1 : 0.5
        actionButton.alpha = isStageEnable ? 1 : 0.5
        actionButton.isEnabled = isStageEnable
    }
}
