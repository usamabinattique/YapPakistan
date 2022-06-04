//
//  YAPItViewController.swift
//  YAP
//
//  Created by Zain on 01/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme

class YAPItViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var yapItButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(UIImage.init(named: "icon_tabbar_yapit", in: .yapPakistan, compatibleWith: nil), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var addMoney: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.alpha = 0
        button.setImage(UIImage.init(named: "icon_home_add", in: .yapPakistan, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var payBillsButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.alpha = 0
        button.setImage(UIImage.init(named: "icon_bills", in: .yapPakistan, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var sendMoneyButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.alpha = 0
        button.setImage(UIImage.init(named: "icon_send_money", in: .yapPakistan, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var addMoneyLabel = UIFactory.makeLabel(font: .small, alignment: .center, text: "screen_yap_it_button_add_money".localized)

    private lazy var payBillsLabel: UILabel = UIFactory.makeLabel(font: .small, alignment: .center, text: "screen_yap_it_button_pay_bills".localized)

    private lazy var sendMoneyLabel: UILabel = UIFactory.makeLabel(font: .small, alignment: .center, text: "screen_yap_it_button_send_money".localized)
    
    // MARK: Properties
    private var viewModel: YAPItViewModelType!
    private var themeService: ThemeService<AppTheme>!
    private let disposeBag = DisposeBag()
    private var tabBarHeight: CGFloat = 0
    
    // MARK: Initialization
    init(viewModel: YAPItViewModelType, themeService: ThemeService<AppTheme>, tabBarHeight: CGFloat) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.themeService = themeService
        self.tabBarHeight = tabBarHeight
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: View cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white.withAlphaComponent(0)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
        
        payBillsLabel.isHidden = true
        payBillsButton.isHidden = true
        
        setupViews()
        setupTheme()
        setupConstraints()
        bindViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAnimation()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        yapItButton.roundView()
        addMoney.roundView()
        payBillsButton.roundView()
        sendMoneyButton.roundView()
    }
    
    // MARK: Action
    
    @objc
    private func tapped(_ tap: UITapGestureRecognizer) {
        hideAnimations(3)
    }
    
}

// MARK: Veiw setup

private extension YAPItViewController {
    
    func setupViews() {
        view.addSubview(yapItButton)
        view.addSubview(addMoney)
        view.addSubview(payBillsButton)
        view.addSubview(sendMoneyButton)
        view.addSubview(addMoneyLabel)
        view.addSubview(payBillsLabel)
        view.addSubview(sendMoneyLabel)
        
        addMoneyLabel.alpha = 0
        payBillsLabel.alpha = 0
        sendMoneyLabel.alpha = 0
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.primary) }, to: [addMoney.rx.backgroundColor])
            .bind({ UIColor($0.primary) }, to: [payBillsButton.rx.backgroundColor])
            .bind({ UIColor($0.primary) }, to: [sendMoneyButton.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark) }, to: [addMoneyLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [payBillsLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [sendMoneyLabel.rx.textColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupConstraints() {
        yapItButton
            .centerHorizontallyInSuperview()
            .width(constant: 94)
            .height(constant: 94)
            .alignEdgeWithSuperview(.bottom, constant: (tabBarHeight + 30) - 94)
        
        payBillsButton
            .alignEdgeWithSuperviewSafeArea(.bottom)
            .centerHorizontallyInSuperview()
            .width(constant: 54)
            .height(constant: 54)
        
        payBillsLabel
            .toBottomOf(payBillsButton, constant: 8)
            .alignEdge(.centerX, withView: payBillsButton)
        
        addMoney
            .alignEdgeWithSuperviewSafeArea(.bottom)
            .toLeftOf(payBillsButton, constant: 35)
            .alignEdge(.width, withView: payBillsButton)
            .alignEdge(.height, withView: payBillsButton)
        
        addMoneyLabel
            .toBottomOf(addMoney, constant: 8)
            .alignEdge(.centerX, withView: addMoney)
        
        sendMoneyButton
            .alignEdgeWithSuperviewSafeArea(.bottom)
            .toRightOf(payBillsButton, constant: 35)
            .alignEdge(.width, withView: payBillsButton)
            .alignEdge(.height, withView: payBillsButton)
        
        sendMoneyLabel
            .toBottomOf(sendMoneyButton, constant: 8)
            .alignEdge(.centerX, withView: sendMoneyButton)
    }
}

// MARK: Binding

private extension YAPItViewController {
    func bindViews() {
        
        Observable.merge(addMoney.rx.tap.map { 0 }, payBillsButton.rx.tap.map { 1 }, sendMoneyButton.rx.tap.map { 2 }, yapItButton.rx.tap.map { 3 }).subscribe(onNext: { [weak self] in
            self?.hideAnimations($0)
        }).disposed(by: disposeBag)
    }
}

// MARK: Animations

private extension YAPItViewController {
    func showAnimation() {
        UIView.animate(withDuration: 0.33, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 8, options: .curveEaseInOut, animations: {
            self.view.backgroundColor = UIColor.white.withAlphaComponent(1)
            self.yapItButton.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi))
        })
        
        UIView.animate(withDuration: 0.33, delay: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: .curveEaseInOut, animations: {
            var frame = self.addMoney.frame
            frame.origin.y = self.yapItButton.frame.origin.y - 40 - frame.size.height
            self.addMoney.frame = frame
            self.addMoney.alpha = 1
            
            var labelFrame = self.addMoneyLabel.frame
            labelFrame.origin.y = frame.origin.y + frame.size.height + 8
            self.addMoneyLabel.frame = labelFrame
            self.addMoneyLabel.alpha = 1
        })
        
        UIView.animate(withDuration: 0.33, delay: 0.4, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: .curveEaseInOut, animations: {
            var frame = self.payBillsButton.frame
            frame.origin.y = self.yapItButton.frame.origin.y - 125 - frame.size.height
            self.payBillsButton.frame = frame
            self.payBillsButton.alpha = 1
            
            var labelFrame = self.payBillsLabel.frame
            labelFrame.origin.y = frame.origin.y + frame.size.height + 8
            self.payBillsLabel.frame = labelFrame
            self.payBillsLabel.alpha = 1
        })
        
        UIView.animate(withDuration: 0.33, delay: 0.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: .curveEaseInOut, animations: {
            var frame = self.sendMoneyButton.frame
            frame.origin.y = self.yapItButton.frame.origin.y - 40 - frame.size.height
            self.sendMoneyButton.frame = frame
            self.sendMoneyButton.alpha = 1
            
            var labelFrame = self.sendMoneyLabel.frame
            labelFrame.origin.y = frame.origin.y + frame.size.height + 8
            self.sendMoneyLabel.frame = labelFrame
            self.sendMoneyLabel.alpha = 1
        })
    }
    
    func hideAnimations(_ type: Int) {
        yapItButton.isUserInteractionEnabled = false
        addMoney.isUserInteractionEnabled = false
        sendMoneyButton.isUserInteractionEnabled = false
        payBillsButton.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.5) {
            self.view.backgroundColor = UIColor.white.withAlphaComponent(0)
        }
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 8, options: .curveEaseInOut, animations: {
            self.yapItButton.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        })
        
        UIView.animate(withDuration: 0.3, delay: 0.05, animations: {
            var frame = self.addMoney.frame
            frame.origin.y = self.view.bounds.height - self.view.safeAreaInsets.bottom - frame.size.height
            self.addMoney.frame = frame
            self.addMoney.alpha = 0
            
            var labelFrame = self.addMoneyLabel.frame
            labelFrame.origin.y = frame.origin.y + frame.size.height + 8
            self.addMoneyLabel.frame = labelFrame
            self.addMoneyLabel.alpha = 0
        })
        
        UIView.animate(withDuration: 0.3, delay: 0.1, animations: {
            var frame = self.payBillsButton.frame
            frame.origin.y = self.view.bounds.height - self.view.safeAreaInsets.bottom - frame.size.height
            self.payBillsButton.frame = frame
            self.payBillsButton.alpha = 0
            
            var labelFrame = self.payBillsLabel.frame
            labelFrame.origin.y = frame.origin.y + frame.size.height + 8
            self.payBillsLabel.frame = labelFrame
            self.payBillsLabel.alpha = 0
        })
        
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            var frame = self.sendMoneyButton.frame
            frame.origin.y = self.view.bounds.height - self.view.safeAreaInsets.bottom - frame.size.height
            self.sendMoneyButton.frame = frame
            self.sendMoneyButton.alpha = 0
            
            var labelFrame = self.sendMoneyLabel.frame
            labelFrame.origin.y = frame.origin.y + frame.size.height + 8
            self.sendMoneyLabel.frame = labelFrame
            self.sendMoneyLabel.alpha = 0
        }) { (completed) in
            guard completed else { return }
            
            switch type {
            case 0:
                self.viewModel.inputs.addMoneyObserver.onNext(())
            case 1:
                self.viewModel.inputs.payBillsObserver.onNext(())
            case 2:
                self.viewModel.inputs.sendMoneyObserver.onNext(())
            default:
                self.viewModel.inputs.hideObserver.onNext(())
            }
        }
    }
}
