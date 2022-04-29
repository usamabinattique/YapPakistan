//
//  ChangeEmailSuccessViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 20/04/2022.
//

import Foundation
import RxSwift

import YAPComponents

protocol UnvarifiedEmailSuccessViewModelInputs {
    var backObserver: AnyObserver<Void> { get }
    var mailActionObserver: AnyObserver<Void> { get }
    var openOutlookObserver: AnyObserver<Void> { get }
    var openGmailObserver: AnyObserver<Void> { get }
    var openMailObserver: AnyObserver<Void> { get }
    var checkMailAppOptionsAvailablityObserver: AnyObserver<Void> { get }
}

protocol UnvarifiedEmailSuccessViewModelOutputs {
    var heading: Observable<String?> { get }
    var subHeading: Observable<NSAttributedString?> { get }
    var successImeg: Observable<UIImage?> { get }
    var description: Observable<String?> { get }
    var mailButtonTitle: Observable<String?> { get }
    var backTitle: Observable<String?> { get }
    var back: Observable<Void> { get }
    var mailAction: Observable<Void> { get }
    var openOutlook: Observable<Void> { get }
    var openGmail: Observable<Void> { get }
    var openMail: Observable<Void> { get }
    var checkMailAppOptionsAvailablity: Observable<Void> { get }
    //var suggestMailAppOptions: Observable<MailOption?> { get }
}

protocol UnvarifiedEmailSuccessViewModelType {
    var inputs: UnvarifiedEmailSuccessViewModelInputs { get }
    var outputs: UnvarifiedEmailSuccessViewModelOutputs { get }
}

class UnvarifiedEmailSuccessViewModel: UnvarifiedEmailSuccessViewModelType, UnvarifiedEmailSuccessViewModelInputs, UnvarifiedEmailSuccessViewModelOutputs {

    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: UnvarifiedEmailSuccessViewModelInputs { return self}
    var outputs: UnvarifiedEmailSuccessViewModelOutputs { return self }

    let headingSubject: BehaviorSubject<String?>
    let subHeadingSubject = BehaviorSubject<NSAttributedString?>(value: nil)
    let successImageSubject: BehaviorSubject<UIImage?>
    let descriptionSubject: BehaviorSubject<String?>
    let mailButtonTitleSubject: BehaviorSubject<String?>
    let backTitleSubject: BehaviorSubject<String?>
    let backSubject = PublishSubject<Void>()
    let mailActionSubject = PublishSubject<Void>()
    let openOutlookSubject = PublishSubject<Void>()
    let openGmailSubject = PublishSubject<Void>()
    let openMailSubject = PublishSubject<Void>()
    let checkMailAppOptionsAvailablitySubject = PublishSubject<Void>()
    //let suggestMailAppOptionsSubject = BehaviorSubject<MailOption?>(value: nil)

    //Inputs
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    var mailActionObserver: AnyObserver<Void> { return mailActionSubject.asObserver() }
    var openMailObserver: AnyObserver<Void> { return openMailSubject.asObserver() }
    var openGmailObserver: AnyObserver<Void> { return openGmailSubject.asObserver() }
    var openOutlookObserver: AnyObserver<Void> { return openOutlookSubject.asObserver() }
    var checkMailAppOptionsAvailablityObserver: AnyObserver<Void> { return checkMailAppOptionsAvailablitySubject.asObserver() }

    //Outputs
    var openMail: Observable<Void> { return openMailSubject.asObserver() }
    var openGmail: Observable<Void> { return openGmailSubject.asObserver() }
    var openOutlook: Observable<Void> { return openOutlookSubject.asObserver() }
    var heading: Observable<String?> { return headingSubject.asObservable() }
    var subHeading: Observable<NSAttributedString?> { return subHeadingSubject.asObservable() }
    var successImeg: Observable<UIImage?> { return successImageSubject.asObservable() }
    var description: Observable<String?> { return descriptionSubject.asObservable() }
    var mailButtonTitle: Observable<String?> { return mailButtonTitleSubject.asObservable() }
    var backTitle: Observable<String?> { return backTitleSubject.asObservable() }
    var back: Observable<Void> { return backSubject.asObservable() }
    var mailAction: Observable<Void> { return mailActionSubject.asObservable() }
    //var suggestMailAppOptions: Observable<MailOption?> { return suggestMailAppOptionsSubject.asObservable() }
    var checkMailAppOptionsAvailablity: Observable<Void> { return checkMailAppOptionsAvailablitySubject.asObservable() }

