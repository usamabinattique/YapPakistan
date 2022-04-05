//
//  NotificationCollectionViewCell.swift
//  YAPPakistan
//
//  Created by Yasir on 04/04/2022.
//

import Foundation
import RxSwift

protocol NotificationCollectionViewCellViewModelInputs {
    var deleteNotificationObserver: AnyObserver<IndexPath> { get }
    var actionButtonTappedObserver: AnyObserver<IndexPath> { get }
}

protocol NotificationCollectionViewCellViewModelOutputs {
    var notificationTitle: Observable<String?> { get }
    var notifocationDescription: Observable<String?> { get }
    var notificationIcon: Observable<String?> { get }
    var deleteNotification: Observable<IndexPath> { get }
    var actionTapped: Observable<IndexPath> { get }
    var deletable: Observable<Bool> { get }
}

protocol NotificationCollectionViewCellViewModelType {
    var inputs: NotificationCollectionViewCellViewModelInputs { get }
    var outputs: NotificationCollectionViewCellViewModelOutputs { get }
}

class NotificationCollectionViewCellViewModel: NotificationCollectionViewCellViewModelType, ReusableCollectionViewCellViewModelType, NotificationCollectionViewCellViewModelInputs, NotificationCollectionViewCellViewModelOutputs {
    
    var reusableIdentifier: String { return NotificationCollectionViewCell.defaultIdentifier }

    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: NotificationCollectionViewCellViewModelInputs { return self }
    var outputs: NotificationCollectionViewCellViewModelOutputs { return self }
    
    private let notificationIconSubject: BehaviorSubject<String?>
    private let notificationTitleSubject: BehaviorSubject<String?>
    private let notificationDescriptionSubject: BehaviorSubject<String?>
    private let deleteNotificationSubject = PublishSubject<IndexPath>()
    private let actionButtonSubject = PublishSubject<IndexPath>()
    private let deletableSubject = BehaviorSubject<Bool>(value: true)
    
    // MARK:- Inputs
    var deleteNotificationObserver: AnyObserver<IndexPath> { return deleteNotificationSubject.asObserver() }
    var actionButtonTappedObserver: AnyObserver<IndexPath> { return actionButtonSubject.asObserver() }
    
    // MARK: - Outputs
    var notificationIcon: Observable<String?> { return notificationIconSubject.asObservable() }
    var notifocationDescription: Observable<String?> { return notificationDescriptionSubject.asObservable() }
    var notificationTitle: Observable<String?> { return notificationTitleSubject.asObservable() }
    var deleteNotification: Observable<IndexPath> { return deleteNotificationSubject.asObservable() }
    var deletable: Observable<Bool> { return deletableSubject.asObservable() }
    var actionTapped: Observable<IndexPath> { return actionButtonSubject.asObservable() }
    
    let notification: InAppNotification
    
    init(notification: InAppNotification) {
        self.notification = notification
        notificationTitleSubject = BehaviorSubject(value: notification.title)
        notificationDescriptionSubject = BehaviorSubject(value: notification.description)
        notificationIconSubject = BehaviorSubject(value: notification.imageUrl)
    }
}
