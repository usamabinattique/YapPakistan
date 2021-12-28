//
//  CardOptionPickerCollectionView.swift
//  YAPPakistan
//
//  Created by Umair  on 26/12/2021.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

public class CardOptionPickerCollectionView: UIView {
    
    //MARK: - Views
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CardOptionPickerCollectionViewCell.self, forCellWithReuseIdentifier: CardOptionPickerCollectionViewCell.defaultIdentifier)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 0, height: 0)
        collectionView.backgroundColor = .white
        collectionView.setCollectionViewLayout(layout, animated: true)
        
        return collectionView
    }()
    
    // MARK: - Properties
    fileprivate lazy var dataSubject: BehaviorSubject<[OptionPickerItem<PaymentCardBlockOption>]> = {
        let subject = BehaviorSubject<[OptionPickerItem<PaymentCardBlockOption>]>(value: [])
        return subject
    }()
    private var disposeBag = DisposeBag()
    
    var itemSpacing: CGFloat = 20 {
        didSet {
            layoutCollectionView()
        }
    }
    
    //MARK: - Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        setupViews()
        setupConstraints()
        bind()
        layoutCollectionView()
    }
    
    public override func layoutSubviews() {
        layoutCollectionView()
    }
    
    // MARK: - Setup
    private func setupViews() {
        addSubview(collectionView)
    }
    
    private func layoutCollectionView() {
        guard let numberOfItems = try? dataSubject.value().count else { return }
        let itemWidth = (bounds.size.width / CGFloat(numberOfItems)) - ((itemSpacing / 2) * CGFloat(numberOfItems - 1))
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: itemWidth, height: bounds.height)
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing = itemSpacing
    }
    
    private func setupConstraints() {
        collectionView.alignAllEdgesWithSuperview()
    }
    
    private func bind() {
        dataSubject.bind(to: collectionView.rx.items) {
            (collectionView, item, optionPickerItem) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardOptionPickerCollectionViewCell.defaultIdentifier, for: IndexPath(item: item, section: 0)) as! CardOptionPickerCollectionViewCell
            cell.configure(with: optionPickerItem)
            return cell
            }.disposed(by: disposeBag)
    }
}

// MARK: - CardOptionPickerCollectionView + Rx
public extension Reactive where Base: CardOptionPickerCollectionView {
    var paymentCardOptionsObserver: AnyObserver<[OptionPickerItem<PaymentCardBlockOption>]> {
        return base.dataSubject.asObserver()
    }
    
    var modelSelected: Observable<PaymentCardBlockOption> {
        return base.collectionView.rx.modelSelected(OptionPickerItem<PaymentCardBlockOption>.self).map { $0.value }
    }
}
