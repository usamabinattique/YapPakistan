//
//  TopupCardSelectionViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 09/02/2022.
//

import UIKit
import RxSwift
import RxCocoa
import YAPCore
import YAPComponents
import RxTheme
import RxDataSources

class TopupCardSelectionViewController: UIViewController {
    
    // MARK: - Views
    private lazy var headingLabel: UILabel =  UIFactory.makeLabel(font: .title2, alignment: .center, numberOfLines: 0) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .large, alignment: .center)
    private lazy var subheadingLabel: UILabel = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .center)
    private lazy var alert: YAPAlert = {
        let alert = YAPAlert()
        alert.translatesAutoresizingMaskIntoConstraints = false
        return alert
    }()
    private lazy var cardsCollectionView: UICollectionView = {
        let layout = CarouselFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width*0.632, height: (UIScreen.main.bounds.width*0.632)/1.559)
        layout.sideItemAlpha = 0.5
        layout.sideItemScale = 0.7
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = false
        collectionView.isDirectionalLockEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var cardBankNameLabel: UILabel = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .micro, alignment: .center)
    private lazy var secureByYAPView: SecureByYAPView = SecureByYAPView(frame: CGRect.zero)
    
    private lazy var selectButton: AppRoundedButton = AppRoundedButtonFactory.createAppRoundedButton(title: "screen_kyc_card_benefits_screen_next_button_title".localized)
    
    private lazy var securedByYapStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 8, arrangedSubviews: [cardBankNameLabel, secureByYAPView])
    
    // MARK: - Properties
//    let disposeBag: DisposeBag
    
    private var themeService: ThemeService<AppTheme>
    private var viewModel: TopupCardSelectionViewModelType!
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!
    
    // MARK: - Initialization
    
    init(themeService: ThemeService<AppTheme>, viewModel: TopupCardSelectionViewModelType) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: \(coder) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "screen_topup_card_selection_display_text_title".localized
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "icon_back", in: .yapPakistan), style: .plain, target: self, action: #selector(closeAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "icon_add_card", in: .yapPakistan), style: .plain, target: self, action: #selector(addCardAction))
        
//        headingLabel.text = "You have 2 cards"
//        subheadingLabel.text = "Choose which card you want to top up with"
        setup()
        bind(viewModel: viewModel)
    }
    
    
    
    // MARK: Actions
    
    @objc
    private func closeAction() {
        viewModel.inputs.backObserver.onNext(())
    }
    
    @objc
    private func addCardAction() {
        viewModel.inputs.addNewCardObserver.onNext(())
    }
    
    func onTapSelectButton() {
        viewModel.inputs.selectObserver.onNext(())
    }
}

// MARK: - Setup
fileprivate extension TopupCardSelectionViewController {
    func setup() {
        
        setupViews()
        setupTheme()
        setupConstraints()
        
        view.clipsToBounds = true
    }
    
    func setupViews() {
        view.backgroundColor = .white
        cardsCollectionView.register(TopupPCCVCell.self, forCellWithReuseIdentifier: TopupPCCVCell.defaultIdentifier)
        cardsCollectionView.register(AddTopupPCCVCell.self, forCellWithReuseIdentifier: AddTopupPCCVCell.defaultIdentifier)

        view.addSubview(headingLabel)
        view.addSubview(subheadingLabel)
        view.addSubview(cardsCollectionView)
        view.addSubview(securedByYapStack)
        view.addSubview(selectButton)
        cardBankNameLabel.isHidden = true
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to:  view.rx.backgroundColor )
            .bind({ UIColor($0.greyDark) }, to: secureByYAPView.textLable.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: headingLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: subheadingLabel.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: navigationItem.leftBarButtonItem!.rx.tintColor)
            .bind({ UIColor($0.primary) }, to: navigationItem.rightBarButtonItem!.rx.tintColor)
            .bind({ UIColor($0.primaryDark) }, to:  cardBankNameLabel.rx.textColor)
//            .bind({ UIColor($0.greyLight) }, to: textField.rx.bottomLineColorNormal)
//            .bind({ UIColor($0.primary) }, to: textField.rx.bottomLineColorWhileEditing)
//            .bind({ UIColor($0.greyDark) }, to: tipsLabel.rx.textColor)
//            .bind({ UIColor($0.primary) }, to: selectButton.rx.backgroundColor)
            .bind({ UIColor($0.primary) }, to: selectButton.rx.enabledBackgroundColor)
            .bind({ UIColor($0.greyDark) }, to: selectButton.rx.disabledBackgroundColor)
            .disposed(by: rx.disposeBag)
    }

    
    func setupConstraints() {
        
        headingLabel
            .alignEdgeWithSuperviewSafeArea(.top, .lessThanOrEqualTo, constant: 30)
            .alignEdgeWithSuperviewSafeArea(.top, .greaterThanOrEqualTo, constant: 15)
            .centerHorizontallyInSuperview()
        
        subheadingLabel
            .toBottomOf(headingLabel, constant: 4)
            .centerHorizontallyInSuperview()
        
        cardsCollectionView
            .toBottomOf(subheadingLabel, .lessThanOrEqualTo, constant: 56)
            .toBottomOf(subheadingLabel, .greaterThanOrEqualTo, constant: 25)
            .alignEdgesWithSuperview([.left, .right], constant: 0)
            .height(constant: (UIScreen.main.bounds.width*0.632)/1.559)
        
        securedByYapStack
            .toBottomOf(cardsCollectionView, .lessThanOrEqualTo, constant: 60)
            .toBottomOf(cardsCollectionView, .greaterThanOrEqualTo, constant: 30)
            .centerHorizontallyInSuperview()
        
        selectButton.centerHorizontallyInSuperview()
            .toBottomOf(securedByYapStack, .greaterThanOrEqualTo, constant: 15)
            .height(constant: 52)
            .width(constant: 192)
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 20)
    }
}

