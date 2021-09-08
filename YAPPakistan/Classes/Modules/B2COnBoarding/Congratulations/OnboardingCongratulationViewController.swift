//
//  CongratulationViewController.swift
//  YAP
//
//  Created by Muhammad Hassan on 02/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import YAPComponents
import RxSwift


public class OnboardingCongratulationViewController: UIViewController {
    
    lazy var marginLayout: UILayoutGuide = {
        return view.layoutMarginsGuide
    }()
    
    lazy var safeAreaHeight: CGFloat = {
        return view.bounds.height - (view.safeAreaInsets.top + view.safeAreaInsets.bottom)
    }()
    
    lazy var rowHeight: CGFloat = {
        return safeAreaHeight / rowHeightDivisor()
    }()
    
    lazy var headingLabel: MarqueeLabel = {
        let label = MarqueeLabel()
        label.textAlignment = .center
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        label.font = UIFont.appFont(forTextStyle: .title2)
        label.textColor = .blue //.appColor(ofType: .primaryDark)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.type = .continuous
        label.speed = .duration(8.0)
        label.fadeLength = 10.0
        return label
    }()
    
    lazy var headingLabelCenterYConstraint: NSLayoutConstraint = {
        headingLabel.sizeToFit()
        let constraint = headingLabel.topAnchor.constraint(equalTo: marginLayout.topAnchor, constant: (safeAreaHeight / 2.3))
        constraint.isActive = true
        return constraint
    }()
    
