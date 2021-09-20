//
//  OnBoardingWaitingListViewModel.swift
//  OnBoarding
//
//  Created by Zain on 04/08/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import RxSwift

protocol OnBoardingWaitingListViewModelInput {
    var keepMePostedObserver: AnyObserver<Void> { get }
}

protocol OnBoardingWaitingListViewModelOutput {
    var heading: Observable<String?> { get }
    var subHeading: Observable<String?> { get }
    var keepMePosted: Observable<URL> { get }
}

protocol OnBoardingWaitingListViewModelType {
    var inputs: OnBoardingWaitingListViewModelInput { get }
    var outputs: OnBoardingWaitingListViewModelOutput { get }
}

class OnBoardingWaitingListViewModel: OnBoardingWaitingListViewModelInput, OnBoardingWaitingListViewModelOutput, OnBoardingWaitingListViewModelType {

    // MARK: Properties

    var inputs: OnBoardingWaitingListViewModelInput { self }
    var outputs: OnBoardingWaitingListViewModelOutput { self }
    private let disposeBag = DisposeBag()

    private let keepMePostedSubject = PublishSubject<Void>()
    private let headingSubject: BehaviorSubject<String?>
    private let subHeadingSubject: BehaviorSubject<String?>

    // MARK: Inputs

    var keepMePostedObserver: AnyObserver<Void> { keepMePostedSubject.asObserver() }

    // MARK: Outputs

    var heading: Observable<String?> { headingSubject.asObservable() }
    var subHeading: Observable<String?> { subHeadingSubject.asObservable() }
    var keepMePosted: Observable<URL> { keepMePostedSubject.map{ URL(string: "https://www.yap.com/") }.unwrap().asObservable() }

    init(_ waitingListNumber: Int) {

        headingSubject = BehaviorSubject(value: "screen_waiting_list_dispaly_text_heading".localized)
        subHeadingSubject = BehaviorSubject(value: "screen_waiting_list_dispaly_text_sub_heading".localized)
    }

}
