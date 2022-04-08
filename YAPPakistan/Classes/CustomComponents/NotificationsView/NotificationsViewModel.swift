//
//  NotificationsViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 04/04/2022.
//

import Foundation
import RxSwift
import RxDataSources

protocol NotificationsViewModelInput {
    var notificationsObserver: AnyObserver<[InAppNotification]> { get }
    var checkedNotificationObserver: AnyObserver<IndexPath> { get }
}

protocol NotificationsViewModelOutput {
    var cellViewModels: [ReusableCollectionViewCellViewModelType] { get }
    var reloadData: Observable<Void> { get }
    var checkedNotification: Observable<InAppNotification> { get }
    var deletedNotification: Observable<InAppNotification> { get }
    var deleteItem: Observable<IndexPath> { get }
}

protocol NotificationsViewModelType {
    var inputs: NotificationsViewModelInput { get }
    var outputs: NotificationsViewModelOutput { get }
}

class NotificationsViewModel: NotificationsViewModelType, NotificationsViewModelInput, NotificationsViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    public var inputs: NotificationsViewModelInput { return self }
    public var outputs: NotificationsViewModelOutput { return self }
    
    private let notificationsSubject = BehaviorSubject<[InAppNotification]>(value: [])
    private var cellViewModelsSubject = [ReusableCollectionViewCellViewModelType]()
    private let checkedNotificationObserverSubject = PublishSubject<IndexPath>()
    private let checkedNotificationSubject = PublishSubject<InAppNotification>()
    private let deletedNotificationSubject = PublishSubject<InAppNotification>()
    private let reloadDataSubject = PublishSubject<Void>()
    private let deleteItemSubject = PublishSubject<IndexPath>()
    
    // MARK: - Inputs
    var notificationsObserver: AnyObserver<[InAppNotification]> { return notificationsSubject.asObserver() }
    var checkedNotificationObserver: AnyObserver<IndexPath> { return checkedNotificationObserverSubject.asObserver() }
    
    // MARK: - Outputs
    public var cellViewModels: [ReusableCollectionViewCellViewModelType] { return cellViewModelsSubject }
    var checkedNotification: Observable<InAppNotification> { return checkedNotificationSubject.asObservable() }
    var deletedNotification: Observable<InAppNotification> { return deletedNotificationSubject.asObservable() }
    var reloadData: Observable<Void> { return reloadDataSubject.asObservable() }
    var deleteItem: Observable<IndexPath> { return deleteItemSubject.asObservable() }
    
    // MARK: - Init
    init() {
        
        notificationsSubject.map {
            $0.map { [unowned self] notification -> ReusableCollectionViewCellViewModelType in
                let cellViewModel = NotificationCollectionViewCellViewModel(notification: notification)
                cellViewModel.outputs.deleteNotification.bind(to: self.deleteItemSubject).disposed(by: self.disposeBag)
                cellViewModel.outputs.actionTapped.map { [unowned self] indexPath in
                    (self.cellViewModels[indexPath.row] as! NotificationCollectionViewCellViewModel).notification
                }.bind(to: checkedNotificationSubject).disposed(by: disposeBag)
                return cellViewModel
            }}
            .subscribe(onNext: { [unowned self] viewModels in
                self.cellViewModelsSubject = viewModels
                self.reloadDataSubject.onNext(())
            })
            .disposed(by: disposeBag)
        
        deleteItemSubject
            .subscribe(onNext: { [unowned self] indexPath in
                let notification = (self.cellViewModelsSubject[indexPath.row] as! NotificationCollectionViewCellViewModel).notification
                self.cellViewModelsSubject.remove(at: indexPath.row)
                self.deletedNotificationSubject.onNext(notification)
            })
            .disposed(by: disposeBag)
    }
}
