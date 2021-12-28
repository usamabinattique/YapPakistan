//
//  ReportCardViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 26/12/2021.
//

import UIKit
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme

class ReportCardViewController : UIViewController {
    
    //MARK: - Views
    
    private lazy var closeBarButtonItem = barButtonItem(image: UIImage(named: "icon_close", in: .yapPakistan), insectBy:.zero)
    
    lazy var optionPickerCollectionView: CardOptionPickerCollectionView = {
        let collectionView = CardOptionPickerCollectionView()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    lazy var paymentCardImageView = UIFactory.makeImageView()
    lazy var cardPlanLabel = UIFactory.makeLabel(font: .micro)
    lazy var panNumberLabel = UIFactory.makeLabel(font: .micro)
    lazy var securedByYAPImageView = UIFactory.makeImageView()
    lazy var cardInfoStackView = UIFactory.makeStackView(axis: .vertical, alignment: .center, distribution: .fill, spacing: 5)
    lazy var noteLabel = UIFactory.makeLabel(font: .small)
    lazy var footnoteLabel = UIFactory.makeLabel()
    lazy var blockReportButton = UIFactory.makeAppRoundedButton(with: .regular, title: "")
    lazy var paymentCardBlockOptionsLabel = UIFactory.makeLabel()
    lazy var contentStackView = UIFactory.makeStackView(axis: .vertical, alignment: .center, distribution: .fill, spacing: 30)
    lazy var bottomPaddingView = UIFactory.makeView()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    //MARK: - Properties
    let viewModel: ReportCardViewModelType
    let themeService: ThemeService<AppTheme>
    
    
    //MARK: - initialization
    init(themeService: ThemeService<AppTheme>, viewModel: ReportCardViewModelType){
        
        self.themeService = themeService
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubViews()
        setupResources()
        setupTheme()
        setupLocalizedStrings()
        setupBindings()
        setupConstraints()
    }
    
    @objc internal override func onTapBackButton() {
        self.dismiss(animated: true, completion: nil)
//        viewModel.inputs.closeObserver.onNext(())
    }
}

fileprivate extension ReportCardViewController {
    func setupSubViews() {
        navigationItem.leftBarButtonItem = closeBarButtonItem.barItem
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
//        footnoteLabel.backgroundColor = UIColor.secondaryMagenta.withAlphaComponent(0.12)
        footnoteLabel.clipsToBounds = true
        footnoteLabel.layer.cornerRadius = 12
//        footnoteLabel.edgeInset = 20
        
        cardInfoStackView.addArrangedSubview(cardPlanLabel)
        cardInfoStackView.addArrangedSubview(panNumberLabel)
        cardInfoStackView.addArrangedSubview(securedByYAPImageView)
        
        contentStackView.addArrangedSubview(paymentCardImageView)
        contentStackView.addArrangedSubview(cardInfoStackView)
        contentStackView.addArrangedSubview(paymentCardBlockOptionsLabel)
        contentStackView.addArrangedSubview(optionPickerCollectionView)
        contentStackView.addArrangedSubview(noteLabel)
        contentStackView.addArrangedSubview(footnoteLabel)
        contentStackView.addArrangedSubview(blockReportButton)
        contentStackView.addArrangedSubview(bottomPaddingView)
    }
    
    func setupConstraints() {
        paymentCardImageView.height(constant: view.bounds.height * 0.274)
        bottomPaddingView.height(constant: 0)

        optionPickerCollectionView.height(constant: 120).alignEdgesWithSuperview([.left, .right])

        contentStackView.alignEdgesWithSuperview([.left, .top, .right, .bottom], constants: [20, 20, 0, 0])
            .width(with: .width, ofView: scrollView, constant: -40)

        scrollView.alignEdgesWithSuperview([.left, .safeAreaTop, .right, .bottom])
        scrollView.height(with: .height, ofView: view)
        .width(with: .width, ofView: view)

        blockReportButton.alignEdgesWithSuperview([.left, .right], constant: 50)
            .height(constant: 150)
    }
    
    func setupBindings(){
        
        viewModel.outputs.title.bind(to: self.rx.title).disposed(by: rx.disposeBag)
        viewModel.outputs.cardPlan.bind(to: cardPlanLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.panNumber.bind(to: panNumberLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.note.bind(to: noteLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.footNote.bind(to: footnoteLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.cardBlockOptionsTitle.bind(to: paymentCardBlockOptionsLabel.rx.text).disposed(by: rx.disposeBag)
        
        //Bind payment card blocking option
        viewModel.outputs.cardBlockOptions.bind(to: optionPickerCollectionView.rx.paymentCardOptionsObserver).disposed(by: rx.disposeBag)
        optionPickerCollectionView.rx.modelSelected.bind(to: viewModel.inputs.selectedCardBlockOption).disposed(by: rx.disposeBag)
        
        viewModel.outputs.blockButtonTitle.bind(to: blockReportButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        viewModel.outputs.isBlockButtonEnabled.bind(to: blockReportButton.rx.isEnabled).disposed(by: rx.disposeBag)
        blockReportButton.rx.tap.bind(to: viewModel.inputs.blockButtonTapObserver).disposed(by: rx.disposeBag)
        
        bindAlertControl()
        
        viewModel.outputs.error.subscribe(onNext: { [weak self] error in
            self?.showAlert(message: error.localizedDescription)
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.isRunning.subscribe(onNext: { isRunning in
            _ = isRunning ? YAPProgressHud.showProgressHud() : YAPProgressHud.hideProgressHud()
        }).disposed(by: rx.disposeBag)
    }
    
    func bindAlertControl() {
        viewModel.outputs.blockConfirmationAlert.subscribe(onNext: { [weak self] alertControlTemplate in
            self?.showAlert(title: alertControlTemplate.title, message: alertControlTemplate.message, defaultButtonTitle: alertControlTemplate.defaultButtonTitle, secondayButtonTitle: alertControlTemplate.secondaryButtonTitle, defaultButtonHandler: { _ in
                self?.viewModel.inputs.paymentCardBlockConfirmedObserver.onNext(())
            })
        }).disposed(by: rx.disposeBag)
    }
    
    func setupResources() {
        paymentCardImageView.image = UIImage(named: "image_spare_card_silver", in: .yapPakistan)
        securedByYAPImageView.image = UIImage(named: "image_secured_by_yap_dark_gray", in: .yapPakistan)
    }
    
    func setupTheme() {
        themeService.rx
//            .bind({ UIColor($0.primary) }, to: [self.rx.titleColor])
            .bind({ UIColor($0.primaryDark  )}, to: [cardPlanLabel.rx.textColor])
            .bind({ UIColor($0.greyDark     )}, to: [panNumberLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [noteLabel.rx.textColor])
            .bind({ UIColor($0.secondaryMagenta) }, to: [footnoteLabel.rx.textColor])
//            .bind({ UIColor($0.secondaryMagenta.alpha(0.12)) }, to: [footnoteLabel.rx.backgroundColor])
            .bind({ UIColor($0.greyDark) }, to: [paymentCardBlockOptionsLabel.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [blockReportButton.rx.backgroundColor])
            .bind({ UIColor($0.backgroundColor) }, to: [blockReportButton.rx.titleColor(for: .normal)])
            .disposed(by: rx.disposeBag)
    }
    
    func setupLocalizedStrings() {
//        viewModel.outputs.localizedText.withUnretained(self).subscribe { `self`, string in
//            self.headingLabel.text = string.heading
//            self.signinButton.setTitle(string.signIn, for: .normal)
//            self.forgotButton.setTitle(string.forgot, for: .normal)
//        }.disposed(by: rx.disposeBag)
    }
}
