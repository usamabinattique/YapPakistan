//
//  AddMoneyViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 08/02/2022.
//

import UIKit
import YAPCore
import YAPCore
import RxSwift
import RxCocoa
import RxDataSources
import YAPComponents
import RxTheme

class AddMoneyViewController: UIViewController {
    
    // MARK: - Veiws
    
    private lazy var headingLabel = UIFactory.makeLabel(font: .title3, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping, text: "How do you want to add money?")
    
    private lazy var closeBarButtonItem = barButtonItem(image: UIImage(named: "icon_close", in: .yapPakistan), insectBy:.zero)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.isDirectionalLockEnabled = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Properties
    private var themeService: ThemeService<AppTheme>
    private var viewModel: AddMoneyViewModelType!
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!
    
    // MARK: - Initialization
    
    init(themeService: ThemeService<AppTheme>, viewModel: AddMoneyViewModel) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: \(coder) has not been implemented")
    }
    
    // MARK: - View cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        closeBarButtonItem.button?.addTarget(self, action: #selector(onTapBackButton), for: .touchUpInside)
        setupViews()
        setupConstraints()
        bindViews(viewModel)
        
       // addBackButton(.closeEmpty)
    }
    
    // MARK: - Actions
    
    @objc internal override func onTapBackButton() {
        viewModel.inputs.closeObserver.onNext(())
    }
}

// MARK: - Setup views

private extension AddMoneyViewController {
    func setupViews() {
        navigationItem.leftBarButtonItem = closeBarButtonItem.barItem
        
        view.addSubview(headingLabel)
        view.addSubview(collectionView)
        
        collectionView.register(YapItTileCell.self, forCellWithReuseIdentifier: YapItTileCell.defaultIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        title = "Add money"
        view.backgroundColor = .white
        headingLabel.adjustsFontSizeToFitWidth = true
    }
    
    func setupConstraints() {
        
        headingLabel
            .alignEdgeWithSuperviewSafeArea(.top, constant: 30)
            .alignEdgesWithSuperview([.left, .right], constant: 25)
        
        collectionView
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .toBottomOf(headingLabel, constant: 40)
            .alignEdgeWithSuperview(.bottom)
    }
    
    func setupTheme() {
       
//        themeService.rx
//            .bind({ UIColor($0.primaryDark) }, to: [navigationController?.navi])
//
//            .disposed(by: rx.disposeBag)
    }
}

// MARK: Binding

fileprivate extension AddMoneyViewController {
    func bindViews(_ viewModel: AddMoneyViewModelType) {
        dataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { (_, collectionView, indexPath, viewModel) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUICollectionViewCell
            cell.configure(with: viewModel, theme: self.themeService)
            return cell
        })
        
        viewModel.outputs.cellViewModels.bind(to: collectionView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)
        
        collectionView.rx.modelSelected(YapItTileCellViewModel.self)
            .subscribe(onNext: { model in
                self.viewModel.inputs.actionObserver.onNext(model.action)
            })
            .disposed(by: rx.disposeBag)
        
    }
}

// MARK: - Collection view flow layout delgete

extension AddMoneyViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 18)/2, height: 120)
    }
}
