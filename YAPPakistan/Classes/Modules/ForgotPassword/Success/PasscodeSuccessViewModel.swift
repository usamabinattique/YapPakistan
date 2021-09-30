//
//  PasscodeSuccessViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 30/09/2021.
//

import RxSwift

protocol PasscodeSuccessViewModelInputs {
    var actionObserver: AnyObserver<Void> { get }
}

protocol PasscodeSuccessViewModelOutputs {
    var action: Observable<Void> { get }
    var headingTitle: Observable<String?> { get }
    var subHeadingTitle: Observable<String?> { get }
    var actionButtonTitle: Observable<String?> { get }
}

protocol PasscodeSuccessViewModelType {
    var inputs: PasscodeSuccessViewModelInputs { get }
    var outputs: PasscodeSuccessViewModelOutputs { get }
}

class PasscodeSuccessViewModel: PasscodeSuccessViewModelType,
                                PasscodeSuccessViewModelInputs,
                                PasscodeSuccessViewModelOutputs {

    // MARK: Inputs and Outputs
    var inputs: PasscodeSuccessViewModelInputs { return self }
    var outputs: PasscodeSuccessViewModelOutputs { return self }

    // MARK: - Protocol Inputs implementation
    var actionObserver: AnyObserver<Void> { return actionSubject.asObserver() }

    // MARK: - Protottcol Outputs implementation
    var action: Observable<Void> { return actionSubject.asObservable() }
    var actionButtonTitle: Observable<String?> { actionButtonTitleSubject.asObservable() }
    var headingTitle: Observable<String?> { headingTitleSubject.asObservable() }
    var subHeadingTitle: Observable<String?> { subHeadingTitleSubject.asObservable() }

    // MARK: - Subjects
    private var actionSubject = PublishSubject<Void>()
    private var headingTitleSubject: BehaviorSubject<String?>
    private var subHeadingTitleSubject: BehaviorSubject<String?>
    private var actionButtonTitleSubject: BehaviorSubject<String?>

    init(passcodeSuccessViewStrings: PasscodeSuccessViewStrings) {
        headingTitleSubject = BehaviorSubject(value: passcodeSuccessViewStrings.heading)
        subHeadingTitleSubject = BehaviorSubject(value: passcodeSuccessViewStrings.subHeading)
        actionButtonTitleSubject = BehaviorSubject(value: passcodeSuccessViewStrings.action)
    }
}

struct PasscodeSuccessViewStrings {
    var heading: String
    var subHeading: String
    var action: String
}
