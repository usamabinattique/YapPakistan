//
//  PhoneNumberViewModel.swift
//  YAP
//
//  Created by Zain on 24/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPComponents
import PhoneNumberKit

typealias TextChange = (text: String, range: NSRange, currentText: String?)

protocol PhoneNumberViewModelInput {
    var textObserver: AnyObserver<String?> { get }
    var iconTapObserver: AnyObserver<Void> { get }
    var countrySelectionObserver: AnyObserver<Int> { get }
    var textWillChangeObserver: AnyObserver<TextChange> { get }
    var sendObserver: AnyObserver<OnboardingStage> { get }
    var viewAppearedObserserver: AnyObserver<Bool> { get }
    var stageObserver: AnyObserver<OnboardingStage> { get }
    var poppedObserver: AnyObserver<Void> { get }
}

protocol PhoneNumberViewModelOutput {
    var text: Observable<NSAttributedString?> { get }
    var inputValidation: Observable<AppRoundedTextFieldValidation> { get }
    var icon: Observable<String?> { get }
    var iconTapped: Observable<Void> { get }
    var countries: Observable<[String]> { get }
    var shouldChange: Bool { get }
    var validInput: Observable<Bool> { get }
    var result: Observable<OnBoardingUser> { get }
    var showError: Observable<String> { get }
    var endEditting: Observable<Bool> { get }
    var progress: Observable<Float> { get }
    var stage: Observable<OnboardingStage> { get }
}

protocol PhoneNumberViewModelType {
    var inputs: PhoneNumberViewModelInput { get }
    var outputs: PhoneNumberViewModelOutput { get }
}

class PhoneNumberViewModel: PhoneNumberViewModelInput, PhoneNumberViewModelOutput, PhoneNumberViewModelType {
    var inputs: PhoneNumberViewModelInput { return self }
    var outputs: PhoneNumberViewModelOutput { return self }

    private let textSubject = BehaviorSubject<NSAttributedString?>(value: NSAttributedString(string: ""))
    private let textObserverSubject = PublishSubject<String?>()
    private let validationSubject = BehaviorSubject<AppRoundedTextFieldValidation>(value: .neutral)
    private let iconTapSubject = PublishSubject<Void>()
    private let iconSubject = BehaviorSubject<String?>(value: nil)
    private let countrySelectionSubject = PublishSubject<Int>()
    private let countriesSubject = BehaviorSubject<[String]>(value: [])
    private var shouldChangeSub = true
    private let textWillChangeSubject = PublishSubject<TextChange>()
    private let validSubject = PublishSubject<Bool>()
    private let resultSubject = PublishSubject<OnBoardingUser>()
    private let sendSubject = PublishSubject<OnboardingStage>()
    private let viewAppearedSubject = PublishSubject<Bool>()
    private let showErrorSubject = PublishSubject<String>()
    private let endEdittingSubject = PublishSubject<Bool>()
    private let progressSubject = PublishSubject<Float>()
    private let stageSubject = PublishSubject<OnboardingStage>()
    private let poppedSubject = PublishSubject<Void>()

    // inputs
    var textObserver: AnyObserver<String?> { return textObserverSubject.asObserver() }
    var iconTapObserver: AnyObserver<Void> { return iconTapSubject.asObserver() }
    var countrySelectionObserver: AnyObserver<Int> { return countrySelectionSubject.asObserver() }
    var textWillChangeObserver: AnyObserver<TextChange> { return textWillChangeSubject.asObserver() }
    var sendObserver: AnyObserver<OnboardingStage> { return sendSubject.asObserver() }
    var viewAppearedObserserver: AnyObserver<Bool> { return viewAppearedSubject.asObserver() }
    var stageObserver: AnyObserver<OnboardingStage> { return stageSubject.asObserver() }
    var poppedObserver: AnyObserver<Void> { return poppedSubject.asObserver() }

    // outputs
    var text: Observable<NSAttributedString?> { return textSubject.asObservable() }
    var inputValidation: Observable<AppRoundedTextFieldValidation> { return validationSubject.asObservable() }
    var icon: Observable<String?> { return iconSubject.asObservable() }
    var iconTapped: Observable<Void> { return iconTapSubject.asObservable() }
    var countries: Observable<[String]> { return countriesSubject.asObservable() }
    var shouldChange: Bool { return shouldChangeSub }
    var validInput: Observable<Bool> { return validSubject.asObservable() }
    var result: Observable<OnBoardingUser> { return resultSubject.asObservable() }
    var showError: Observable<String> { return showErrorSubject.asObservable() }
    var endEditting: Observable<Bool> { return endEdittingSubject.asObservable() }
    var progress: Observable<Float> { return progressSubject.asObservable() }
    var stage: Observable<OnboardingStage> { return stageSubject.asObservable() }

    private var countryList = [Country]()
    private let disposeBag = DisposeBag()
    private var currentItem = 0
    private var isFormatted = false
    private var user: OnBoardingUser!
    private let repositoryProvider: (_ countryCode: String) -> OnBoardingRepositoryType
    private let countryListProvider: CountryListProviderType

    private var repository: OnBoardingRepositoryType?

