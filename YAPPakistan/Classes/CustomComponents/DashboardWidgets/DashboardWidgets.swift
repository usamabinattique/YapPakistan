//
//  DashboardWidgets.swift
//  YAPPakistan
//
//  Created by Yasir on 04/04/2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxTheme

public class DashboardWidgets: UIView {
    
    let delegateImplementation = PeekCollectionViewDelegateImplementation(cellSpacing: 10, cellPeekWidth: 20)
    
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
    
    public let viewModel = DashboardWidgetsViewModel()
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!
    private let disposeBag = DisposeBag()
    private var themeService: ThemeService<AppTheme>!
    
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init(theme:ThemeService<AppTheme>) {
        super.init(frame: .zero)
        self.themeService = theme
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        setupViews()
        setupConstraints()
    }
}

//MARK:- View Setup

extension DashboardWidgets {

    func setupViews() {
        collectionView.register(CustomWidgetsCollectionViewCell.self, forCellWithReuseIdentifier: CustomWidgetsCollectionViewCell.defaultIdentifier)
        addSubview(collectionView)
        
        bind()
    }
    
    func setupConstraints() {
        
        collectionView
            .alignEdgesWithSuperview([.left,.right,.top,.bottom], constants: [24,10,15,0])//[25,10,15,0])
            .height(constant: 120)
    }
}

//MARK:- Binding

extension DashboardWidgets {
    
    func bind() {
        
        dataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { [unowned self] (_, collectionView, indexPath, viewModel) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUICollectionViewCell
            
            cell.configure(with: viewModel, theme: self.themeService)
            return cell
        })
        viewModel.outputs.dataSource.bind(to: collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        collectionView.rx.modelSelected(CustomWidgetsCollectionViewCellViewModel.self).bind(to: viewModel.inputs.modelObserver).disposed(by: disposeBag)
        
        viewModel.scrollToTop.subscribe(onNext: {[unowned self] in
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
        }).disposed(by: disposeBag)
    }
    
    func observeData(data: [DashboardWidgetsResponse]) {
        viewModel.inputs.widgetsDataObserver.onNext(data)
    }
}

extension DashboardWidgets: UICollectionViewDelegateFlowLayout {
   
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: collectionView.bounds.height)
    }
    
}
public extension Reactive where Base: DashboardWidgets {
    
    var dashboardWidgets: Binder<[DashboardWidgetsResponse]?> {
        return Binder(self.base) { myClass, data -> Void in
            myClass.observeData(data: data ?? [])
        }
    }
}
