//
//  KYCInitialReviewViewModel.swift
//  YAPPakistan
//
//  Created by Tayyab on 28/09/2021.
//

import Foundation
import RxSwift
import YAPComponents

protocol KYCInitialReviewViewModelInput {
    var issueDateObserver: AnyObserver<Date> { get }
    var confirmObserver: AnyObserver<Void> { get }
    var rescanObserver: AnyObserver<Void> { get }
}

protocol KYCInitialReviewViewModelOutput {
    var subHeadingText: Observable<String> { get }
    var cnicNumber: Observable<String> { get }
    var issueDateTitle: Observable<String> { get }
    var issueDateValue: Observable<String> { get }
    var cnicInfo: Observable<CNICInfo> { get }
    var showError: Observable<String> { get }
    var rescan: Observable<Void> { get }
}

protocol KYCInitialReviewViewModelType {
    var inputs: KYCInitialReviewViewModelInput { get }
    var outputs: KYCInitialReviewViewModelOutput { get }
}

class KYCInitialReviewViewModel: KYCInitialReviewViewModelInput, KYCInitialReviewViewModelOutput, KYCInitialReviewViewModelType {

    // MARK: Properties

    private let disposeBag = DisposeBag()

    private var subHeadingSubject = BehaviorSubject<String>(value: "")
    private var cnicNumberSubject = BehaviorSubject<String>(value: "")
    private var issueDateTitleSubject = BehaviorSubject<String>(value: "")
    private var issueDateValueSubject = BehaviorSubject<String>(value: "")
    private var issueDateSubject = BehaviorSubject<Date>(value: Date())
    private var cnicInfoSubject = PublishSubject<CNICInfo>()
    private let showErrorSubject = PublishSubject<String>()

    private var confirmSubject = PublishSubject<Void>()
    private var rescanSubject = PublishSubject<Void>()

    var inputs: KYCInitialReviewViewModelInput { return self }
    var outputs: KYCInitialReviewViewModelOutput { return self }

    // MARK: Inputs

    var issueDateObserver: AnyObserver<Date> { issueDateSubject.asObserver() }
    var confirmObserver: AnyObserver<Void> { confirmSubject.asObserver() }
    var rescanObserver: AnyObserver<Void> { rescanSubject.asObserver() }

    // MARK: Outputs

    var subHeadingText: Observable<String> { subHeadingSubject.asObservable() }
    var cnicNumber: Observable<String> { cnicNumberSubject.asObservable() }
    var issueDateTitle: Observable<String> { issueDateTitleSubject.asObservable() }
    var issueDateValue: Observable<String> { issueDateValueSubject.asObservable() }
    var cnicInfo: Observable<CNICInfo> { cnicInfoSubject.asObservable() }
    var showError: Observable<String> { return showErrorSubject.asObservable() }
    var rescan: Observable<Void> { rescanSubject.asObservable() }

    // MARK: Initialization

    init(accountProvider: AccountProvider, kycRepository: KYCRepository, cnicOCR: CNICOCR) {
        cnicNumberSubject.onNext(cnicOCR.cnicNumber)
        issueDateTitleSubject.onNext("screen_kyc_initial_review_issue_date".localized)

        accountProvider.currentAccount
            .subscribe(onNext: { [weak self] account in
                let name = account?.customer.firstName ?? ""
                let heading = String(format: "screen_kyc_initial_review_screen_subtitle".localized, name)
                self?.subHeadingSubject.onNext(heading)
            })
            .disposed(by: disposeBag)

        issueDateSubject
            .subscribe(onNext: { [weak self] date in
                let dateFormatter = DateFormatter.appReadableDateFormatter
                let dateString = dateFormatter.string(from: date)
                self?.issueDateValueSubject.onNext(dateString)
            })
            .disposed(by: disposeBag)

        if let date = cnicOCR.issueDate {
            issueDateSubject.onNext(date)
        }

        let cnicRequest = confirmSubject.withLatestFrom(issueDateSubject)
            .do(onNext: { _ in
                YAPProgressHud.showProgressHud()
            })
            .flatMap { issueDate -> Observable<Event<CNICInfo?>> in
//                let cnic = cnicOCR.cnicNumber.replace(string: "-", replacement: "")
                // !!!: Random Cnic for testing
                let cnic = getRandomNumber()
                let dateFormatter = DateFormatter.serverReadableDateFromatter
                let dateOfIssuance = dateFormatter.string(from: issueDate)

                return kycRepository.performNadraVerification(cnic: cnic, dateOfIssuance: dateOfIssuance)
            }
            .do(onNext: { _ in
                YAPProgressHud.hideProgressHud()
            })
            .share()

        cnicRequest.elements()
            .unwrap()
            .bind(to: cnicInfoSubject)
            .disposed(by: disposeBag)

        cnicRequest.errors()
            .map { $0.localizedDescription }
            .bind(to: showErrorSubject)
            .disposed(by: disposeBag)
    }
}

private func getRandomNumber() -> String {
    var prefix = "352023333"
    let randomInt1 = Int.random(in: 1000 ... 5000)
    prefix += "\(randomInt1)"
    return prefix
}

