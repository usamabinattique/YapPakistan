//
//  WelcomeScreenViewController.swift
//  App
//
//  Created by Uzair on 10/06/2021.
//

import UIKit
import RxCocoa
import RxSwift
import YAPComponents
/*
class WelcomeScreenViewController: UIViewController {
    
    //with: .primaryDark
    private lazy var headerLabel : UILabel = UIFactory.makeLabel( textStyle: .title2, alignment:.center, numberOfLines: 2, text: "Welcome to Business Banking Made Better", alpha: 1, adjustFontSize: true)
    
    //with: .greyDark,
    private lazy var poweredByLabel : UILabel = UIFactory.makeLabel(textStyle: .small, alignment: .center, text: "Powered by")
    
    
    private lazy var logoEDBImage = UIFactory.makeImageView(image: BundleYapPak.image("EDB_Logo_Blue"), contentMode: .scaleAspectFit)
    
    
    private lazy var logoYAPImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "yap_logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var signInLabel: UIButton = {
        let label = UIButton()
        label.titleLabel?.font = UIFont.appFont(forTextStyle: .regular)
        label.setTitleColor(UIColor.appColor(ofType: .greyDark), for: .normal)
        let text =  "screen_home_display_text_sign_in".localized
        let signIn = text.components(separatedBy: "?").last ?? ""
        let attributed = NSMutableAttributedString(string: text)
        attributed.addAttribute(.foregroundColor, value: UIColor.primary, range: NSRange(location: text.count - signIn.count, length: signIn.count))
        attributed.addAttribute(.foregroundColor, value: UIColor.greyDark, range: NSRange(location: 0, length: text.count - signIn.count))
        label.setAttributedTitle(attributed, for: .normal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var getStartedButton: UIButton = {
        let button = UIButton()
        button.setTitle("screen_welcome_button_get_started".localized, for: .normal)
        button.backgroundColor = .primary
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 26
        button.titleLabel?.font = UIFont.appFont(forTextStyle: .large,weight: .medium)
        return button
    }()
    
//    private lazy var bottomImage: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.image = UIImage(named: "bottom")
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
    
    var viewModel: WelcomeScreenViewModelType!
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubViews()
        setupConstraints()
        bindViews()
    }
}

// MARK: View setup

private extension WelcomeScreenViewController {
    
    func setupSubViews() {
        view.backgroundColor = .white
        view.addSubview(headerLabel)
        view.addSubview(logoEDBImage)
        view.addSubview(poweredByLabel)
        view.addSubview(logoYAPImage)
        view.addSubview(getStartedButton)
        view.addSubview(signInLabel)
//        view.addSubview(bottomImage)
    }
    
    func setupConstraints() {
        
        let height = view.frame.height
        let width = view.frame.width
        
        headerLabel
            .alignEdgeWithSuperviewSafeArea(.top, constant: height * 0.020)
            .alignEdgesWithSuperview([.left, .right], constants: [30, 30])
            .centerHorizontallyInSuperview()
        
        logoEDBImage
            .toBottomOf(headerLabel, constant:60)
            .height(constant: height * 0.123)
            .width(constant: width * 0.432)
            .centerHorizontallyInSuperview()
        
        poweredByLabel
            .toBottomOf(logoEDBImage, constant:height * 0.070)
            .centerHorizontallyInSuperview()
        
        logoYAPImage
            .toBottomOf(poweredByLabel, constant:8)
            .height(constant: 29)
            .width(constant: 79)
            .centerHorizontallyInSuperview()
        
        getStartedButton
            .toTopOf(signInLabel, constant: 24)
            .width(constant: 210)
            .height(constant: 52)
            .centerHorizontallyInSuperview()
    
        signInLabel
            .alignEdgeWithSuperview(.bottom, constant: height * 0.045)
            .width(constant: view.bounds.size.width)
            .height(constant: 24)
            .centerHorizontallyInSuperview()
        
//        bottomImage
//            .alignEdgesWithSuperview([.left, .right], constants: [0, 0])
//            .centerHorizontallyInSuperview()
//            .alignEdgeWithSuperview(.bottom, constant: 0)
    }
}

// MARK: Binding

private extension WelcomeScreenViewController {
    
    func bindViews() {
        getStartedButton.rx.tap.bind(to: viewModel.inputs.getStartedObserver).disposed(by: disposeBag)
        signInLabel.rx.tap.bind(to: viewModel.inputs.signInObserver).disposed(by: disposeBag)
    }
}
*/
