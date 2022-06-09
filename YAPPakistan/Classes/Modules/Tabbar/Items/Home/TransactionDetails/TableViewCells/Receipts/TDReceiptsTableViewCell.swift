//
//  TDReceiptsTableViewCell.swift
//  Cards
//
//  Created by Janbaz Ali on 26/10/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import UIKit
import YAPCore
import YAPComponents
import RxSwift
import RxDataSources
import RxTheme

class TDReceiptsTableViewCell: RxUITableViewCell {

    private lazy var icon: UIImageView = UIImageViewFactory.createImageView(mode: .scaleAspectFit, image: UIImage.init(named: "icon_add_receipt", in: .yapPakistan))
    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private lazy var titleLabel: UILabel = UIFactory.makeLabel(font: .small, alignment: .left) //UILabelFactory.createUILabel(with: .primary, textStyle: .small, alignment: .left)
    private lazy var descriptionLabel: UILabel = UIFactory.makeLabel(font: .micro, alignment: .left) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .left)
    
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
    
    //MARK: - Properties
    var viewModel: TDReceiptsTableViewCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    private var receiptsDataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!
    
    // MARK: Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: View cycle
    
    override func draw(_ rect: CGRect) {
        render()
    }
    
    // MARK: Configuration
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? TDReceiptsTableViewCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bind()
        setupTheme()
//        setupResources()
    }
    
    func render() {
        iconContainerView.layer.cornerRadius = iconContainerView.bounds.height/2
        iconContainerView.layer.masksToBounds = false
        iconContainerView.clipsToBounds = true
    }
    
}

// MARK: SetupViews
private extension TDReceiptsTableViewCell {
    func setupViews() {
        contentView.backgroundColor = .white
        
        vStack.addArrangedSubview(titleLabel)
        vStack.addArrangedSubview(descriptionLabel)
        vStack.addArrangedSubview(collectionView)
        vStack.setCustomSpacing(14, after: descriptionLabel)
        iconContainerView.addSubview(icon)
        
        contentView.addSubview(iconContainerView)
        contentView.addSubview(vStack)
        
        collectionView.register(TDReceiptCollectionViewCell.self, forCellWithReuseIdentifier: TDReceiptCollectionViewCell.defaultIdentifier)
    }
    
    func setupConstraints() {
        
        iconContainerView
            .width(constant: 42)
            .height(constant: 42)
            .alignEdgesWithSuperview([.left, .top], constants: [20,10])
            .alignEdgeWithSuperviewSafeArea(.bottom, .greaterThanOrEqualTo, constant: 10, priority: .defaultLow)
        
        vStack
            .toRightOf(iconContainerView, constant: 16)
            .alignEdge(.top, withView: iconContainerView)
            .alignEdgeWithSuperview(.right)
            .alignEdgeWithSuperview(.bottom, .greaterThanOrEqualTo, constant: 10, priority: .defaultLow)
        
        collectionView
            .height(constant: 32)
            
        icon
            .centerInSuperView()
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [icon.rx.tintColor,titleLabel.rx.textColor])
            .bind({ UIColor($0.primary).withAlphaComponent(0.16) }, to: [iconContainerView.rx.backgroundColor])
            .bind({ UIColor($0.greyDark) }, to: [descriptionLabel.rx.textColor])
            .disposed(by: rx.disposeBag)
    }
    
    func bind() {
        viewModel.outputs.isCollectionHidden.bind(to: collectionView.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: titleLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.descriptionText.bind(to: descriptionLabel.rx.text).disposed(by: disposeBag)
        bindCollectionView()
    }
    
    func bindCollectionView() {
        receiptsDataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { [unowned self] (_, collectionView, indexPath, viewModel) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUICollectionViewCell
            cell.configure(with: viewModel, theme: self.themeService)
            return cell
        })
        
        viewModel.outputs.receiptsDataSource.bind(to: collectionView.rx.items(dataSource: receiptsDataSource)).disposed(by: disposeBag)
        Observable.zip(collectionView.rx.modelSelected(ReusableCollectionViewCellViewModelType.self), collectionView.rx.itemSelected).subscribe(onNext: { [weak self] (viewModel, indexPath) in
            guard let `self` = self else { return }
            if let _ = viewModel as? TDReceiptCollectionViewCellViewModel{
                self.viewModel.inputs.selectedModelObserver.onNext(indexPath)
            }
        }).disposed(by: disposeBag)
        
    }
    
}


// MARK: Collection view flow layout delgete

extension TDReceiptsTableViewCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 96 , height: 32)
        return CGSize(width: 130 , height: 32)
    }
}
