//
//  PINViewController.swift
//  YAP
//
//  Created by Zain on 26/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import YAPComponents
import RxSwift
import RxCocoa

/**
 
 */
public class PINViewController: UIViewController {
    
    // MARK: - Init
    public init(viewModel: PINViewModelType, isCreatePasscode: Bool? = false) {
        self.viewModel = viewModel
        self.isCreatePasscode = isCreatePasscode ?? false
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Views
    //.primaryDark, textStyle: .title3
    private lazy var headingLabel: UILabel = UIFactory.makeLabel(font: .title3, alignment: .center, lineBreakMode: .byWordWrapping)
    
    private lazy var holdingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dottedView: PasscodeDottedView = {
        let view = PasscodeDottedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //collor: .error
    private lazy var errorLabel: UILabel = UIFactory.makeLabel(font:.regular, alignment: .center)
    
    private lazy var pinKeyboard: RxPasscodeKeyboard = RxPasscodeKeyboard()
    
    //with: .greyDark
    private lazy var termsAndCondtionsLabel: UILabel = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)
    
    private lazy var createPINButton: AppRoundedButton = AppRoundedButtonFactory.createAppRoundedButton()
    
    // MARK: - Properties
    let viewModel: PINViewModelType
    let disposeBag: DisposeBag
    var hideNavigationBar: Bool = false
    var isCreatePasscode: Bool
    
    // MARK: - View Life Cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
        bindTranslations()
        
        termsAndCondtionsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(termsAndCondtionsTapped)))
        termsAndCondtionsLabel.isUserInteractionEnabled = true
    }
    
    public override func onTapBackButton() {
        viewModel.inputs.backObserver.onNext(())
        viewModel.inputs.backObserver.onCompleted()
    }
    
    @objc func termsAndCondtionsTapped() {
        viewModel.inputs.termsAndConditionsActionObserver.onNext(())
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(hideNavigationBar, animated: false)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(isCreatePasscode ? true : hideNavigationBar, animated: false)
    }
    
}

// MARK: - Setup
fileprivate extension PINViewController {
    func setup() {
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        view.backgroundColor = .white
        holdingView.addSubview(dottedView)
        holdingView.addSubview(errorLabel)
        view.addSubview(headingLabel)
        view.addSubview(holdingView)
        view.addSubview(pinKeyboard)
        view.addSubview(termsAndCondtionsLabel)
        view.addSubview(createPINButton)
    }
    
    
    func setupConstraints() {
        
        headingLabel
            .alignEdge(.left, withView: view, constant: 20)
            .height(.greaterThanOrEqualTo, constant: 23)
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperviewSafeArea(.safeAreaTop, .lessThanOrEqualTo, constant: 15)
            .alignEdgeWithSuperviewSafeArea(.safeAreaTop, .greaterThanOrEqualTo, constant: 0)

        
        dottedView
            .centerInSuperView()
            .height(constant: 16)
        
        errorLabel
            .toBottomOf(dottedView, constant: 3)
            .alignEdges([.left, .right], withView: holdingView, constant: 25)
            .height(constant: 20)
        
        holdingView
            .toBottomOf(headingLabel, constant: 1)
            .toTopOf(pinKeyboard)
            .alignEdgesWithSuperview([.left, .right])
        
        pinKeyboard
            .alignEdgesWithSuperview([.left, .right], constants: [55, 55])
            .toBottomOf(errorLabel, .lessThanOrEqualTo, constant: 40)
            .toBottomOf(dottedView, .greaterThanOrEqualTo, constant: 40)
        
        termsAndCondtionsLabel
            .alignEdge(.left, withView: view, constant: 70)
            .toBottomOf(pinKeyboard, .lessThanOrEqualTo, constant: 25)
            .toBottomOf(pinKeyboard, .greaterThanOrEqualTo, constant: 10)
            .height(constant: UIScreen.screenType == .iPhone5 || UIScreen.screenType == .iPhone6 ? 30 : 34)
            .centerHorizontallyInSuperview()
        
        let bottomSafeArea: CGFloat = (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) == 0 ? 18 : 12
        createPINButton
            .toBottomOf(termsAndCondtionsLabel, constant: 16)
            .centerHorizontallyInSuperview()
            .height(constant: UIScreen.screenType == .iPhone5 || UIScreen.screenType == .iPhone6 ? 50 : 52)
            .width(constant: 200)
            .alignEdgeWithSuperviewSafeArea(.bottom,
                                            constant: bottomSafeArea)
        
    }
}

// MARK: - Bind
fileprivate extension PINViewController {
    func bind() {
        viewModel.outputs.pinText.map{ $0?.string.count ?? 0 }.bind(to: dottedView.rx.characters).disposed(by: disposeBag)
        
        viewModel.outputs.pinValid.bind(to: createPINButton.rx.isEnabled).disposed(by: disposeBag)
        createPINButton.rx.tap.bind(to: viewModel.inputs.actionObserver).disposed(by: disposeBag)
        
        pinKeyboard.rx.output.bind(to: viewModel.inputs.pinChangeObserver).disposed(by: disposeBag)
        
        viewModel.outputs.error.bind(to: errorLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.pinText.map { _ -> String? in nil }.bind(to: errorLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.outputs.enableBack
            .subscribe(onNext: { [unowned self] in
                if $0.0 {
                    self.addBackButton($0.1, backgroundColor: .blue, tintColor: .white)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.shake
            .subscribe(onNext: { [unowned self] in
                self.dottedView.animate([Animation.shake(duration: 0.1)])
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.hideNavigationBar.subscribe(onNext: {[weak self] in
            self?.hideNavigationBar = $0
        }).disposed(by: disposeBag)
    }
    
    func bindTranslations() {
        viewModel.outputs.headingText.bind(to: headingLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.termsAndConditionsText.subscribe(onNext: {[weak self] in
            if $0 == nil { self?.termsAndCondtionsLabel.isHidden = true }
            self?.termsAndCondtionsLabel.attributedText = $0
        }).disposed(by: disposeBag)
        viewModel.outputs.actionTitle.bind(to: createPINButton.rx.title()).disposed(by: disposeBag)
    }
}