    init(repositoryProvider: @escaping (_ countryCode: String) -> OnBoardingRepositoryType,
         user: OnBoardingUser,
         countryListProvider: CountryListProviderType) {
        self.repositoryProvider = repositoryProvider
        self.user = user
        self.countryListProvider = countryListProvider
        self.countryList = countryListProvider.list()

        iconSubject.onNext(countryList.first?.flagIconImageName)
        textSubject.onNext(self.attributed(text: countryList.first?.callingCode ?? ""))

        countriesSubject.onNext(countryList.map { $0.name })
        countrySelectionSubject.map { _ in false }.bind(to: validSubject).disposed(by: disposeBag)
        countrySelectionSubject.map { [unowned self] index in self.attributed(text: self.countryList[index].callingCode) }.bind(to: textSubject).disposed(by: disposeBag)
        countrySelectionSubject.do(onNext: { [unowned self] in self.currentItem = $0 }).map { [unowned self] index in self.countryList[index].flagIconImageName }.bind(to: iconSubject).disposed(by: disposeBag)

        let formattedText = textObserverSubject
            .do(onNext: {[unowned self] in self.user.mobileNo.formattedValue = $0})
            .unwrap()
            .map { $0.toFormatedPhone }
            .do(onNext: { [unowned self] in self.isFormatted = $0.isFormated} )

        formattedText.map { return $0.isFormated }
            .bind(to: validSubject)
            .disposed(by: disposeBag)
        formattedText.map { $0.isFormated ? .valid : .neutral }
            .bind(to: validationSubject)
            .disposed(by: disposeBag)
        formattedText.map { [unowned self] in self.attributed(text: $0.number) }
            .bind(to: textSubject)
            .disposed(by: disposeBag)

        textWillChangeSubject.do(onNext: { [unowned self] text, range, currentText in
            let currentText = (currentText ?? "").replacingOccurrences(of: " ", with: "")
            self.shouldChangeSub = (range.location > self.countryList[self.currentItem].callingCode.count - 1 &&
                                        (currentText.count + text.count < 14 || text.count == 0)) && (!self.isFormatted || text.count == 0)
        }).subscribe().disposed(by: disposeBag)

        let request = sendSubject.filter {
            if case OnboardingStage.phone = $0 { return true }
            return false
        }
            .do(onNext: {[unowned self] _ in
            self.endEdittingSubject.onNext(true)
        })
        .map { [unowned self] _ in self.user.mobileNo }.unwrap().flatMap { [unowned self] phone -> Observable<Event<String?>> in
            YAPProgressHud.showProgressHud()
            self.repository = repositoryProvider("PK")
            return self.repository!.signUpOTP(countryCode: phone.countryCode ?? "",
                                              mobileNo: phone.number ?? "",
                                              accountType: user.accountType.rawValue)
        }.do(onNext: {_ in
                YAPProgressHud.hideProgressHud()
            }).share()

        let error = request.errors().map { $0.localizedDescription }
        error
            .bind(to: showErrorSubject).disposed(by: disposeBag)

//        error
//            .map{ OnBoardingEvent.phoneNumberError(["error" : $0])}
//            .bind(to: AppAnalytics.shared.rx.logEvent)
//            .disposed(by: disposeBag)

        request.elements().map { [weak self] _ in self?.user }.unwrap().bind(to: resultSubject).disposed(by: disposeBag)

        let viewAppeared = viewAppearedSubject.filter { $0 }
        viewAppeared.map { [unowned self] _ -> Float in return self.user.accountType == .b2cAccount ? 0.2 : 0.428 }.bind(to: progressSubject).disposed(by: disposeBag)
        viewAppeared.map { [unowned self] _ in self.isFormatted }.bind(to: validSubject).disposed(by: disposeBag)

        poppedSubject.subscribe(onNext: { [unowned self] in
            self.resultSubject.onCompleted()
            self.validSubject.onCompleted()
            self.stageSubject.onCompleted()
            self.progressSubject.onCompleted()
            self.sendSubject.dispose()
        }).disposed(by: disposeBag)
    }
}

private extension PhoneNumberViewModel {
    func attributed(text: String) -> NSAttributedString {
        let length = text.components(separatedBy: " ").first?.count ?? 0
        let attributed = NSMutableAttributedString(string: text)
        attributed.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.blue/*appColor(ofType: .primaryDark)*/.withAlphaComponent(0.5)], range: NSRange(location: 0, length: length))
        return attributed
    }
}

extension String {
    var toSimplePhoneNumber:String {
        return self.replacingOccurrences(of: "+", with: "00").replacingOccurrences(of: " ", with: "")
    }

    var toFormatedPhoneNumber: String {
        guard self.count > 2 else { return self }

        let phoneNumberKit = PhoneNumberKit()
        if let pNumber = try? phoneNumberKit.parse(self) {
            let formattedNumber = phoneNumberKit.format(pNumber, toType: .international)
            return formattedNumber
        }

        return self
    }

    var toFormatedPhone:(number: String, isFormated: Bool) {
        let phoneNumberKit = PhoneNumberKit()
        if let pNumber = try? phoneNumberKit.parse(self) {
            let formattedNumber = phoneNumberKit.format(pNumber, toType: .international)
            return (formattedNumber, true)
        }
        return (self, false)
    }
}