// MARK: - Bind
fileprivate extension TopupCardSelectionViewController {
    func bind(viewModel: TopupCardSelectionViewModelType) {
//        viewModel.outputs.topupPaymentCardCellViewModels.bind(to: cardsCollectionView.rx.items) { [unowned self] collectionView, item, viewModel in
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.reusableIdentifier, for: IndexPath(item: item, section: 0)) as! RxUICollectionViewCell
//            cell.configure(with: viewModel, theme: self.themeService)
//            return cell
//        }.disposed(by: rx.disposeBag)
        
        dataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { [weak self] (data, tableView, index, viewModel) in
            
            guard let self = self else { return UICollectionViewCell() }
            
            let cell = tableView.dequeueReusableCell(withReuseIdentifier: viewModel.reusableIdentifier, for: index) as! RxUICollectionViewCell
            cell.configure(with: viewModel, theme: self.themeService)
            return cell
        })
        
        viewModel.outputs.cellViewModels.bind(to: cardsCollectionView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)
        
        viewModel.outputs.cardCount.bind(to: headingLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.subHeading.bind(to: subheadingLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.cardNickName.map { $0 == nil }.bind(to: cardBankNameLabel.rx.isHidden).disposed(by: rx.disposeBag)
        viewModel.outputs.cardNickName.map { $0 == nil }.bind(to: selectButton.rx.animateIsHidden).disposed(by: rx.disposeBag)
        viewModel.outputs.cardNickName.bind(to: cardBankNameLabel.rx.text).disposed(by: rx.disposeBag)
        //TODO: handle following scenario in vm and uncomment it.
//        viewModel.outputs.addCardEnabled.subscribe(onNext: { [weak self] in
//            guard let `self` = self else { return }
//            self.navigationItem.rightBarButtonItem = $0 ? UIBarButtonItem(image: UIImage.init(named: "icon_add_card", in: .yapPakistan), style: .plain, target: self, action: #selector(self.addCardAction)) : nil
//        }).disposed(by: rx.disposeBag)
        viewModel.outputs.error.bind(to: rx.showErrorMessage).disposed(by: rx.disposeBag)
        
        cardsCollectionView.rx.itemSelected.subscribe(onNext:{[weak self] in
            self?.viewModel.inputs.itemSelectedObserver.onNext($0)
        }).disposed(by: rx.disposeBag)
        
        cardsCollectionView.rx.currentPage.bind(to: viewModel.inputs.currentIndexObserver).disposed(by: rx.disposeBag)
        
        selectButton.rx.tap.subscribe(onNext: {[unowned self] _ in
            self.onTapSelectButton()
        }).disposed(by: rx.disposeBag)

    }
}
