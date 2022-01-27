//
//  Y2YTransferSuccessViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 27/01/2022.
//

import UIKit
import YAPComponents
import RxSwift

class Y2YTransferSuccessViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var userImage = UIFactory.makeImageView(contentMode: .scaleAspectFit) //UIImageViewFactory.createBackgroundImageView(mode: .scaleAspectFit)
    
    private lazy var userName = UIFactory.makeLabel(font: .large, alignment: .center) //.primaryDark
    
    private lazy var transferLabel = UIFactory.makeLabel(font: .micro, alignment: .center) //.greyDark : "screen_y2y_funds_transfer_success_display_text_transfer".localized)
    
    private lazy var amountLabel = UIFactory.makeLabel(font: .title2, alignment: .center) // .primaryDark
    
    private lazy var confirmButton = AppRoundedButtonFactory.createAppRoundedButton(title: "screen_y2y_funds_transfer_success_button_back".localized)
    
    private lazy var checkView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var checkImage = UIFactory.makeImageView(contentMode: .center)  //UIImageViewFactory.createImageView(mode: .center, image: UIImage.sharedImage(named: "icon_completion"))

    // MARK: Properties
    
    private var viewModel: Y2YTransferSuccessViewModelType!
    private let disposeBag = DisposeBag()
    
    // MARK: Initialization
    
    init(viewModel: Y2YTransferSuccessViewModelType) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "screen_y2y_funds_transfer_success_display_text_title".localized
        navigationItem.hidesBackButton = true
        
        setupConstraints()
        setupSubViews()
        setupBindings()
        setupTheme()
    }
}

// MARK: View setup

extension Y2YTransferSuccessViewController: ViewDesignable {
    
    public func setupConstraints() {
        
        userImage
            .alignEdgeWithSuperview(.top, constant: 25)
            .centerHorizontallyInSuperview()
            .height(constant: 64)
            .width(with: .height, ofView: userImage)
        
        userName
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .toBottomOf(userImage, constant: 20)
        
        transferLabel
            .toBottomOf(userName, constant: 15)
            .centerHorizontallyInSuperview()
        
        amountLabel
            .toBottomOf(transferLabel, constant: 2)
            .centerHorizontallyInSuperview()
        
        confirmButton
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 15)
            .centerHorizontallyInSuperview()
            .width(constant: 240)
            .height(constant: 52)
        
        checkView
            .toBottomOf(amountLabel)
            .toTopOf(confirmButton)
            .alignEdgesWithSuperview([.left, .right])
        
        checkImage
            .centerInSuperView()
    }
    
    
    public func setupSubViews() {
        view.backgroundColor = .white
        
        view.addSubview(userImage)
        view.addSubview(userName)
        view.addSubview(transferLabel)
        view.addSubview(amountLabel)
        view.addSubview(checkView)
        view.addSubview(confirmButton)
        
        checkView.addSubview(checkImage)
        
        userImage.layer.cornerRadius = 32
        userImage.clipsToBounds = true
    }
    
    public func setupBindings() {
        viewModel.outputs.userImage.bind(to: userImage.rx.loadImage()).disposed(by: disposeBag)
        viewModel.outputs.userName.bind(to: userName.rx.text).disposed(by: disposeBag)
        viewModel.outputs.amount.bind(to: amountLabel.rx.text).disposed(by: disposeBag)
        
        confirmButton.rx.tap.bind(to: viewModel.inputs.confirmObsever).disposed(by: disposeBag)
    }
    
    public func setupTheme() {
        
    }
    
    
    
}
