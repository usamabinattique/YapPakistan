//
//  NotificationsView.swift
//  YAPPakistan
//
//  Created by Yasir on 04/04/2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxTheme
import RxTheme

public class NotificationsView: UIView {

    let delegateImplementation = PeekCollectionViewDelegateImplementation(cellSpacing: 10, cellPeekWidth: 20)

    private lazy var notificationCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.configureForPeekingDelegate()
        collectionView.delegate = delegateImplementation
        collectionView.isDirectionalLockEnabled = true
        collectionView.dataSource = self
        return collectionView
    }()

    var viewModel = NotificationsViewModel()
    private var isShown: Bool = true

    private let disposeBag = DisposeBag()
    private var heightConstraint: NSLayoutConstraint!
    private var top: NSLayoutConstraint!
    private var themeService: ThemeService<AppTheme>!

    // MARK: Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    init(theme:ThemeService<AppTheme>) {
        super.init(frame: .zero)
        self.themeService = theme
        commonInit()
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        clipsToBounds = true
        delegateImplementation.delegate = self
        setupViews()
        setupConstraints()
        bindOutputs()
    }

    // MARK: Parallex animation
    public func changeHeight(by progress: CGFloat, withDuration duration: TimeInterval = 0, completion: ((Bool) -> Void)? = nil) {

        guard isShown else { return }

        let viewHeight = notificationCollection.bounds.height * progress
        self.heightConstraint.constant = viewHeight
//        self.top.constant = (progress <= 1 ? 0 : ((viewHeight - notificationCollection.bounds.height)/2))

        guard duration == 0 else {
            notificationCollection.alpha = progress
            return
        }

        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.notificationCollection.alpha = progress
            self?.layoutIfNeeded()
        }, completion: completion)
    }
}

// MARK: View setup

private extension NotificationsView {

    func setupViews() {
        notificationCollection.register(NotificationCollectionViewCell.self, forCellWithReuseIdentifier: NotificationCollectionViewCell.defaultIdentifier)

        addSubview(notificationCollection)
    }

    func setupConstraints() {
        notificationCollection
            .alignEdgesWithSuperview([.left, .right])
            .centerVerticallyInSuperview()
            .height(constant: 140)

        heightConstraint = heightAnchor.constraint(equalToConstant: 140)
        heightConstraint.isActive = true
    }
}

// MARK: Collection view data source

extension NotificationsView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.outputs.cellViewModels.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellViewModel = viewModel.outputs.cellViewModels[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellViewModel.reusableIdentifier, for: indexPath) as! NotificationCollectionViewCell
        cell.configure(with: cellViewModel, theme: themeService)
        cell.indexPath = indexPath
        return cell
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

// MARK: Collection veiw delegate
extension NotificationsView: PeekCollectionViewDelegate {
    public func peekImplementation(_ peekImplementation: PeekCollectionViewDelegateImplementation, didSelectItemAt indexPath: IndexPath) {
//        viewModel.inputs.checkedNotificationObserver.onNext(indexPath)
    }
}

// MARK: Binding
private extension NotificationsView {
    func bindOutputs() {
        
        viewModel.outputs.reloadData.subscribe(onNext: { [weak self] _ in
            self?.notificationCollection.reloadData()
        }).disposed(by: disposeBag)

        viewModel.outputs.deleteItem.subscribe(onNext: { [weak self] indexPath in
            self?.notificationCollection.deleteItems(at: [indexPath])
            if indexPath.row > 0 {
                (self?.notificationCollection.cellForItem(at: indexPath) as? NotificationCollectionViewCell)?.deleteCell()
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.25, execute: { [weak self] in
                self?.notificationCollection.reloadSections(IndexSet([0]))
            })
        }).disposed(by: disposeBag)
    }
}

// MARK: Reactive
public extension Reactive where Base: NotificationsView {

    var notifications: AnyObserver<[InAppNotification]> {
        return self.base.viewModel.inputs.notificationsObserver
    }

    var notificationDeleted: Observable<InAppNotification> {
        base.viewModel.outputs.deletedNotification
    }

    var notificationChecked: Observable<InAppNotification> {
        return self.base.viewModel.outputs.checkedNotification
    }
}