    lazy var subheadingLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.appFont(forTextStyle: .regular)
        label.textColor = .darkGray //.appColor(ofType: .greyDark)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        return label
    }()
    
    lazy var subheadingLabelCenterYConstraint: NSLayoutConstraint = {
        subheadingLabel.sizeToFit()
        let constraint = subheadingLabel.topAnchor.constraint(equalTo: marginLayout.topAnchor, constant: (safeAreaHeight / 1.9) + rowHeight)
        constraint.isActive = true
        return constraint
    }()
    
    lazy var paymentCardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.alpha = 0
        imageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        imageView.image = UIImage(named: "image_payment_card_white", in: .yapPakistan)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - IBAN Header
    lazy var ibanHeaderLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.appFont(forTextStyle: .small)
        label.textColor = .darkGray //UIColor.appColor(ofType: .greyDark)
        label.text = "screen_onboarding_congratulations_display_text_iban".localized
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var ibanHeaderLabelTopConstraint: NSLayoutConstraint = {
        let constraint = ibanHeaderLabel.topAnchor.constraint(equalTo: paymentCardImageView.bottomAnchor, constant: 100)
        constraint.isActive = true
        return constraint
    }()
    
    // MARK: - IBAN
    lazy var ibanLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(forTextStyle: .regular)
        label.textColor = .blue //.appColor(ofType: .primary)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - IBAN view
    lazy var ibanView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 44).isActive = true
        view.clipsToBounds = true
        view.alpha = 0
        view.backgroundColor = UIColor.lightGray //.appColor(ofType: .greyLight).withAlphaComponent(0.5)
        view.layer.cornerRadius = 22
        
        let label = ibanLabel
        view.addSubview(label)
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: label.trailingAnchor).isActive = true
        
        return view
    }()
    
    lazy var ibanViewTopConstraint: NSLayoutConstraint = {
        let constraint = ibanView.topAnchor.constraint(equalTo: ibanHeaderLabel.bottomAnchor, constant: 100)
        constraint.isActive = true
        return constraint
    }()
    
    // MARK: - Footnote
    lazy var footnoteLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.appFont(forTextStyle: .small)
        label.textColor = UIColor.darkGray //.appColor(ofType: .greyDark)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text =  footNoteText()
        label.alpha = 0
        return label
    }()
    
    lazy var footnoteTopConstraint: NSLayoutConstraint = {
        let constraint = footnoteLabel.topAnchor.constraint(equalTo: ibanView.bottomAnchor, constant: 50)
        constraint.isActive = true
        return constraint
    }()
    
    // MARK: - Complete Verification Button
    lazy var completeVerificationButton: AppRoundedButton = {
        let button = AppRoundedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        button.setTitle( actionButtonText() , for: .normal)
        button.alpha = 0
        return button
    }()
    
    lazy var completeVerificationButtonTopConstraint: NSLayoutConstraint = {
        let constraint = completeVerificationButton.topAnchor.constraint(equalTo: footnoteLabel.bottomAnchor, constant: 142)
        constraint.isActive = true
        return constraint
    }()
    
    // MARK: - Properties
    var viewModel: OnboardingCongratulationViewModelType!
    
    // MARK: - Initialization
    
    init(viewModel: OnboardingCongratulationViewModelType) {
        super.init(nibName: nil, bundle: nil)
        //self.viewModel = viewModel
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - View Life Cycle
    override public func viewDidLoad() {
       // super.viewDidLoad()
        
        setup()
        style()
        localize()
        bind()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func setup() {
        _ = rowHeight
        animateHeading()
        animateSubheading()
        animatePaymentCard()
        animateIBANHeader()
        animateIBANView()
        animateFootnote()
        animateCompleteVerificationButton()
    }
    
    func addFootnoteTopConstraint() -> NSLayoutConstraint {
        return footnoteTopConstraint
    }
    
    func rowHeightDivisor() -> CGFloat {
        return 100
    }
    
    func footNoteText() -> String {
        return "screen_onboarding_congratulations_display_text_meeting_note".localized
    }
    
    func actionButtonText() -> String {
        "screen_onboarding_congratulations_button_complete_verification".localized
    }
}

// MARK: - Setup
extension OnboardingCongratulationViewController {
    
    
    
    fileprivate func setupUI() {
        
    }
    
    func animateHeading() {
        view.backgroundColor = .white
        
        view.addSubview(headingLabel)
        _ = headingLabelCenterYConstraint
        headingLabel.centerXAnchor.constraint(equalTo: marginLayout.centerXAnchor).isActive = true
        headingLabel.leadingAnchor.constraint(equalTo: marginLayout.leadingAnchor).isActive = true
        marginLayout.trailingAnchor.constraint(equalTo: headingLabel.trailingAnchor).isActive = true
        view.layoutIfNeeded()
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0,
                       options: [.curveEaseOut],
                       animations: {
                self.headingLabel.alpha = 1
                self.headingLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (_) in }
        
        UIView.animate(withDuration: 1,
                       delay: 2.2,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: [.curveEaseOut],
                       animations: {
                self.headingLabelCenterYConstraint.constant = self.rowHeight
                self.view.layoutIfNeeded()
        }) { (_) in
            //            self.headingLabel.restartLabel()
            //            self.headingLabel.type = .continuous
            //            self.headingLabel.speed = .duration(8.0)
            //            self.headingLabel.fadeLength = 10.0
        }
    }
    
    func animateSubheading() {
        view.addSubview(subheadingLabel)
        _ = subheadingLabelCenterYConstraint
        subheadingLabel.centerXAnchor.constraint(equalTo: marginLayout.centerXAnchor).isActive = true
        subheadingLabel.leadingAnchor.constraint(equalTo: marginLayout.leadingAnchor).isActive = true
        marginLayout.trailingAnchor.constraint(equalTo: subheadingLabel.trailingAnchor).isActive = true
        view.layoutIfNeeded()
        bindTimeInterval()
        UIView.animate(withDuration: 1,
                       delay: 0.8,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0,
                       options: [.curveEaseOut],
                       animations: { [weak self] in
                guard let `self` = self else { return }
                self.subheadingLabel.alpha = 1
                self.subheadingLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (_) in }
        
        UIView.animate(withDuration: 1,
                       delay: 2.5,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: [.curveEaseOut],
                       animations: { [weak self] in
                guard let `self` = self else { return }
                self.subheadingLabelCenterYConstraint.constant = self.rowHeight * 8
                self.view.layoutIfNeeded()
        }) { (_) in }
    }
    
    func animatePaymentCard() {
        view.addSubview(paymentCardImageView)
        paymentCardImageView.topAnchor.constraint(equalTo: subheadingLabel.bottomAnchor, constant: rowHeight).isActive = true
        paymentCardImageView.centerXAnchor.constraint(equalTo: marginLayout.centerXAnchor).isActive = true
        paymentCardImageView.heightAnchor.constraint(equalTo: marginLayout.heightAnchor, multiplier: rowHeight / 18).isActive = true
        paymentCardImageView.heightAnchor.constraint(equalTo: paymentCardImageView.widthAnchor, multiplier: 233 / 322).isActive = true
        paymentCardImageView.animate(inParallel: [
            .fadeIn(duration: 1.5, delay: 2.7),
            .scale(to: CGAffineTransform(scaleX: 1, y: 1), delay: 2.7, duration: 1.5, springWithDamping: 0.5, initialSpringVelocity: 5)
            ])
    }
    
    fileprivate func animateIBANHeader() {
        view.addSubview(ibanHeaderLabel)
        ibanHeaderLabel.centerXAnchor.constraint(equalTo: marginLayout.centerXAnchor).isActive = true
        _ = ibanHeaderLabelTopConstraint
        view.layoutIfNeeded()
        ibanHeaderLabel.animate([
            .fadeIn(duration: 1, delay: 3)
            ])
        
        UIView.animate(withDuration: 2,
                       delay: 3,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0,
                       options: [.curveEaseOut],
                       animations: { [weak self] in
                guard let `self` = self else { return }
                self.ibanHeaderLabelTopConstraint.constant = 0 //self.rowHeight * 1.2
                self.view.layoutIfNeeded()
        }) { (_) in }
    }
    
    fileprivate func animateIBANView() {
        view.addSubview(ibanView)
        ibanView.centerXAnchor.constraint(equalTo: marginLayout.centerXAnchor).isActive = true
        _ = ibanViewTopConstraint
        ibanView.leadingAnchor.constraint(equalTo: marginLayout.leadingAnchor, constant: 15).isActive = true
        marginLayout.trailingAnchor.constraint(equalTo: ibanView.trailingAnchor, constant: 15).isActive = true
        view.layoutIfNeeded()
        ibanView.animate([
            .fadeIn(duration: 1, delay: 3.3)
            ])
        
        UIView.animate(withDuration: 2,
                       delay: 3.3,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0,
                       options: [.curveEaseOut],
                       animations: { [weak self] in
                guard let `self` = self else { return }
                self.ibanViewTopConstraint.constant = self.rowHeight * 2.5
                self.view.layoutIfNeeded()
        }) { (_) in }
    }
    
    func animateFootnote() {
        view.addSubview(footnoteLabel)
        footnoteLabel.centerXAnchor.constraint(equalTo: marginLayout.centerXAnchor).isActive = true
        let topConstraint = addFootnoteTopConstraint()
        footnoteLabel.leadingAnchor.constraint(equalTo: marginLayout.leadingAnchor, constant: 15).isActive = true
        marginLayout.trailingAnchor.constraint(equalTo: footnoteLabel.trailingAnchor, constant: 15).isActive = true
        view.layoutIfNeeded()
        footnoteLabel.animate([
            .fadeIn(duration: 1, delay: 3.6)
            ])
        UIView.animate(withDuration: 2,
                       delay: 3.6,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0,
                       options: [.curveEaseOut],
                       animations: { [weak self] in
                guard let `self` = self else { return }
                topConstraint.constant = self.rowHeight * 3.8
                self.view.layoutIfNeeded()
        }) { (_) in }
    }
    
    func animateCompleteVerificationButton() {
        view.addSubview(completeVerificationButton)
        completeVerificationButton.centerXAnchor.constraint(equalTo: marginLayout.centerXAnchor).isActive = true
        _ = completeVerificationButtonTopConstraint
        completeVerificationButton.leadingAnchor.constraint(equalTo: marginLayout.leadingAnchor, constant: 15).isActive = true
        marginLayout.trailingAnchor.constraint(equalTo: completeVerificationButton.trailingAnchor, constant: 15).isActive = true
        view.layoutIfNeeded()
        completeVerificationButton.animate([
            .fadeIn(duration: 1, delay: 3.9)
            ])
        UIView.animate(withDuration: 2,
                       delay: 3.9,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0,
                       options: [.curveEaseOut],
                       animations: { [weak self] in
                guard let `self` = self else { return }
                self.completeVerificationButtonTopConstraint.constant = self.rowHeight * 3.8
                self.view.layoutIfNeeded()
        }) { (_) in }
    }
    
    fileprivate func style() {
        
    }
    
    fileprivate func localize() {
        
    }
}

// MARK: - Bind
extension OnboardingCongratulationViewController {
    fileprivate func bind() {
        bindName()
        bindTimeInterval()
        bindIBAN()
        bindCompleteVerification()
    }
    
    fileprivate func bindName() {
         viewModel.outputs.name.map { String(format:  "screen_onboarding_congratulations_display_text_title".localized, $0) }.bind(to: headingLabel.rx.text).disposed(by: rx.disposeBag)
    }
    
    fileprivate func bindTimeInterval() {
         viewModel.outputs.onboardingInterval.subscribe(onNext: { [weak self] interval in
            if interval > 60 || interval <= 0 {
                self?.subheadingLabel.text =  "screen_onboarding_congratulations_display_text_sub_title_no_interval".localized
                self?.subheadingLabel.sizeToFit()
            } else {
                let secondsInString = String(format: "%.0f", ceil(interval))
                let maxValue = Int(secondsInString)!
                let attributedString = NSMutableAttributedString(string: String(format:  "screen_onboarding_congratulations_display_text_sub_title".localized, secondsInString), attributes: [
                    .font: UIFont.systemFont(ofSize: 16.0, weight: .regular)//,
                    //.foregroundColor: UIColor.appColor(ofType: .greyDark)
                    ])
                attributedString.addAttributes([
                    .font: UIFont.systemFont(ofSize: 16.0, weight: .medium) //,
                    //.foregroundColor: UIColor.appColor(ofType: .primaryDark)
                    ], range: NSRange(location: 61, length: 9 + secondsInString.count))
                self?.subheadingLabel.attributedText = attributedString
                self?.subheadingLabel.sizeToFit()
                self?.subheadingLabel.animateCountDown(labels: Array((maxValue > 30 ? maxValue - 30 : 9)...maxValue).map({ String(format: "%02d", $0) }), withDuration: 2, inRange: NSRange(location: 61, length: secondsInString.count))
            }
        }).disposed(by: rx.disposeBag)
    }
    
    fileprivate func bindIBAN() {
        viewModel.outputs.iban.bind(to: ibanLabel.rx.text).disposed(by: rx.disposeBag)
    }
    
    fileprivate func bindCompleteVerification() {
         completeVerificationButton.rx.tap.bind(to: viewModel.inputs.completeVerificationObserver).disposed(by: rx.disposeBag) 
    }
}
