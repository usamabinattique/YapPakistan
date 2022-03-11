//
//  DenominationAmountCollectionView.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 05/09/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxTheme

open class DenominationAmountCollectionView: UIView {
    
    // MARK: - Properties
    public var themeService: ThemeService<AppTheme> = AppTheme.service(initial: .light)
    fileprivate let disposeBag = DisposeBag()
    private var leftEdgeInset = 0
    var viewModelsItemsSubject = BehaviorSubject<[DenominationAmountCollectionViewCellViewModel]>(value: [])
    var viewModelItems: Observable<[DenominationAmountCollectionViewCellViewModel]> { return viewModelsItemsSubject.asObservable() }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = false
        setupViews()
        setUpConstraints()
        bind()
    }
    
    private func setupViews() {
        collectionView.backgroundColor = .white
        addSubview(collectionView)
        registerCell()
    }
    
    private func setUpConstraints() {
        collectionView
            .alignEdgesWithSuperview([.left, .right, .top, .bottom])
    }
    
    private func registerCell() {
        collectionView.register(DenominationAmountCollectionViewCell.self, forCellWithReuseIdentifier: DenominationAmountCollectionViewCell.defaultIdentifier)
    }
    
    private func bind() {
        viewModelItems.bind(to: collectionView.rx.items(cellIdentifier: DenominationAmountCollectionViewCell.defaultIdentifier, cellType: DenominationAmountCollectionViewCell.self)) {[unowned self] _, data, cell in
            //FIXME: [UMAIR] - use proper injection for theme
            cell.configure(with: data, theme: self.themeService)
            self.styleCollectionViewCell()
            }.disposed(by: disposeBag)
    }
    
    private func styleCollectionViewCell() {
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let itemWidth = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width
        let spacing = (Int(collectionView.frame.width) - (numberOfItems * Int(itemWidth))) / (numberOfItems + 1)
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumLineSpacing = CGFloat(spacing)
        self.leftEdgeInset = spacing
    }
}

extension DenominationAmountCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: CGFloat(leftEdgeInset - 8), bottom: 0, right: 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 55, height: 20)
    }
}

// MARK: - DenominationAmountCollectionView+Rx
public extension Reactive where Base: DenominationAmountCollectionView {
    var items: Binder<[DenominationAmountCollectionViewCellViewModel]> {
        return Binder(self.base) { denominationView, viewModels in
            denominationView.viewModelsItemsSubject.onNext(viewModels)
        }
    }
    
    var modelSelected: Observable<String> {
        return base.collectionView.rx.modelSelected(DenominationAmountCollectionViewCellViewModel.self).flatMap { $0.amount }
    }
    
}
