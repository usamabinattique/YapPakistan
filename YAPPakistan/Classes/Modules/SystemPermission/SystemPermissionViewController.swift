//
//  BiometricPermissionViewController.swift
//  YAP
//
//  Created by Wajahat Hassan on 27/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents

//import Authentication
//import AppAnalytics

class SystemPermissionViewController: UIViewController {
    
    // swiftlint:disable force_cast
    //let appDelegate = UIApplication.shared.delegate as! PublicAppDelegate
    // swiftlint:enable force_cast
    //let viewModel: SystemPermissionViewModelType
    //fileprivate var disposeBag = DisposeBag()
    fileprivate var widthConstraint: NSLayoutConstraint?
    //fileprivate var permissionType: SystemPermissionType?
    fileprivate var username: String = ""
    
    fileprivate lazy var icon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .blue //.primary
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    fileprivate lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(forTextStyle: .title3)
        label.textColor = .blue //UIColor.appColor(ofType: .primaryDark)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate lazy var subHeadingLabel: UILabel = {
        let label = UILabel()
        label.font = .small
        label.textColor = .gray //.greyDark
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate lazy var termsDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(forTextStyle: .small)
        label.textColor = UIColor.gray //.appColor(ofType: .greyDark)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate lazy var termsConditionButton: UIButton = {
        let button = UIButton()
        button.setTitle( "screen_system_permission_text_terms_and_conditions".localized, for: .normal)
        button.titleLabel?.font = .appFont(forTextStyle: .small)
        button.setTitleColor(UIColor.blue /*.appColor(ofType: .primary )*/, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate lazy var permissionButton: AppRoundedButton = {
        let button = AppRoundedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate lazy var thanksButton: UIButton = {
        let button = UIButton()
        button.setTitle( "screen_system_permission_text_denied".localized, for: .normal)
        button.setTitleColor(UIColor.blue /*appColor(ofType: .primary)*/, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /* init(viewModel: SystemPermissionViewModelType, username: String = "") {
        self.viewModel = viewModel
        self.username = username
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    } */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //bind(viewModel: viewModel)
        setupSubViews()
        setupConstraints()
    }
}

extension SystemPermissionViewController {
    fileprivate func setupSubViews() {
        navigationItem.hidesBackButton = true
        view.backgroundColor = .white
        view.addSubview(icon)
        view.addSubview(headingLabel)
        view.addSubview(subHeadingLabel)
        view.addSubview(termsDescriptionLabel)
        view.addSubview(termsConditionButton)
        view.addSubview(permissionButton)
        view.addSubview(thanksButton)
    }
    
    fileprivate func setupConstraints() {
        //TBEFixed
        self.widthConstraint = self.permissionButton.widthAnchor.constraint(equalToConstant: 192)
        
        let iconConstraints = [
            icon.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 75),
            icon.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        let headingConstraints = [
            headingLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 47),
            headingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            view.trailingAnchor.constraint(equalTo: headingLabel.trailingAnchor, constant: 30)
        ]
        
        let subHeadingConstraints = [
            subHeadingLabel.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 20),
            subHeadingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            view.trailingAnchor.constraint(equalTo: subHeadingLabel.trailingAnchor, constant: 30)
        ]
        
        let termsConditionDescriptionConstraints = [
            termsConditionButton.topAnchor.constraint(equalTo: termsDescriptionLabel.bottomAnchor, constant: 0),
            termsDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            view.trailingAnchor.constraint(equalTo: termsDescriptionLabel.trailingAnchor, constant: 25)
        ]
        
        let termsConditionButtonConstraints = [
            permissionButton.topAnchor.constraint(equalTo: termsConditionButton.bottomAnchor, constant: 31),
            termsConditionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            view.trailingAnchor.constraint(equalTo: termsConditionButton.trailingAnchor, constant: 25)
        ]
        
        let permissionButtonConstraints = [
            widthConstraint!,
            thanksButton.topAnchor.constraint(equalTo: permissionButton.bottomAnchor, constant: 23),
            permissionButton.heightAnchor.constraint(equalToConstant: 52),
            permissionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        let thanksButtonContraints = [
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: thanksButton.bottomAnchor, constant: 30),
            thanksButton.widthAnchor.constraint(equalToConstant: view.bounds.size.width),
            thanksButton.heightAnchor.constraint(equalToConstant: 24),
            thanksButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(
            iconConstraints +
                headingConstraints +
                subHeadingConstraints +
                termsConditionDescriptionConstraints +
                termsConditionButtonConstraints +
                permissionButtonConstraints +
            thanksButtonContraints
        )
        
    }
    
}

/*
extension SystemPermissionViewController {
    
    fileprivate func bind(viewModel: SystemPermissionViewModelType?) {
        guard let `viewModel` = viewModel else { return }
        bindDisplayableText(viewModel: viewModel)
        bindLoader(viewModel: viewModel)
        bindPermissionType(viewModel: viewModel)
        bindActions(viewModel: viewModel)
        bindError(viewModel: viewModel)
        bindDeviceToken(viewModel: viewModel)
        bindNoThanks(viewModel: viewModel)
    }
    
    private func bindLoader(viewModel: SystemPermissionViewModelType) { }
    
    private func bindDisplayableText(viewModel: SystemPermissionViewModelType) {
        viewModel.outputs.heading.bind(to: headingLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.subHeading.bind(to: subHeadingLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.icon.bind(to: icon.rx.image).disposed(by: rx.disposeBag)
        viewModel.outputs.termsConditionDescription.bind(to: termsDescriptionLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.iconBackground.filter{ $0 != .clear}.subscribe(onNext: { [weak self] in
            self?.icon.backgroundColor = $0
            self?.icon.height(constant: 64)
            self?.icon.width(constant: 64)
            self?.icon.layer.cornerRadius = 32
            self?.icon.contentMode = .center
            self?.icon.clipsToBounds = true
        }).disposed(by: rx.disposeBag)
    }
    
    private func bindDeviceToken(viewModel: SystemPermissionViewModelType) {
        let deviceToken = appDelegate.deviceToken.share()
        deviceToken.unwrap().map { _ in () }.bind(to: viewModel.inputs.successObserver).disposed(by: rx.disposeBag)
        deviceToken.filter { $0 == nil }.map { _ in () }.bind(to: viewModel.inputs.onNoThanksObserver).disposed(by: rx.disposeBag)
    }
    
    private func bindNoThanks(viewModel: SystemPermissionViewModelType) {
        thanksButton.rx.tap
            .map { _ in () }
            .bind(to: viewModel.inputs.onNoThanksObserver).disposed(by: rx.disposeBag)
    }
    
    private func bindActions(viewModel: SystemPermissionViewModelType) {
        permissionButton.rx.tap.bind(to: viewModel.inputs.onPermissionObserver).disposed(by: rx.disposeBag)
        
        viewModel.outputs.buttonTitle.subscribe(onNext: {[unowned self] title in
            self.permissionButton.setTitle(title, for: .normal)
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.permissionType.map { $0 == .notification ? true : false }.bind(to: termsDescriptionLabel.rx.isHidden).disposed(by: rx.disposeBag)
        viewModel.outputs.permissionType.map { $0 == .notification ? true : false }.bind(to: termsConditionButton.rx.isHidden).disposed(by: rx.disposeBag)
        
    }
    
    private func bindPermissionType(viewModel: SystemPermissionViewModelType) {
        viewModel.outputs.permissionType.subscribe(onNext: {[unowned self] type in
            switch type {
            case .notification:
                self.widthConstraint = self.permissionButton.widthAnchor.constraint(equalToConstant: 280)
            default:
                self.widthConstraint = self.permissionButton.widthAnchor.constraint(equalToConstant: 192)
            }
            self.permissionType = type
        }).disposed(by: rx.disposeBag)
    }
    
    private func bindError(viewModel: SystemPermissionViewModelType) {
        viewModel.outputs.error
            .subscribe(onNext: { _ in
            }).disposed(by: rx.disposeBag)
    }
}
*/
