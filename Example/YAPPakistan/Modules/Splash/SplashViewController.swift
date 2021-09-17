//
//  SplashViewController.swift
//  YapPakistanApp
//
//  Created by Sarmad on 24/08/2021.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents

let bundle:Bundle? = nil

class SplashViewController: UIViewController {
    
    private var logoWidthConstraint: NSLayoutConstraint!
    private var logoHeightConstraint: NSLayoutConstraint!
    private var logoCenterHorizonConstraint: NSLayoutConstraint!
    
    private var dotWidthConstraint: NSLayoutConstraint!
    private var dotHeightConstraint: NSLayoutConstraint!
    
    private var viewModel: SplashViewModelType!
    
    private lazy var logo = UIFactory
        .makeImageView(image: UIImage(named: "yap_logo_animate"))
        .addToSuper(view: view)
    
    private lazy var dot = UIFactory
        .makeImageView(image: UIImage(named: "circle"))
        .addToSuper(view: view)
    
    // MARK: Initialization
    init(viewModel: SplashViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubViews()
        setupConstraints()
        bindViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

// MARK: View setup

extension SplashViewController {
    
    fileprivate func setupSubViews() {
        view.backgroundColor = .white
        view.addSubview(logo)
        view.addSubview(dot)
    }
    
    //MARK: Updated YAPLayout, after using UnsafeMutablePointer for initialization
    fileprivate func setupConstraints() {
        logo
            .centerVerticallyInSuperview()
            .horizontallyCenterWith(view, assignTo:&logoCenterHorizonConstraint)
            .width(constant: 110, assignTo:&logoWidthConstraint)
            .height(constant: 103,         assignTo:&logoHeightConstraint)
        
        dot
            .centerHorizontallyInSuperview()
            .verticallyCenterWith(view, constant: 8)
            .width(constant: 13,         assignTo:&dotWidthConstraint)
            .height(constant: 13,         assignTo:&dotHeightConstraint)
    }
    
}

// MARK: Binding

private extension SplashViewController {
    func bindViews() {
        
        viewModel
            .outputs
            .showError
            .subscribe(onNext: { [unowned self] error in
                self.showAlert(title: "",
                 message: error,
                 defaultButtonTitle:  "common_display_text_retry",
                 secondayButtonTitle: nil, defaultButtonHandler: { [weak self] _ in
                 self?.viewModel.inputs.refreshXSRF.onNext(())
                 }, secondaryButtonHandler: nil, completion: nil)
            })
            .disposed(by: rx.disposeBag)
        
        viewModel
            .outputs
            .showAnimation
            .debug("start animation")
            .flatMap{ [weak self] _ in self?.animateLogo() ?? .never() }
            .bind(to: viewModel.inputs.animationCompleteObserver)
            .disposed(by: rx.disposeBag)
        
    }
}

// MARK: - Animations

private extension SplashViewController {
    func animateLogo() -> Observable<Void> {
        let logoAnimation = Observable<Void>.create { [weak self] (observer) -> Disposable in
            UIView.animate(withDuration: 1,delay: 0,options: .curveEaseIn, animations: { [weak self] in
                guard let self = self else {return}
                self.logoWidthConstraint.constant = self.logoWidthConstraint.constant * 100
                self.logoHeightConstraint.constant = self.logoHeightConstraint.constant * 100
                self.logoCenterHorizonConstraint.constant = self.logoCenterHorizonConstraint.constant - 28
                self.view.layoutIfNeeded()
            }){ success in
                if success {
                    observer.onNext(())
                }
            }
            return Disposables.create()
        }
        
        let dotAnimationFaster = Observable<Void>.create { [weak self] (observer) -> Disposable in
            UIView.animate(withDuration: 0.9, delay: 0.4, options: .curveEaseIn, animations: { [weak self] in
                guard let self = self else {return}
                self.dotWidthConstraint.constant = self.dotWidthConstraint.constant * 90
                self.dotHeightConstraint.constant = self.dotHeightConstraint.constant * 90
                self.view.layoutIfNeeded()
            }){ success in
                if success {
                    observer.onNext(())
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
        
        return Observable.zip(logoAnimation, dotAnimationFaster).map{ _ in }
    }
    
}
