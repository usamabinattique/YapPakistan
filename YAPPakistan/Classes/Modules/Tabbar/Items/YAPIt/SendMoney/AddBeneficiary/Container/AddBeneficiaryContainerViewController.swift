//
//  AddBeneficiaryContainerViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 15/03/2022.
//

import UIKit
import YAPComponents
import RxCocoa
import RxSwift
import RxTheme

class AddBeneficiaryContainerViewController: KeyboardAvoidingViewController {

//    private lazy var sendButton = UIFactory.makeAppRoundedButton(
//        with: .large,
//        title: "common_button_next".localized
//    )
    
    
    
    private var themeService: ThemeService<AppTheme>!
    private var viewModel: AddSendMoneyBeneficiaryViewModelType!
    private var childNavigation: UINavigationController?
    private var childView: UIView?

    private let disposeBag = DisposeBag()

    init(themeService: ThemeService<AppTheme>, viewModel: AddSendMoneyBeneficiaryViewModelType, childNavigation: UINavigationController?) {

        super.init(nibName: nil, bundle: nil)
        print("OnBoardingContainerViewControllerdevelopment pods")
        self.viewModel = viewModel
        self.themeService = themeService
        self.childNavigation = childNavigation
        self.childView = childNavigation?.view
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupTheme()
        setupCostraints()
        bindViews()
    }
}

// MAKR: View setup

fileprivate extension AddBeneficiaryContainerViewController {
    func setupViews() {
//        view.addSubview(sendButton)
       

        childView?.translatesAutoresizingMaskIntoConstraints = false
        if childView != nil, childNavigation != nil {
            addChild(childNavigation!)
            view.addSubview(childView!)
        }
        childNavigation?.didMove(toParent: self)
        
       // emailDescription.textColor = UIColor(Color(hex: "9391B1"))
    }

    func setupTheme() {
        
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
//            .bind({ UIColor($0.primary) }, to: [sendButton.rx.enabledBackgroundColor])
//            .bind({ UIColor($0.greyDark) }, to: [sendButton.rx.disabledBackgroundColor])
//            .bind({ UIColor($0.primaryExtraLight) }, to: [sendButton.rx.titleColor(for: .normal)])
            .disposed(by: disposeBag)
    }

    func setupCostraints() {
       
        
        
//        sendButton
//            .alignEdgeWithSuperviewSafeArea(.bottomAvoidingKeyboard, constant: 34)
//            .centerHorizontallyInSuperview()
//            .height(constant: 52)
//            .width(constant: 192)

        childView?
            .alignEdgesWithSuperview([.left, .right, .top,.bottom])
//            .alignEdgesWithSuperview([.left, .right, .bottom])
            .alignEdgeWithSuperview(.top,constant: 32)
//            .toTopOf(sendButton)
    }
}

// MARK: Binding

fileprivate extension AddBeneficiaryContainerViewController {
    func bindViews() {
//        sendButton.rx.tap.withLatestFrom(viewModel.outputs.activeStage)
//            .do(onNext: { value in
//                print(value)
//            }).bind(to: viewModel.inputs.sendObserver).disposed(by: disposeBag)
//        viewModel.outputs.valid.bind(to: sendButton.rx.isEnabled).disposed(by: disposeBag)
              
    }
}
