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
        .makeImageView(image:BundleYapPak.image("yap_logo_animate"))
        .addToSuper(view: view)
    
    private lazy var dot = UIFactory
        .makeImageView(image:BundleYapPak.image("circle")) //BundleYapPak.image("circle"))
        .addToSuper(view: view)
    
    /*private lazy var visualEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        view.effect = nil
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()*/
    
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
        
        //DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        //    print(self.logo.image)
        //    self.animateLogo().subscribe().disposed(by: self.rx.disposeBag)
        //}
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
        //view.addSubview(visualEffectView)
    }
    
    fileprivate func setupConstraints() {
        
        logo.centerVerticallyInSuperview()
        
        logoCenterHorizonConstraint = NSLayoutConstraint(item: logo, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        
        logo.horizontallyCenterWith(view, constant: 0)
        logoWidthConstraint = logo.widthAnchor.constraint(equalToConstant: 110)
        logoHeightConstraint = logo.heightAnchor.constraint(equalToConstant: 103)
        
        logoWidthConstraint.isActive = true
        logoHeightConstraint.isActive = true
        logoCenterHorizonConstraint.isActive = true
        
        dot
        .centerHorizontallyInSuperview()
        .verticallyCenterWith(view, constant: 8)
       
        dotWidthConstraint = dot.widthAnchor.constraint(equalToConstant: 13)
        dotHeightConstraint = dot.heightAnchor.constraint(equalToConstant: 13)
        
        dotWidthConstraint.isActive = true
        dotHeightConstraint.isActive = true
        
        //visualEffectView.alignAllEdgesWithSuperview()
    }
}

// MARK: Binding

private extension SplashViewController {
    func bindViews() {
        
        viewModel
            .outputs
            .showError
            .subscribe(onNext: { [unowned self] error in
                /* self.showAlert(title: "",
                           message: error,
                           defaultButtonTitle:  "common_display_text_retry".localized,
                           secondayButtonTitle: nil, defaultButtonHandler: { [weak self] _ in
                            self?.viewModel.inputs.refreshXSRF.onNext(())
                }, secondaryButtonHandler: nil, completion: nil) */
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
