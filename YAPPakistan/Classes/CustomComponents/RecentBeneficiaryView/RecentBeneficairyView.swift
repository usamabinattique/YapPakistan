//
//  RecentBeneficairyView.swift
//  YAPKit
//
//  Created by Zain on 02/11/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import RxDataSources
import YAPComponents
import RxTheme

public class RecentBeneficiaryView: UIView, ConfigurableView {
    
    
    // MARK: - Views
    
    private lazy var leftLabel = UIFactory.makeLabel(font:.micro, alignment: .left)
    
    private lazy var showButton = UIFactory.makeButton(with: .micro, backgroundColor: .clear, title: "Show recent transfers")
    
    private lazy var hideButton =  UIFactory.makeButton(with: .micro, backgroundColor: .clear, title: "Hide")
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var saperator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    
    private var viewModel: RecentBeneficiaryViewModelType!
    private var themeService: ThemeService<AppTheme>!
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!
    private var disposeBag = DisposeBag()
    private var collectionViewHeight: NSLayoutConstraint!
    public weak var delegate: RecentBeneficiaryViewLayoutDelegate?
    
    public var showsSaperator: Bool = true {
        didSet {
            saperator.isHidden = !showsSaperator
        }
    }
    
    // MARK: - Configurations
    
    public func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let `viewModel` = viewModel as? RecentBeneficiaryViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        self.disposeBag = DisposeBag()
        bind(viewModel)
        render()
    }
    
    // MARK: - Initialization
    
    init(with theme: ThemeService<AppTheme>){
        super.init(frame: CGRect.zero)
        self.themeService = theme
        commonInit()
    }
    
//    public override init(frame: CGRect) {
//        super.init(frame: frame)
//        commonInit()
//    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupViews()
        setupConstraints()
        render()
    }
    
}

// MARK: Collection view flow layout delgete

extension RecentBeneficiaryView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: collectionView.bounds.height)
    }
}

// MARK: - View setup

private extension RecentBeneficiaryView {
    func setupViews() {
        addSubview(leftLabel)
        addSubview(showButton)
        addSubview(hideButton)
        addSubview(collectionView)
        addSubview(saperator)
        
        collectionView.register(RecentBeneficiaryCollectionViewCell.self, forCellWithReuseIdentifier: RecentBeneficiaryCollectionViewCell.defaultIdentifier)
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 17.5, bottom: 0, right: 17.5)
    }
    
    func setupConstraints() {
        
        leftLabel
            .height(constant: 18)
            .alignEdgesWithSuperview([.left, .top, .right], constants: [25, 0, 25])
        
        showButton
            .height(constant: 18)
            .alignEdgesWithSuperview([.left, .top], constants: [25, 0])
        
        hideButton
            .height(constant: 18)
            .alignEdgesWithSuperview([.top, .right], constants: [0, 25])
        
        collectionView
            .alignEdgesWithSuperview([.left, .right, .bottom])
            .toBottomOf(leftLabel)
        
        saperator
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .alignEdgeWithSuperview(.bottom)
            .height(constant: 1)
        
        collectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: 95)
        collectionViewHeight.priority = .required
        collectionViewHeight.isActive = true
    }
    
    func render() {
        showButton.titleLabel?.font = .micro
        hideButton.titleLabel?.font = .micro
        
        backgroundColor = .clear
        saperator.backgroundColor = UIColor(themeService.attrs.greyDark).withAlphaComponent(0.15)
        showButton.setTitleColor(UIColor(themeService.attrs.primary), for: .normal)
        hideButton.setTitleColor(UIColor(themeService.attrs.primary), for: .normal)
        leftLabel.textColor = UIColor(themeService.attrs.greyDark)
    }
}

// MARK: - Binding

private extension RecentBeneficiaryView {
    func bind(_ viewModel: RecentBeneficiaryViewModelType) {
        bindViews(viewModel)
        bindCollectionView(viewModel)
    }
    
    func bindViews(_ viewModel: RecentBeneficiaryViewModelType) {
        viewModel.outputs.heading.bind(to: leftLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.showButtonTitle.bind(to: showButton.rx.title(for: .normal)).disposed(by: disposeBag)
        viewModel.outputs.hideButtonTitle.bind(to: hideButton.rx.title(for: .normal)).disposed(by: disposeBag)
        
        viewModel.outputs.isShown.map{ !$0 }.bind(to: hideButton.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.isShown.map{ !$0 }.bind(to: leftLabel.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.isShown.map{ $0 }.bind(to: showButton.rx.isHidden).disposed(by: disposeBag)
        
        showButton.rx.tap.bind(to: viewModel.inputs.showObserver).disposed(by: disposeBag)
        hideButton.rx.tap.bind(to: viewModel.inputs.hideObserver).disposed(by: disposeBag)
        
        viewModel.outputs.isShown.subscribe(onNext: { [weak self] in self?.animateView(collectionViewShown: $0) }).disposed(by: disposeBag)
    }
    
    func bindCollectionView(_ veiwModel: RecentBeneficiaryViewModelType) {
        dataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { [weak self] (_, collectionView, indexPath, viewModel) -> UICollectionViewCell in
            
            guard let `self` = self else { return UICollectionViewCell() }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUICollectionViewCell
            cell.configure(with: viewModel, theme: AppTheme.service(initial: .light))
            return cell
        })
        
        viewModel.outputs.cellViewModels.bind(to: collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        collectionView.rx.itemSelected.map{ $0.row }.bind(to: viewModel.inputs.itemSelectedObserver).disposed(by: disposeBag)
    }
}

// MARK: Animations

private extension RecentBeneficiaryView {
    func animateView(collectionViewShown: Bool) {
        collectionViewHeight.constant = collectionViewShown ? 95 : 0
        delegate?.recentBeneficiaryViewWillAnimate(self)
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutAllSuperViews()
            self.saperator.alpha = collectionViewShown ? 1 : 0
        }) { (completion) in
            guard completion else { return }
            self.collectionView.isHidden = !collectionViewShown
            self.delegate?.recentBeneficiaryViewDidAnimate(self)
        }
    }
}

public protocol RecentBeneficiaryViewLayoutDelegate: AnyObject {
    func recentBeneficiaryViewWillAnimate(_ recentBeneficiaryView: RecentBeneficiaryView)
    func recentBeneficiaryViewDidAnimate(_ recentBeneficiaryView: RecentBeneficiaryView)
}

public extension RecentBeneficiaryViewLayoutDelegate {
    func recentBeneficiaryViewWillAnimate(_ recentBeneficiaryView: RecentBeneficiaryView) {}
    func recentBeneficiaryViewDidAnimate(_ recentBeneficiaryView: RecentBeneficiaryView) {}
}

