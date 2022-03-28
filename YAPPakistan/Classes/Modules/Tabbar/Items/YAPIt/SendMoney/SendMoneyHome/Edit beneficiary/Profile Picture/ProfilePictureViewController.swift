//
//  ProfilePictureViewController.swift
//  Adjust
//
//  Created by Muhammad Sohaib on 22/03/2022.
//

import UIKit
import YAPCore
import YAPComponents
import RxSwift
import RxCocoa
import RxDataSources
import RxTheme

class ProfilePictureViewController: KeyboardAvoidingViewController {
    
    // MARK: Views
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(named: "icon_close_white_bg", in: .yapPakistan), for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var userImageView: UIImageView = {
        let imageView = UIFactory.makeImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var bottomView = UIFactory.makeView()
    
    private lazy var usePhotoButton = AppRoundedButtonFactory.createAppRoundedButton(title: "screen_send_money_edit_beneficiary_use_photo".localized)
    private lazy var retakePhotoButton = UIButtonFactory.createButton(title: "screen_send_money_edit_beneficiary_retake_photo".localized, backgroundColor: .clear)
    
    private lazy var buttonStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 23, arrangedSubviews: [usePhotoButton, retakePhotoButton])
    
    // MARK: Properties
    
    private let disposeBag = DisposeBag()
    private var themeService: ThemeService<AppTheme>!
    let viewModel: ProfilePictureViewModelType!
    
    // MARK: Initialization

    init(themeService: ThemeService<AppTheme>,
         _ viewModel: ProfilePictureViewModelType) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        
        /// View
        setupView()
        setupTheme()
        setupConstraints()
        
        /// Bind
        bindViews()
    }
}

// MARK: View Setup

extension ProfilePictureViewController {
    
    func setupView() {
        bottomView.addSubview(buttonStack)
        view.addSubviews([userImageView, closeButton, bottomView])
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor, bottomView.rx.backgroundColor])
            .bind({ UIColor($0.primary)}, to: [usePhotoButton.rx.backgroundColor, retakePhotoButton.rx.titleColorForNormal])
            .disposed(by: rx.disposeBag)
    }
    
    func setupConstraints() {
        
        userImageView
            .alignEdgeWithSuperview(.top, constant: 0)
            .alignEdgeWithSuperview(.left, constant: 0)
            .alignEdgeWithSuperview(.right, constant: 0)
        
        closeButton
            .alignEdgesWithSuperview([.left, .top], constants: [25, 50])
            .height(constant: 32)
            .width(constant: 32)
        
        bottomView
            .toBottomOf(userImageView)
            .alignEdgesWithSuperview([.left, .right, .bottom], constants: [0, 0, 0])
            .height(constant: 180)
        
        usePhotoButton
            .height(constant: 52)
            .width(constant: 192)
        
        retakePhotoButton
            .height(constant: 28)
            .width(constant: 192)
        
        buttonStack
            .alignEdgesWithSuperview([.centerX, .centerY], constants: [0, 0])
    }
}

// MARK: Binding

extension ProfilePictureViewController {
    
    func bindViews() {
        
        /// Event flow: VC -> VM
        closeButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: disposeBag)
        usePhotoButton.rx.tap.bind(to: viewModel.inputs.usePhotoObserver).disposed(by: disposeBag)
        retakePhotoButton.rx.tap.map{ PictureReviewResult.retake }.bind(to: viewModel.inputs.retakeObserver).disposed(by: disposeBag)

        /// Event flow: VM -> VC
        viewModel.outputs.image.bind(to: userImageView.rx.image).disposed(by: disposeBag)
    }
}
