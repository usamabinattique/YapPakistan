//
//  CardBenefitsViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 04/02/2022.
//

import Foundation
import RxTheme
import RxSwift
import YAPComponents
import UIKit
import RxDataSources

class CardBenefitsViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var crossImage = UIFactory.makeImageView()
    private lazy var crossButton = UIFactory.makeButton(with: .regular)
    private lazy var coverImage = UIFactory.makeImageView(contentMode: .scaleAspectFill)
    private lazy var balanceLabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.isUserInteractionEnabled = true
        return tableView
    }()
    private lazy var nextButton = UIFactory.makeAppRoundedButton(with: .large)
    
    //MARK: Properties
    private let themeService: ThemeService<AppTheme>
    let viewModel: CardBenefitsViewModelType
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!

    // MARK: Initialization

    init(themeService: ThemeService<AppTheme>, viewModel: CardBenefitsViewModelType) {
        self.themeService = themeService
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Unsupported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        
        setupSubViews()
        setupTheme()
        setupConstraints()
        setupResources()
        
        crossButton.addTarget(self, action: #selector(onTapBackButton), for: .touchUpInside)
        //Fetch cards
        viewModel.inputs.fetchBenefitsObserver.onNext(())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupBindings()
    }
    
    @objc internal override func onTapBackButton() {
//        self.dismiss(animated: true, completion: {
//            self.viewModel.inputs.backObserver.onNext(())
//        })
        
        self.viewModel.inputs.backObserver.onNext(())
    }
    
}

extension CardBenefitsViewController: ViewDesignable {
    func setupSubViews() {
        view.addSubview(coverImage)
        view.addSubview(tableView)
        view.addSubview(balanceLabel)
        crossButton.addSubview(crossImage)
        view.addSubview(crossButton)
        view.addSubview(nextButton)
        
        balanceLabel.text = "Your available balance is PKR XXX"
        
        tableView.register(CardBenefitsCell.self, forCellReuseIdentifier: CardBenefitsCell.defaultIdentifier)
        tableView.register(CardInfoCell.self, forCellReuseIdentifier: CardInfoCell.defaultIdentifier)
        
    }
    
    func setupConstraints() {
        
        let topSafeArea: CGFloat = (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) == 0 ? 26 : 0
        crossButton
            .alignEdgeWithSuperviewSafeArea(.top, constant: topSafeArea)
            .alignEdgesWithSuperview([.left], constants: [26])
            .height(constant: 32)
            .width(constant: 32)
        crossImage
            .alignEdgesWithSuperview([.top, .bottom, .left, .right], constants: [0, 0, 0, 0])
        
        coverImage
            .alignEdgesWithSuperview([.top, .left, .right], constants: [0, 0, 0])
            .heightEqualToSuperView(multiplier: 0.49, constant: 0, priority: .defaultHigh)
        
        tableView
            .toBottomOf(coverImage, constant: 0)
            .alignEdgesWithSuperview([.left, .right])
        
        balanceLabel
            .alignEdgesWithSuperview([.left, .right], constants: [0, 0])
            .height(constant: 40)
            .toBottomOf(tableView)
        
        let bottomSafeArea: CGFloat = (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) == 0 ? 33 : 0
        nextButton
            .toBottomOf(balanceLabel, constant: 10)
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: bottomSafeArea)
            .centerHorizontallyInSuperview()
            .width(constant: 192)
            .height(constant: 52)
    }
    
    func setupBindings() {
        
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { [weak self] (_, tableView, _, viewModel) in
            
            guard let self = self else { return UITableViewCell() }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxUITableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell
        })
        
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)
        
        nextButton.rx.tap.subscribe(onNext: { [weak self] _ in
//            self?.dismiss(animated: true
//                                                , completion: {
//                self?.viewModel.inputs.nextObserver.onNext(())
//            })
            
            self?.viewModel.inputs.nextObserver.onNext(())
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.userBalance.subscribe(onNext: { [weak self] balanceText in
            self?.balanceLabel.text = balanceText
        }).disposed(by: rx.disposeBag) //.bind(to: self.balanceLabel.text).disposed(by: rx.disposeBag)
        
        viewModel.outputs.buttonTitle.bind(to: nextButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)
#warning("[UMAIR] - Todo: disable button for master card")
//        viewModel.outputs.isNextButtonEnabled.bind(to: nextButton.rx.isEnabled).disposed(by: rx.disposeBag)
        
        viewModel.outputs.coverImage.subscribe(onNext:{ [weak self] imageName in
            self?.coverImage.image = UIImage(named: imageName ?? "", in: .yapPakistan)
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.error.bind(to: rx.showErrorMessage).disposed(by: rx.disposeBag)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.primary) }, to: [nextButton.rx.enabledBackgroundColor])
            .bind({ UIColor($0.greyDark) }, to: [balanceLabel.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [nextButton.rx.disabledBackgroundColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupResources() {
        crossImage.image = UIImage(named: "Close", in: .yapPakistan)
    }
    
}
