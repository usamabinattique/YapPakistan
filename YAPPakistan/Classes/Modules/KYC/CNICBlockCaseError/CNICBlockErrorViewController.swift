//
//  CNICBlockErrorViewController.swift
//  YAPPakistan
//
//  Created by Awais on 23/06/2022.
//

import YAPComponents
import RxSwift
import RxTheme
import UIKit

class CNICBlockCaseErrorViewController: UIViewController {
    
    private let errorImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private let errorTitltLabel = UIFactory.makeLabel(font: .title1, alignment: .center, numberOfLines: 0)
    private let errorDescriptionLabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0)
    private let dashboardButton = UIFactory.makeAppRoundedButton(with: .regular)
    private let backButton = UIFactory.makeAppRoundedButton(with: .regular)
    
    private var themeService: ThemeService<AppTheme>!
    var viewModel: CNICBlockCaseErrorViewModelType!
    private let disposeBag = DisposeBag()
    
    convenience init(themeService: ThemeService<AppTheme>, viewModel: CNICBlockCaseErrorViewModelType) {
        self.init(nibName: nil, bundle: nil)
        
        self.themeService = themeService
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTheme()
        setupResources()
        setupBindings()
        setupConstraints()
    }
    
    func setupViews() {
        view
            .addSub(view: errorImage)
            .addSub(view: errorTitltLabel)
            .addSub(view: dashboardButton)
            .addSub(view: errorDescriptionLabel)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primaryDark) }, to: errorTitltLabel.rx.textColor)
            .bind( { UIColor($0.greyDark) }, to: errorDescriptionLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: dashboardButton.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
    }
    
    func setupResources() {
        self.dashboardButton.setTitle("Log out", for: .normal)
        errorImage.image = UIImage(named: "cnic_block_image", in: .yapPakistan)
    }
    
    func setupBindings() {
        self.dashboardButton.rx.tap.bind(to: self.viewModel.inputs.gotoDashboardObserver).disposed(by: rx.disposeBag)
        self.viewModel.outputs.errorTitle.bind(to: self.errorTitltLabel.rx.text).disposed(by: disposeBag)
        self.viewModel.outputs.errorDescription.bind(to: self.errorDescriptionLabel.rx.text).disposed(by: disposeBag)
    }
    
    func setupConstraints() {
        
        errorTitltLabel
            .centerHorizontallyInSuperview()
            .alignEdgesWithSuperview([.top, .safeAreaLeft, .safeAreaRight], constants: [94, 33, 33])
        
        errorImage
            .centerHorizontallyInSuperview()
            .toBottomOf(errorTitltLabel, constant: 43)
            .alignEdgesWithSuperview([.safeAreaLeft, .safeAreaRight], constants: [0, 0])
            .height(constant: 250)
            
        
        errorDescriptionLabel
            .toBottomOf(errorImage, constant: 32)
            .alignEdgesWithSuperview([.safeAreaLeft, .safeAreaRight], constants: [32, 34])
        
        
        dashboardButton
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.safeAreaBottom, constant: 25)
            .width(constant: 250)
            .height(constant: 52)
    }
}
