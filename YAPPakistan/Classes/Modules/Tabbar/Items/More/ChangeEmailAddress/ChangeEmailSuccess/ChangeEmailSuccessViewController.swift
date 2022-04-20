//
//  ChangeEmailSuccessViewController.swift
//  YAPPakistan
//
//  Created by Awais on 20/04/2022.
//

import UIKit
import RxSwift
import RxTheme
import RxCocoa
import YAPComponents

class UnvarifiedEmailSuccessViewController: UIViewController {
    
    // MARK: - Init
    init(viewModel: UnvarifiedEmailSuccessViewModelType, themeService: ThemeService<AppTheme>) {
        self.themeService = themeService
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Views
    private lazy var headingLabel: UILabel = UIFactory.makeLabel(font: .title2, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping ) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .title2, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)
    private lazy var subHeadingLabel: UILabel = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0)
    
    
    
    //UILabelFactory.createUILabel(with: .greyDark, textStyle: .regular, alignment: .center, numberOfLines: 0)
    //private lazy var descriptionLabel: UILabel = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .regular, alignment: .center, numberOfLines: 0)
    
    
    private lazy var successImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var back = AppRoundedButtonFactory.createAppRoundedButton(title: "common_button_next".localized, isEnable: true)
    
    // MARK: - Properties
    private var themeService: ThemeService<AppTheme>
    let viewModel: UnvarifiedEmailSuccessViewModelType
    let disposeBag: DisposeBag
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
        //bindMailAppOption()
        hideBackButton()
    }
    
#warning("need to set the status bar colors properly in ViewWillAppear & viewWillDisappear")
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.barStyle = .black //SessionManager.current.currentAccountType == .household ? .black : .default
    }
}

// MARK: - Setup
fileprivate extension UnvarifiedEmailSuccessViewController {
    func setup() {
        setupViews()
        setupTheme()
        setupConstraints()
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark        ) }, to: [headingLabel.rx.textColor])
            .bind({ UIColor($0.primary        ) }, to: [back.rx.enabledBackgroundColor])
            //.bind({ UIColor($0.greyDark       ) }, to: [descriptionLabel.rx.textColor])
    }
    
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(headingLabel)
        view.addSubview(subHeadingLabel)
        view.addSubview(successImageView)
        //view.addSubview(descriptionLabel)
        //view.addSubview(mailActionButton)
        view.addSubview(back)
    }
    
    func setupConstraints() {
        headingLabel
            .alignEdgeWithSuperviewSafeArea(.top, constant: 40)
            .alignEdgesWithSuperview([.left, .right], constants: [30, 30])
        
        subHeadingLabel
            .toBottomOf(headingLabel, constant: 10)
            .alignEdgesWithSuperview([.left, .right], constants: [29, 29])
        
        successImageView
            .toBottomOf(subHeadingLabel, .lessThanOrEqualTo, constant: 60)
            .height(.lessThanOrEqualTo, constant: 193)
            .alignEdgesWithSuperview([.left, .right], constants: [59, 59])
        
        //descriptionLabel
//            .toBottomOf(successImageView, .lessThanOrEqualTo, constant: 55)
//            .alignEdgesWithSuperview([.left, .right], constants: [33, 33])
            //.toTopOf(mailActionButton, .greaterThanOrEqualTo, constant: 20)
        
//        mailActionButton
//            .toTopOf(back, constant: 10)
//            .centerHorizontallyInSuperview()
//            .height(constant: 52)
//            .width(constant: 192)
        
        back
            .centerHorizontallyInSuperview()
            .width(constant: 192)
            .height(constant: 52)
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 15)
    }
}

// MARK: - Bind
fileprivate extension UnvarifiedEmailSuccessViewController {
    func bind() {
        viewModel.outputs.heading.bind(to: headingLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.subHeading.bind(to: subHeadingLabel.rx.attributedText).disposed(by: disposeBag)
        viewModel.outputs.successImeg.bind(to: successImageView.rx.image).disposed(by: disposeBag)
        //viewModel.outputs.mailButtonTitle.bind(to: mailActionButton.rx.title(for: .normal)).disposed(by: disposeBag)
        //mailActionButton.rx.tap.bind(to: viewModel.inputs.mailActionObserver).disposed(by: disposeBag)
        viewModel.outputs.backTitle.bind(to: back.rx.title(for: .normal)).disposed(by: disposeBag)
        back.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: disposeBag)
        //viewModel.outputs.description.bind(to: descriptionLabel.rx.text).disposed(by: disposeBag)
    }
    
//    func bindMailAppOption() {
//        viewModel.outputs.suggestMailAppOptions.unwrap().subscribe(onNext: { options in
//            self.showMailOptions(options: options)
//        }).disposed(by: disposeBag)
//    }
}
