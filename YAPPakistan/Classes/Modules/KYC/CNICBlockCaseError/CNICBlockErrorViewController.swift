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
    private let actionButton = UIFactory.makeAppRoundedButton(with: .regular)
    private let dashboardButton = UIFactory.makeAppRoundedButton(with: .regular)
    private lazy var stackView = UIFactory.makeStackView( axis: .vertical,
                                                          alignment: .fill,
                                                          spacing: 10 )
    
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
            .addSub(view: stackView)
            .addSub(view: errorDescriptionLabel)
        
        stackView.addArrangedSubview(actionButton)
        stackView.addArrangedSubview(dashboardButton)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primaryDark) }, to: errorTitltLabel.rx.textColor)
            .bind( { UIColor($0.greyDark) }, to: errorDescriptionLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: dashboardButton.rx.titleColor)
            .bind({ UIColor($0.primary) }, to: actionButton.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
        
        dashboardButton.backgroundColor = UIColor.white
    }
    
    func setupResources() {
        errorImage.image = UIImage(named: "cnic_block_image", in: .yapPakistan)
    }
    
    func setupBindings() {
        self.dashboardButton.rx.tap.bind(to: self.viewModel.inputs.gotoDashboardObserver).disposed(by: rx.disposeBag)
        self.viewModel.outputs.errorTitle.bind(to: self.errorTitltLabel.rx.text).disposed(by: disposeBag)
        self.viewModel.outputs.errorDescription.bind(to: self.errorDescriptionLabel.rx.text).disposed(by: disposeBag)
        self.actionButton.rx.tap.bind(to: self.viewModel.inputs.actionButtonObserver).disposed(by: disposeBag)
        self.viewModel.outputs.blockCaseActionsState.subscribe(onNext: { [weak self] blockCase in
            
            guard let self = self else { return }
            
            if blockCase == .underAge {
                // Only logout button will be available for this case
                self.actionButton.setTitle("Log out", for: .normal)
              
                self.dashboardButton.isHidden = true
                self.actionButton.isHidden = false
            }
            else if blockCase == .invalidCNIC {
                // Rescan CNIC and goto dashboard button will be available
                self.actionButton.setTitle("Re-scan CNIC", for: .normal)
                self.dashboardButton.setTitle("Skip and go to dashboard", for: .normal)
                
                self.actionButton.isHidden = false
                self.dashboardButton.isHidden = false
            }
            else if blockCase == .cnicExpiredOnScane {
                // Rescan CNIC and goto dashboard button will be available
                self.actionButton.setTitle("Re-scan CNIC", for: .normal)
                self.dashboardButton.setTitle("Skip and go to dashboard", for: .normal)
                
                self.actionButton.isHidden = false
                self.dashboardButton.isHidden = false
            }
            else if blockCase == .cnicAlreadyUsed {
                // Only logout button will be available for this case
                self.actionButton.setTitle("Log out", for: .normal)
                
                self.actionButton.isHidden = false
                self.dashboardButton.isHidden = true
            }
        }).disposed(by: disposeBag)
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
            .height(constant: 50)
        
        actionButton
            .height(constant: 50)
        
        stackView
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.safeAreaBottom, constant: 25)
            .width(constant: 250)
    }
}
