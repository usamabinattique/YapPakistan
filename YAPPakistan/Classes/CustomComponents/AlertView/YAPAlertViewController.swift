//
//  YAPAlertViewController.swift
//  YAPKit
//
//  Created by Zain on 04/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents
import RxTheme

class YAPAlertViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var alertView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var label: ClickableLinkLabel = {
        let label = ClickableLinkLabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.delegate = self
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var primaryButton = UIFactory.makeAppRoundedButton(with: nil, title: nil)
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
//        button.setTitleColor(.primary, for: .normal)
        button.setTitleColor(.purple, for: .normal)
        button.titleLabel?.font = .large
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var stackView: UIStackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 15)
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.sharedImage(named: "icon_close")?.asTemplate, for: .normal)
        button.backgroundColor = .clear
        button.isHidden = true
//        button.tintColor = .primaryDark
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: Properties
    
    var window: UIWindow?
//    private var labelHeight: NSLayoutConstraint!
//    private var viewTop: NSLayoutConstraint!
    private var viewModel: YAPAlertViewModelType!
    private let disposeBag = DisposeBag()
    private var theme: ThemeService<AppTheme>!

    // MARK: Initialization
    
    init(themeService: ThemeService<AppTheme>, viewModel: YAPAlertViewModelType) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.theme = themeService
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        bindViews()
        setupTheme()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        render()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        view.layoutIfNeeded()
        
        alertView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: {() -> Void in
            self.alertView.transform = .identity
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }, completion: {(finished: Bool) -> Void in
            // do something once the animation finishes, put it here
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        view.window?.resignKey()
        view.window?.removeFromSuperview()
        window = nil
    }
    
    // MARK: Hide
    
    private func hide() {
        alertView.transform = .identity
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {() -> Void in
            self.alertView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.alertView.alpha = 0
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        }, completion: { (completed) -> Void in
            guard completed else { return }
            self.alertView.isHidden = true
            self.dismiss(animated: false, completion: nil)
        })
    }
    
}

// MARK: View setup

private extension YAPAlertViewController {
    func setupViews() {
        view.addSubview(alertView)
        
        alertView.addSubview(stackView)
        alertView.addSubview(closeButton)
        stackView.addArrangedSubview(icon)
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(primaryButton)
        stackView.addArrangedSubview(cancelButton)
    }
    
    func setupConstraints() {
        
        closeButton
            .alignEdgesWithSuperview([.right, .top], constants: [23, 21])
        
        alertView
            .alignEdgeWithSuperview(.left, constant: 25)
            .centerInSuperView()
            .height(.lessThanOrEqualTo, constant: UIScreen.main.bounds.height * 0.7)
        
        stackView
            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constants: [20, 30, 20, 30])
        
        label
            .alignEdgeWithSuperview(.width)
        
        primaryButton
            .height(constant: 50)
            .width(constant: 190)
        
        cancelButton
            .height(constant: 40)
        
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
    }
    
    func render() {
        alertView.layer.cornerRadius = 14
        alertView.clipsToBounds = true
    }
}

// MARK: Binding

private extension YAPAlertViewController {
    func bindViews() {
        viewModel.outputs.icon.map { $0 == nil }.bind(to: icon.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.icon.bind(to: icon.rx.image).disposed(by: disposeBag)
        viewModel.outputs.text.bind(to: label.rx.attributedText).disposed(by: disposeBag)
        viewModel.outputs.primaryButtonTitle.bind(to: primaryButton.rx.title(for: .normal)).disposed(by: disposeBag)
        viewModel.outputs.cancelButtonTitle.bind(to: cancelButton.rx.title(for: .normal)).disposed(by: disposeBag)
        viewModel.outputs.cancelButtonTitle.map { $0 == nil }.bind(to: cancelButton.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.showsCloseButton.map{ !$0 }.bind(to: closeButton.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.primaryButtonTitle.map { ($0 ?? "").isEmpty }.bind(to: primaryButton.rx.isHidden).disposed(by: disposeBag)
        
        primaryButton.rx.tap
            .do(onNext: { [weak self] in self?.hide() })
            .bind(to: viewModel.inputs.primaryActionObserver)
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .do(onNext: { [weak self] in self?.hide() })
            .bind(to: viewModel.inputs.cancelActionObserver)
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .do(onNext: { [weak self] in self?.hide() })
            .bind(to: viewModel.inputs.closeObserver)
            .disposed(by: disposeBag)
       
    }
    
    func setupTheme() {
        self.theme.rx
            .bind({ UIColor($0.primary) }, to:  primaryButton.rx.enabledBackgroundColor )
            .bind({ UIColor($0.primary) }, to:  cancelButton.rx.titleColor(for: .normal) )
            .bind({ UIColor($0.primaryDark) }, to:  closeButton.rx.tintColor )
            .disposed(by: rx.disposeBag)
    }
}

// MARK: Clickable link label delegate

extension YAPAlertViewController: ClickableLinkLabelDelegate {
    func clickableLinkLabel(_ clickableLinkLabel: ClickableLinkLabel, didTapLink link: String) {
        hide()
        viewModel.inputs.urlObserver.onNext(link)
    }
}
