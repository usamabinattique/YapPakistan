//
//  SomeInformationMissingViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 09/02/2022.
//

import Foundation
import RxSwift

protocol SomeInformationMissingViewModelInput {
    var goToDashboardObserver: AnyObserver<Void> { get }
}

protocol SomeInformationMissingViewModelOutput {
    var heading: Observable<String?> { get }
    var subHeading: Observable<String?> { get }
    var goToDashboard: Observable<Void> { get }
}

protocol SomeInformationMissingViewModelType {
    var inputs: SomeInformationMissingViewModelInput { get }
    var outputs: SomeInformationMissingViewModelOutput { get }
}

class SomeInformationMissingViewModel: SomeInformationMissingViewModelInput, SomeInformationMissingViewModelOutput, SomeInformationMissingViewModelType {
    

    // MARK: Properties

    var inputs: SomeInformationMissingViewModelInput { self }
    var outputs: SomeInformationMissingViewModelOutput { self }
    private let disposeBag = DisposeBag()

    private let goToDashboardSubject = PublishSubject<Void>()
    private let headingSubject: BehaviorSubject<String?>
    private let subHeadingSubject: BehaviorSubject<String?>

    // MARK: Inputs

    var goToDashboardObserver: AnyObserver<Void> { goToDashboardSubject.asObserver() }

    // MARK: Outputs

    var heading: Observable<String?> { headingSubject.asObservable() }
    var subHeading: Observable<String?> { subHeadingSubject.asObservable() }
    var goToDashboard: Observable<Void> { goToDashboardSubject.asObservable() }

    init() {

        headingSubject = BehaviorSubject(value: "screen_onboarding_missing_information_display_text_title".localized)
        subHeadingSubject = BehaviorSubject(value: "screen_onboarding_missing_information_display_text_sub_title".localized)
    }

}
