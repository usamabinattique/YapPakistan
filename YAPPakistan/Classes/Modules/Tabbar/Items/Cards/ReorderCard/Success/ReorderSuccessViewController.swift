//
//  ReorderSuccessViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 27/12/2021.
//

import YAPComponents
import RxTheme
import RxSwift

class ReorderSuccessViewController: UIViewController {
    
    private let titleLabel = UIFactory.makeLabel(font: .large)
    private let cardImageView = UIFactory.makeImageView()
    private let subTitleLabel = UIFactory.makeLabel(
        font: .small,
        insects: .init(top: 0, left: 15, bottom: 0, right: 15)
    ).setCornerRadius(12)
    private let headingLabel = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0)
    private let detailLabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0)

    private let doneButton = UIFactory.makeAppRoundedButton(with: .regular)
    
    let spacers = [UIFactory.makeView(), UIFactory.makeView(),
                   UIFactory.makeView(), UIFactory.makeView()]
    
    var backButton: UIButton!
    
    private var themeService: ThemeService<AppTheme>!
    var viewModel:  ReorderSuccessViewModelType!
    
    convenience init(themeService: ThemeService<AppTheme>, viewModel: ReorderSuccessViewModelType) {
        self.init(nibName: nil, bundle: nil)
        
        self.themeService = themeService
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTheme()
        setupResources()
        setupLanguageStrings()
        setupBindings()
        setupConstraints()
    }
    
    func setupViews() {
        view
            .addSub(views: [cardImageView, subTitleLabel, headingLabel, detailLabel, doneButton])
            .addSub(views: spacers)
        
        navigationItem.titleView = titleLabel
        
        backButton = addBackButton(of: .backEmpty)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: subTitleLabel.rx.textColor)
            .bind({ UIColor($0.primaryExtraLight) }, to: subTitleLabel.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: headingLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: detailLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: doneButton.rx.enabledBackgroundColor)
            .bind({ UIColor($0.greyDark) }, to: doneButton.rx.disabledBackgroundColor)
            .disposed(by: rx.disposeBag)
        
        guard backButton != nil else { return }
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [ backButton.rx.tintColor ])
            .disposed(by: rx.disposeBag)
    }
    
    func setupResources() {
        cardImageView.image = UIImage(named: "payment_card", in: .yapPakistan)
    }
    
    func setupLanguageStrings() {
        viewModel.outputs.languageStrings.withUnretained(self)
            .subscribe(onNext: { `self`, strings in
                self.titleLabel.text = "Order successfull"
                self.subTitleLabel.text = "Primary card"
                self.headingLabel.text = "Your card has been permanently blocked and a new card has been orderd and is on the way"
                self.detailLabel.text = "An agent will get in touch with you soon to arrange the delivery. Please keep your CNIC at hand."
                self.doneButton.setTitle("Done", for: .normal)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func setupBindings() {
        doneButton.rx.tap.bind(to: viewModel.inputs.backObserver)
            .disposed(by: rx.disposeBag)
        backButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
    }
    
    func setupConstraints() {
        
        spacers[0]
            .alignEdgesWithSuperview([.left, .right, .safeAreaTop])
        
        cardImageView
            .toBottomOf(spacers[0])
            .widthEqualToSuperView(multiplier: 0.45)
            .centerHorizontallyInSuperview()
            .aspectRatio(1030 / 652)
        subTitleLabel
            .toBottomOf(cardImageView, constant: 20)
            .centerHorizontallyInSuperview()
            .height(constant: 24)

        spacers[1]
            .toBottomOf(subTitleLabel)
            .alignEdgesWithSuperview([.left, .right])

        headingLabel
            .toBottomOf(spacers[1])
            .alignEdgesWithSuperview([.left, .right], constant: 20)
        
        spacers[2]
            .toBottomOf(headingLabel)
            .alignEdgesWithSuperview([.left, .right])

        detailLabel
            .toBottomOf(spacers[2])
            .alignEdgesWithSuperview([.left, .right], constant: 20)

        spacers[3]
            .toBottomOf(detailLabel)
            .alignEdgesWithSuperview([.left, .right])
        
        doneButton
            .toBottomOf(spacers[3])
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.safeAreaBottom, constant: 25)
            .width(constant: 200)
            .height(constant: 52)
        
        spacers[0]
            .heightEqualTo(view: spacers[1])
            .heightEqualTo(view: spacers[2], multiplier: 2)
            .heightEqualTo(view: spacers[3], multiplier: 0.4)
    }
}