    let outlookURL = URL(string: "ms-outlook:///")!
    let gmailURL = URL(string: "googlegmail:///")!
    let mailURL = URL(string: "message://")!

    public init(changedEmailOrPhoneString : String, descriptionText: String) {
        
//        // MARK: Unverified success Screen
//        "screen_unverified_success_display_text_heading" = "Success!";
//        "screen_unverified_success_display_text_sub_heading" = "Your email address has been changed to\n%@";
//        "screen_unverified_success_display_text_description" = "Please log in to your email address to validate your email and continue with\naccess to YAP!";
//        "screen_unverified_display_button_mail" = "Open mail app";
//        "screen_unverified_display_button_back_to_dashboard" = "Back to dashboard";

        headingSubject = BehaviorSubject(value:  "screen_unverified_success_display_text_heading".localized)
        successImageSubject = BehaviorSubject(value: UIImage(named: "image_email_verified", in: .yapPakistan, compatibleWith: nil)) // Change Image here
        descriptionSubject = BehaviorSubject(value:  "screen_unverified_success_display_text_description".localized)
        mailButtonTitleSubject = BehaviorSubject(value:  "screen_unverified_display_button_mail".localized)
        backTitleSubject = BehaviorSubject(value:  "common_button_Done".localized)
        subHeadingSubject.onNext(self.makeAttributesEmailAddress(email: changedEmailOrPhoneString, descriptionText: descriptionText))

//        mailAction.subscribe(onNext: {[unowned self] _ in
//            self.checkMailAppOptionsAvailablitySubject.onNext(())
//        }).disposed(by: disposeBag)
//
//        checkMailAppOptionsAvailablity.subscribe(onNext: {[unowned self] _ in
//            self.checkMailAppOptions()
//        }).disposed(by: disposeBag)
//
//        initiallizeMailActions()
    }

}

extension UnvarifiedEmailSuccessViewModel {

    func makeAttributesEmailAddress(email: String, descriptionText: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: String(format:  descriptionText.localized, email), attributes: [
            .font: UIFont.systemFont(ofSize: 16.0, weight: .regular),
            .foregroundColor: UIColor(red: 147.0 / 255.0, green: 145.0 / 255.0, blue: 177.0 / 255.0, alpha: 1.0)
        ])
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 39.0 / 255.0, green: 34.0 / 255.0, blue: 98.0 / 255.0, alpha: 1.0), range: NSRange(location: 39, length: email.count))

        return attributedString
    }
}

extension UnvarifiedEmailSuccessViewModel {

//    func checkMailAppOptions() {
//        var mailOptions = MailOption()
//
//        if UIApplication.shared.canOpenURL(self.outlookURL) { mailOptions.outlook = true }
//        if UIApplication.shared.canOpenURL(self.gmailURL) { mailOptions.gmail = true }
//        if UIApplication.shared.canOpenURL(self.mailURL) { mailOptions.mail = true }
//
//        if mailOptions.outlook == false && mailOptions.gmail == false {
//            openMailSubject.onNext(())
//        } else {
//            suggestMailAppOptionsSubject.onNext(mailOptions)
//        }
//
//    }

//    func initiallizeMailActions() {
//
//        openOutlook.subscribe(onNext: {[unowned self] _ in
//            if UIApplication.shared.canOpenURL(self.outlookURL) {
//                UIApplication.shared.open(self.outlookURL, options: [:], completionHandler: nil)
//            }
//        }).disposed(by: disposeBag)
//
//        openGmail.subscribe(onNext: {[unowned self] _ in
//            if UIApplication.shared.canOpenURL(self.gmailURL) {
//                UIApplication.shared.open(self.gmailURL, options: [:], completionHandler: nil)
//            }
//        }).disposed(by: disposeBag)
//
//        openMail.subscribe(onNext: {[unowned self] _ in
//            if UIApplication.shared.canOpenURL(self.mailURL) {
//                UIApplication.shared.open(self.mailURL, options: [:], completionHandler: nil)
//            }
//        }).disposed(by: disposeBag)
//    }

}
