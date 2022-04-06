////
////  PersonalDetailsViewModel.swift
////  YAPPakistan
////
////  Created by Awais on 06/04/2022.
////
//
//import Foundation
//import RxSwift
//import YAPComponents
//
//
//protocol PersonalDetailsViewModelInputs {
//    var viewWillAppearObserver: AnyObserver<Void> { get }
//    var editPhoneTapObserver: AnyObserver<Void> { get }
//    var editEmailTapObserver: AnyObserver<Void> { get }
//    var editAddressTapObserver: AnyObserver<Void> { get }
//    var emiratesIDStatusObserver: AnyObserver<UserProfileViewModel.EmiratesIDStatus> { get }
//    var updateEmiratesIDTapObserver: AnyObserver<Void> { get }
//    var backObserver: AnyObserver<Void> { get }
//    var addressUpdatedObserver: AnyObserver<Void> { get }
//}
////
//protocol PersonalDetailsViewModelOutputs {
//    var title: Observable<String> { get }
//    var fullName: Observable<String?> { get }
//    var phone: Observable<String> { get }
//    var editPhoneTap: Observable<Void> { get }
//    var email: Observable<String> { get }
//    var editEmailTap: Observable<Void> { get }
//    var address: Observable<String?> { get }
//    var editAddressTap: Observable<Void> { get }
//    var emiratesIDStatus: Observable<UserProfileViewModel.EmiratesIDStatus> { get }
//    var updateEmiratesIDTap: Observable<Void> { get }
//    var error: Observable<Error> { get }
//    var back: Observable<Void> { get }
//    var isRunning: Observable<Bool> { get }
//    var showBlockedOTPError: Observable<String>{ get }
//}
//
//protocol PersonalDetailsViewModelType {
//    var inputs: PersonalDetailsViewModelInputs { get }
//    var outputs: PersonalDetailsViewModelOutputs { get }
//}
//
//class PersonalDetailsViewModel: PersonalDetailsViewModelType, PersonalDetailsViewModelInputs, PersonalDetailsViewModelOutputs {
//
//    // MARK: - Properties
//    let disposeBag = DisposeBag()
//    var inputs: PersonalDetailsViewModelInputs { return self }
//    var outputs: PersonalDetailsViewModelOutputs { return self }
//
//    private let customer: Observable<Customer>
//    private let viewWillAppearSubject = PublishSubject<Void>()
//    private var emiratesIDStatusSubject = BehaviorSubject<UserProfileViewModel.EmiratesIDStatus>(value: .none)
//    private let addressSubject = PublishSubject<String?>()
//    private let editPhoneTapSubject = PublishSubject<Void>()
//    private let editEmailTapSubject = PublishSubject<Void>()
//    private let editAddressTapSubject = PublishSubject<Void>()
//    private let updateEmiratesIDTapSubject = PublishSubject<Void>()
//    private let blockedOTPErrorMessageSubject = PublishSubject<String>()
//    private let errorSubject = PublishSubject<Error>()
//    private let backSubject = PublishSubject<Void>()
//    private let addressUpdatedSubject = BehaviorSubject<Void>(value: ())
//
//
//    // MARK: - Inputs
//    var editPhoneTapObserver: AnyObserver<Void> { return editPhoneTapSubject.asObserver() }
//    var editEmailTapObserver: AnyObserver<Void> { return editEmailTapSubject.asObserver() }
//    var editAddressTapObserver: AnyObserver<Void> { return editAddressTapSubject.asObserver() }
//    var emiratesIDStatusObserver: AnyObserver<UserProfileViewModel.EmiratesIDStatus> { return emiratesIDStatusSubject.asObserver() }
//    var updateEmiratesIDTapObserver: AnyObserver<Void> { return updateEmiratesIDTapSubject.asObserver() }
//    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
//    var addressUpdatedObserver: AnyObserver<Void> { return addressUpdatedSubject.asObserver() }
//
//    // MARK: - Outputs
//    var viewWillAppearObserver: AnyObserver<Void> { return viewWillAppearSubject.asObserver() }
//    var title: Observable<String> { return Observable.of( "screen_personal_details_display_text_title".localized) }
//    var fullName: Observable<String?> { return customer.map { $0.fullName } }
//    var phone: Observable<String> { return customer.map { $0.mobileNo } }
//    var editPhoneTap: Observable<Void> { return editPhoneTapSubject.asObservable() }
//    var email: Observable<String> { return customer.map { $0.email } }
//    var editEmailTap: Observable<Void> { return editEmailTapSubject.asObservable() }
//    var address: Observable<String?> { return addressSubject.asObservable() }
//    var editAddressTap: Observable<Void> { return editAddressTapSubject.asObservable() }
//    var emiratesIDStatus: Observable<UserProfileViewModel.EmiratesIDStatus> { return emiratesIDStatusSubject.asObservable() }
//    var updateEmiratesIDTap: Observable<Void> { return updateEmiratesIDTapSubject.asObservable() }
//    var error: Observable<Error> { return errorSubject.asObservable() }
//    var back: Observable<Void> { return backSubject.asObservable() }
//    var isRunning: Observable<Bool> {
//        return Observable.from([
//            addressUpdatedSubject.map { _ in true },
//            addressSubject.map { _ in false },
//            errorSubject.map { _ in false }
//        ]).merge()
//    }
//    var showBlockedOTPError: Observable<String>{ blockedOTPErrorMessageSubject.asObservable() }
//    // MARK: - Init
//    init(_ customer: Observable<Customer>,
//         //emiratesIDStatus: UserProfileViewModel.EmiratesIDStatus,
//         //profileRepository: ProfileRepository = ProfileRepository()) {
//        self.customer = customer
//
//        //emiratesIDStatusSubject = BehaviorSubject(value: emiratesIDStatus)
//
////        let request = addressUpdatedSubject.flatMap { profileRepository.getLastLocation() }.do(onNext: { _ in YAPProgressHud.hideProgressHud() }).share(replay: 1, scope: .whileConnected)
////
////        request.elements().unwrap().map { [$0.address1, $0.address2, $0.city].compactMap{ $0 }.joined(separator: ", ") }.bind(to: addressSubject).disposed(by: disposeBag)
////        request.errors().bind(to: errorSubject).disposed(by: disposeBag)
////    }
//}
