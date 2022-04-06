//
//  UserProfileViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 30/03/2022.
//

import Foundation
import RxSwift
import YAPComponents
import RxDataSources
import YAPCore
//import Authentication
//import Networking

enum UserProfileTableViewAccessory {
    case button(String)
    case toggleSwitch(Bool)
}

enum UserProfileTableViewAction {
    case button(Void)
    case toggleSwitch(Bool)
}

enum UserProfileItemType {
    case profileItem
    case logout
}

struct UserProfileTableViewItem {
    let icon: UIImage?
    let title: String
    let warning: Observable<Bool>
    let type: UserProfileItemType
    let accessory: UserProfileTableViewAccessory?
    let actionObserver: AnyObserver<UserProfileTableViewAction>

    init(icon: UIImage? = nil,
         title: String = "",
         warning: Observable<Bool> = Observable.of(false),
         type: UserProfileItemType = .profileItem,
         accessory: UserProfileTableViewAccessory? = nil,
         actionObserver: AnyObserver<UserProfileTableViewAction>) {
        self.icon = icon
        self.title = title
        self.warning = warning
        self.type = type
        self.accessory = accessory
        self.actionObserver = actionObserver
    }
}

// MARK: - UserProfileViewModel
protocol UserProfileViewModelInputs {
    var viewWillAppearObserver: AnyObserver<Void> { get }
    var profilePhotoEditObserver: AnyObserver<Void> { get }
    var openCameraTapObserver: AnyObserver<Void> { get }
    var chooosePhotoTapObserver: AnyObserver<Void> { get }
    var changedProfilePhotoObserver: AnyObserver<UIImage?> { get }
    var personalDetailsTapObserver: AnyObserver<UserProfileTableViewAction> { get }
    var privacyTapObserver: AnyObserver<UserProfileTableViewAction> { get }
    var passcodeTapObserver: AnyObserver<UserProfileTableViewAction> { get }
    var appNotificationsDidChangeObserver: AnyObserver<UserProfileTableViewAction> { get }
    var faceIDDidChangeObserver: AnyObserver<UserProfileTableViewAction> { get }
    var termsConditionsTapObserver: AnyObserver<UserProfileTableViewAction> { get }
    var feeAndPricingPlanTapObserver: AnyObserver<UserProfileTableViewAction> { get }
    var intagramTapObserver: AnyObserver<UserProfileTableViewAction> { get }
    var twitterTapObserver: AnyObserver<UserProfileTableViewAction> { get }
    var facebookTapObserver: AnyObserver<UserProfileTableViewAction> { get }
    var logoutTapObserver: AnyObserver<UserProfileTableViewAction> { get }
    var backObserver: AnyObserver<Void> { get }
    var logoutConfirmObserver: AnyObserver<Void>{ get }
    var removePhotoTapObserver: AnyObserver<Void> { get }
}

protocol UserProfileViewModelOutputs {
    var fullName: Observable<String?> { get }
    var emiratesID: Observable<Document?> { get }
    var isEmiratesIDExpired: Observable<UserProfileViewModel.EmiratesIDStatus> { get }
    var profilePhotoURL: Observable<URL?> { get }
    var profilePhotoEditTap: Observable<Void> { get }
    var openCameraTap: Observable<Void> { get }
    var choosePhotoTap: Observable<Void> { get }
    var changedProfilePhoto: Observable<UIImage?> { get }
    var userProfileItems: Observable<[SectionModel<String, UserProfileTableViewCellViewModelType>]> { get }
    var personalDetailsTap: Observable<Void> { get }
    var changePasscodeTap: Observable<Void> { get }
    var logoutTap: Observable<Void> { get }
    var error: Observable<Error> { get }
    var isRunning: Observable<Bool> { get }
    var back: Observable<Void> { get }
    var result: Observable<Void> { get }
    var openTermsAndConditions: Observable<Void> { get }
    var openFeeAndPricingPlan: Observable<Void> { get }
    var logoutConfirm: Observable<Void>{ get }
    var profilePhotoEditButtonImage: Observable<UIImage?>{ get }
    var removePhotoTap: Observable<Void> { get }
    var removeProfilePhotoFlag: Observable<Bool>{ get }
    var accentColor: Observable<UIColor> { get }
    var userNotificationPreference:Observable<Bool> {get}
    var dismiss: Observable<Void> { get }
}

protocol UserProfileViewModelType {
    var inputs: UserProfileViewModelInputs { get }
    var outputs: UserProfileViewModelOutputs { get }
}

class UserProfileViewModel: UserProfileViewModelType, UserProfileViewModelInputs, UserProfileViewModelOutputs {

    // MARK: - Properties
    let disposeBag = DisposeBag()
    let biometricsManager: BiometricsManager
    var inputs: UserProfileViewModelInputs { return self }
    var outputs: UserProfileViewModelOutputs { return self }
    var credentialStore: CredentialsStoreType!
    var notificationManager: NotificationManagerType!

    private let customer: Observable<Customer>
    private let viewWillAppearSubject = PublishSubject<Void>()
    private let emiratesIDSubject = PublishSubject<Document?>()
    private let profilePhotoEditSubject = PublishSubject<Void>()
    private let choosePhotoTapSubject = PublishSubject<Void>()
    private let openCameraTapSubject = PublishSubject<Void>()
    private let changedProfilePhotoSubject = PublishSubject<UIImage?>()
    private let profilePhotoURLSubject = BehaviorSubject<URL?>(value: nil)
    private var userProfileItemsSubject = BehaviorSubject<[SectionModel<String, UserProfileTableViewCellViewModelType>]>(value: [])
    private let personalDetailsTapSubject = PublishSubject<UserProfileTableViewAction>()
    private let privacyTapSubject = PublishSubject<UserProfileTableViewAction>()
    private let passcodeTapSubject = PublishSubject<UserProfileTableViewAction>()
    private let appNotificationsDidChangeSubject = PublishSubject<UserProfileTableViewAction>()
    private let faceIDDidChangeSubject = PublishSubject<UserProfileTableViewAction>()
    private let termsConditionsTapTapSubject = PublishSubject<UserProfileTableViewAction>()
    private let feeAndPricingPlanTapSubject = PublishSubject<UserProfileTableViewAction>()
    private let instagramTapSubject = PublishSubject<UserProfileTableViewAction>()
    private let twitterTapSubject = PublishSubject<UserProfileTableViewAction>()
    private let facebookTapSubject = PublishSubject<UserProfileTableViewAction>()
    private let logoutTapSubject = PublishSubject<UserProfileTableViewAction>()
    private let errorSubject = PublishSubject<Error>()
    private let backSubject = PublishSubject<Void>()
    private let resultSubject = PublishSubject<Void>()
    private let emiratedIdExpiredSbuject = BehaviorSubject<EmiratesIDStatus>(value: .none)
    private let logoutConfirmSubject = PublishSubject<Void>()
    private let profilePhotoEditButtonImageSubject = BehaviorSubject<UIImage?>(value: UIImage.init(named: "icon_edit_profile_photo", in: .yapPakistan, compatibleWith: nil))
    private let removePhotoTapSubject = PublishSubject<Void>()
    private let removeProfilePhotoFlagSubject = BehaviorSubject<Bool>(value: false)
    private let accentColorSubject = BehaviorSubject<UIColor> (value: UIColor.red) //SessionManager.current.currentProfile?.customer.accentColor ?? .primary)
    private let userNotificationPreferenceSubject = BehaviorSubject<Bool>(value: YAPUserDefaults.isNotificationOn())
    private let dismissSubject = PublishSubject<Void>()

    // MARK: - Inputs
    var viewWillAppearObserver: AnyObserver<Void> { return viewWillAppearSubject.asObserver() }
    var profilePhotoEditObserver: AnyObserver<Void> { return profilePhotoEditSubject.asObserver() }
    var openCameraTapObserver: AnyObserver<Void> { return openCameraTapSubject.asObserver() }
    var chooosePhotoTapObserver: AnyObserver<Void> { return choosePhotoTapSubject.asObserver() }
    var changedProfilePhotoObserver: AnyObserver<UIImage?> { return changedProfilePhotoSubject.asObserver() }
    var personalDetailsTapObserver: AnyObserver<UserProfileTableViewAction> { return personalDetailsTapSubject.asObserver() }
    var privacyTapObserver: AnyObserver<UserProfileTableViewAction> { return privacyTapSubject.asObserver() }
    var passcodeTapObserver: AnyObserver<UserProfileTableViewAction> { return passcodeTapSubject.asObserver() }
    var appNotificationsDidChangeObserver: AnyObserver<UserProfileTableViewAction> { return appNotificationsDidChangeSubject.asObserver() }
    var faceIDDidChangeObserver: AnyObserver<UserProfileTableViewAction> { return faceIDDidChangeSubject.asObserver() }
    var termsConditionsTapObserver: AnyObserver<UserProfileTableViewAction> { return termsConditionsTapTapSubject.asObserver() }
    var feeAndPricingPlanTapObserver: AnyObserver<UserProfileTableViewAction> { return feeAndPricingPlanTapSubject.asObserver() }
    var intagramTapObserver: AnyObserver<UserProfileTableViewAction> { return instagramTapSubject.asObserver() }
    var twitterTapObserver: AnyObserver<UserProfileTableViewAction> { return twitterTapSubject.asObserver() }
    var facebookTapObserver: AnyObserver<UserProfileTableViewAction> { return facebookTapSubject.asObserver() }
    var logoutTapObserver: AnyObserver<UserProfileTableViewAction> { return logoutTapSubject.asObserver() }
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    var logoutConfirmObserver: AnyObserver<Void>{ return logoutConfirmSubject.asObserver() }
    var removePhotoTapObserver: AnyObserver<Void>{ return removePhotoTapSubject.asObserver() }

    // MARK: - Outputs
    var logoutConfirm: Observable<Void>{ return logoutConfirmSubject.asObservable() }
    var fullName: Observable<String?> { return customer.map { $0.fullName } }
    var emiratesID: Observable<Document?> { return emiratesIDSubject.asObservable() }
    var isEmiratesIDExpired: Observable<EmiratesIDStatus> { return emiratedIdExpiredSbuject.asObservable() }
    var profilePhotoURL: Observable<URL?> { return profilePhotoURLSubject }
    var profilePhotoEditTap: Observable<Void> { return profilePhotoEditSubject.asObservable() }
    var openCameraTap: Observable<Void> { return openCameraTapSubject.asObservable() }
    var choosePhotoTap: Observable<Void> { return choosePhotoTapSubject.asObservable() }
    var changedProfilePhoto: Observable<UIImage?> { return changedProfilePhotoSubject.asObservable() }
    var userProfileItems: Observable<[SectionModel<String, UserProfileTableViewCellViewModelType>]> { return userProfileItemsSubject.asObservable() }
    var personalDetailsTap: Observable<Void> { return personalDetailsTapSubject.map { _ in () }.asObservable() }
    var changePasscodeTap: Observable<Void> { return passcodeTapSubject.map { _ in () }.asObservable() }
    var instagramTap: Observable<Void> { return instagramTapSubject.map { _ in () }.asObservable() }
    var twitterTap: Observable<Void> { return twitterTapSubject.map { _ in () }.asObservable() }
    var facebookTap: Observable<Void> { return facebookTapSubject.map { _ in () }.asObservable() }
    var logoutTap: Observable<Void> { return logoutTapSubject.map { _ in () }.asObservable() }
    var error: Observable<Error> { return errorSubject.asObservable() }
    var back: Observable<Void> { return backSubject.asObservable() }
    var result: Observable<Void> { return resultSubject.asObservable() }
    var openTermsAndConditions: Observable<Void> { termsConditionsTapTapSubject.map{ _ in } }
    var openFeeAndPricingPlan: Observable<Void> { feeAndPricingPlanTapSubject.map{ _ in } }
    var profilePhotoEditButtonImage: Observable<UIImage?>{ profilePhotoEditButtonImageSubject.asObservable() }
    var removePhotoTap: Observable<Void>{ return removePhotoTapSubject.asObserver() }
    var removeProfilePhotoFlag: Observable<Bool>{ return removeProfilePhotoFlagSubject.asObservable()}
    var accentColor: Observable<UIColor> { return accentColorSubject.map{$0}.asObservable() }
    var userNotificationPreference: Observable<Bool> { userNotificationPreferenceSubject.asObservable() }
    var dismiss: Observable<Void> { dismissSubject.asObservable() }

    var isRunning: Observable<Bool> {
        return Observable.from([
            viewWillAppearSubject.map { _ in true },
            emiratesIDSubject.map { _ in false },
            profilePhotoURLSubject.map { _ in false },
            errorSubject.map { _ in false }
        ]).merge().startWith(true)
    }

    // MARK: - Init
    init(customer: Observable<Customer>,
         biometricsManager: BiometricsManager = BiometricsManager(), credentialStore: CredentialsStoreType,
         repository: LoginRepository, notificationManager: NotificationManagerType) {

        self.customer = customer
        self.credentialStore = credentialStore
        self.biometricsManager = biometricsManager
        self.notificationManager = notificationManager
        customer.map { $0.imageURL }.bind(to: profilePhotoURLSubject).disposed(by: disposeBag)
        customer.map { $0.imageURL }.subscribe(onNext: {[weak self] in
            if $0 == nil {
                self?.profilePhotoEditButtonImageSubject.onNext(UIImage.init(named: "icon_add_profile_photo", in: .yapPakistan, compatibleWith: nil))
                self?.removeProfilePhotoFlagSubject.onNext(false)
            }else{
                self?.profilePhotoEditButtonImageSubject.onNext(UIImage.init(named: "icon_edit_profile_photo", in: .yapPakistan, compatibleWith: nil))
                self?.removeProfilePhotoFlagSubject.onNext(true)
            }
        }).disposed(by: disposeBag)

        Observable.combineLatest(customer,userNotificationPreferenceSubject).subscribe(onNext: { [unowned self] (user, _) in
            self.userProfileItemsSubject.onNext(UserProfileItemFactory.makeUserProfileItems(isEmiratesIDExpired: self.isEmiratesIDExpired.map { $0.isExpired }, signInWithFaceId: BiometricsManager().isBiometryEnabled(for: user.email), actionObservers: [self.personalDetailsTapObserver, self.privacyTapObserver, self.passcodeTapObserver, self.appNotificationsDidChangeObserver, self.faceIDDidChangeObserver, self.termsConditionsTapObserver, self.feeAndPricingPlanTapObserver, self.intagramTapObserver, self.twitterTapObserver, self.facebookTapObserver, self.logoutTapObserver]))
        }).disposed(by: disposeBag)

        self.customer.subscribe(onNext: { [unowned self] (user) in
            self.faceIDDidChangeSubject
            .map { didChange -> Bool in if case let UserProfileTableViewAction.toggleSwitch(value) = didChange { return value }; return false }
            .subscribe(onNext: { [weak self] isOn in
                self?.biometricsManager.setBiometry(isEnabled: isOn, phone: user.mobileNo)
                self?.biometricsManager.setBiometryPermission(isPrompt: true, phone: user.mobileNo)
            }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)


        emiratesIDSubject.map { EmiratesIDStatus(isExpired: $0?.isExpired) }.bind(to: emiratedIdExpiredSbuject).disposed(by: disposeBag)
        
//        fetchEmiratesID(repository: repository)
//        uploadProfilePhoto(repository: repository)
//        removeProfilePicture(repository: repository)
        logout(repository: repository)
        openInstagram()
        openTwitter()
        openFacebook()

//        Observable.merge(privacyTapSubject, appNotificationsDidChangeSubject).subscribe(onNext: { state in
//            switch state {
//            case .toggleSwitch(true):
//                NotificationManager().turnNotificationsOn()
//            case .toggleSwitch(false):
//                NotificationManager().turnNotificationsOff()
//            case .button():
//                return
//            }
//
//        }).disposed(by: disposeBag)

        NotificationCenter.default.addObserver(self, selector: #selector(checkingNotifs), name: .checkUserNotificationPreference, object: nil)

        backSubject.subscribe(onNext:{ [weak self] _ in
            guard let self = self else { return }
            self.personalDetailsTapSubject.onCompleted()
            self.emiratedIdExpiredSbuject.onCompleted()
            self.passcodeTapSubject.onCompleted()
            self.choosePhotoTapSubject.onCompleted()
            self.openCameraTapSubject.onCompleted()
            self.termsConditionsTapTapSubject.onCompleted()
            self.resultSubject.onCompleted()
            self.dismissSubject.onNext(())
            self.dismissSubject.onCompleted()

        }).disposed(by: disposeBag)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .checkUserNotificationPreference, object: nil)
    }


    @objc
    func checkingNotifs() {
        self.userNotificationPreferenceSubject.onNext(NotificationManager().isNotificationAuthorised())
    }

//    func fetchEmiratesID(repository: ProfileRepository) {
//        let request = viewWillAppearSubject.flatMap { _ in repository.fetchDocument(forType: DocumentType.emiratesId.rawValue) }.share(replay: 1, scope: .whileConnected)
//
//        request.do(onNext: { _ in YAPProgressHud.hideProgressHud() }).elements().bind(to: emiratesIDSubject).disposed(by: disposeBag)
//        request.errors().map { _ in EmiratesIDStatus(isExpired: Bool?.none) }.bind(to: emiratedIdExpiredSbuject).disposed(by: disposeBag)
//    }
//
//    func uploadProfilePhoto(repository: ProfileRepository) {
//        let imageValidation = changedProfilePhoto.unwrap().flatMap { (image: UIImage) -> Observable<Event<Data>> in
//            return Observable.create { observer in
//                let compressedImage = image.jpegData(compressionQuality: 0.5)!
//                do {
//                    try UploadingImageValiadtor(data: compressedImage).validate()
//                } catch {
//                    observer.onError(error)
//                }
//                observer.onNext(compressedImage)
//                return Disposables.create()
//            }.materialize()
//        }.share(replay: 1, scope: .whileConnected)
//
//        let request = imageValidation.elements().do(onNext: { _ in YAPProgressHud.showProgressHud() }).flatMap { repository.changeProfilePhoto($0, name: "profile-picture", fileName: "profile_photo.jpg", mimeType: "image/jpg") }.share(replay: 1, scope: .whileConnected)
//
//        request.elements().map { $0.imageUrl }.do(onNext: { _ in SessionManager.current.refreshAccount() }).bind(to: profilePhotoURLSubject).disposed(by: disposeBag)
//
//        Observable.merge(imageValidation.errors(),
//                         request.errors()).debug("Error").delaySubscription(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance).bind(to: errorSubject).disposed(by: disposeBag)
//    }
//
//    func removeProfilePicture(repository: ProfileRepository){
//
//        let result = removePhotoTapSubject
//            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
//            .flatMap {_ -> Observable<Event<String?>> in
//                return repository.removeProfilePhoto()
//        }.share()
//
//        result.elements()
//            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
//            .subscribe(onNext: {_ in
//                SessionManager.current.refreshAccount()
//            }).disposed(by: disposeBag)
//
//        result
//            .errors()
//            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
//            .bind(to: errorSubject)
//            .disposed(by: disposeBag)
//    }
//
    func openInstagram() {
        instagramTap.subscribe(onNext: { _ in
            let username =  "yap"
            let appURL = URL(string: "instagram://user?username=\(username)")!
            let application = UIApplication.shared

            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                let webURL = URL(string: "https://instagram.com/\(username)")!
                application.open(webURL)
            }
        }).disposed(by: disposeBag)
    }

    func openTwitter() {
        twitterTap.subscribe(onNext: { _ in
            let username =  "yap"
            let appURL = URL(string: "https://twitter.com/yappakistan?s=11")!
            let application = UIApplication.shared

            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                let webURL = URL(string: "https://twitter.com/YAPpakistan")!
                application.open(webURL)
            }
        }).disposed(by: disposeBag)
    }

    func openFacebook() {
        facebookTap.subscribe(onNext: { _ in
            let username =  "YAP"
            let appURL = URL(string: "https://m.facebook.com/YAPPakistan/")!
            let application = UIApplication.shared

            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                let webURL = URL(string: "https://www.facebook.com/YAPPakistan")!
                application.open(webURL)
            }
        }).disposed(by: disposeBag)
    }

    func logout(repository: LoginRepository) {
        
        
        let logoutRequest = logoutTapSubject
            .do(onNext: { [unowned self] _ in
                self.biometricsManager.deleteBiometryForUser(phone: credentialStore.getUsername() ?? "")
                YAPProgressHud.showProgressHud()
            })
            .flatMap { _ -> Observable<Event<[String: String]?>> in
                return repository.logout(deviceUUID: UIDevice.current.identifierForVendor?.uuidString ?? "")
            }
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .share()

        //logoutRequest.errors().map { $0.localizedDescription }.bind(to: errorSubject).disposed(by: disposeBag)

        logoutRequest.elements()
            .do(onNext: { [weak self] _ in
                let user = self?.credentialStore.getUsername() ?? ""
                self?.biometricsManager.deleteBiometryForUser(phone: user)
                self?.notificationManager.deleteNotificationPermission()
                self?.credentialStore.setRemembersId(false)
                self?.credentialStore.clearUsername()
                
            })
            .map { _ in () }
            .bind(to: resultSubject)
            .disposed(by: disposeBag)
        
        
        
//        let logoutRequest = logoutConfirm
//            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
//            .flatMap { _ -> Observable<Event<[String: String]?>> in
//
//                return repository.logout(deviceUUID: UIDevice.current.identifierForVendor?.uuidString ?? "")
//        }
//        .do(onNext: { _ in YAPProgressHud.hideProgressHud()})
//        .share(replay: 1, scope: .whileConnected)
//
//        logoutRequest.errors()
//            .subscribe(onNext: { [unowned self] in
//                self.errorSubject.onNext($0) })
//            .disposed(by: disposeBag)
//
//        logoutRequest.elements()
////            .do(onNext: {_ in logoutYAPUser() })
//            .map {_ in ()}
//            .subscribe(onNext: { [weak self] in
//                self?.resultSubject.onNext(()) })
//            .disposed(by: disposeBag)
    }
}

// MARK: - User Profile Items Factory
class UserProfileItemFactory {
    class func makeUserProfileItems(isEmiratesIDExpired: Observable<Bool>, signInWithFaceId: Bool, actionObservers: [AnyObserver<UserProfileTableViewAction>]) -> [SectionModel<String, UserProfileTableViewCellViewModelType>] {

        let biometricsManager = BiometricsManager()

        var cellViewModelSecuritySection = [UserProfileTableViewCellViewModelType]()

        cellViewModelSecuritySection.append(contentsOf: [UserProfileTableViewCellViewModel(UserProfileTableViewItem(icon: UIImage(named: "icon_lock_primary_dark", in: .yapPakistan, compatibleWith: nil)?.asTemplate, title:  "screen_user_profile_display_text_privacy".localized, accessory: .button( "common_button_view".localized), actionObserver: actionObservers[1])),
            UserProfileTableViewCellViewModel(UserProfileTableViewItem(icon: UIImage(named: "icon_key_primary_dark", in: .yapPakistan, compatibleWith: nil)?.asTemplate, title:  "screen_user_profile_display_text_passcode".localized, accessory: .button( "common_button_change".localized), actionObserver: actionObservers[2])),
            UserProfileTableViewCellViewModel(UserProfileTableViewItem(icon: UIImage(named: "icon_notification_primary_dark", in: .yapPakistan, compatibleWith: nil)?.asTemplate, title:  "screen_user_profile_display_text_app_notifications".localized, accessory: .toggleSwitch(NotificationManager().isNotificationAuthorised()), actionObserver: actionObservers[3])),
                                                         
            UserProfileTableViewCellViewModel(UserProfileTableViewItem(icon: UIImage(named: "icon_face_id", in: .yapPakistan, compatibleWith: nil)?.asTemplate, title:  "screen_user_profile_display_text_app_signinwithfaceID".localized, accessory: .toggleSwitch(NotificationManager().isNotificationAuthorised()), actionObserver: actionObservers[3]))
                                                         
        ])

        if biometricsManager.deviceBiometryType != .none {
            var icon: UIImage? = biometricsManager.deviceBiometryType == .faceID ? UIImage(named: "icon_faceId", in: .yapPakistan, compatibleWith: nil) : UIImage.sharedImage(named: "icon_touch_id")

            //icon = SessionManager.current.currentAccountType == .b2cAccount ? icon : icon?.asTemplate


            let biometry = biometricsManager.deviceBiometryType == .faceID ?

                UserProfileTableViewCellViewModel(UserProfileTableViewItem(icon: icon, title:  "screen_user_profile_display_text_face_id".localized, accessory: .toggleSwitch(signInWithFaceId), actionObserver: actionObservers[4])) :

                UserProfileTableViewCellViewModel(UserProfileTableViewItem(icon: icon, title:  "screen_user_profile_display_text_touch_id".localized, accessory: .toggleSwitch(signInWithFaceId), actionObserver: actionObservers[4]))

            cellViewModelSecuritySection.append(biometry)
        }

        return [
            SectionModel(model:  "screen_user_profile_display_text_profile".localized, items: [ UserProfileTableViewCellViewModel(UserProfileTableViewItem(icon: UIImage(named: "icon_profile_primary_dark", in: .yapPakistan), title:  "screen_user_profile_display_text_personal_details".localized, warning: isEmiratesIDExpired, accessory: .button( "common_button_view".localized), actionObserver: actionObservers[0]))]),

            SectionModel(model:  "screen_user_profile_display_text_security".localized, items: cellViewModelSecuritySection),
            
            SectionModel(model:  "screen_user_profile_display_text_app_advanceSetting".localized, items: [ UserProfileTableViewCellViewModel(UserProfileTableViewItem(icon: UIImage(named: "icon_numeric_format", in: .yapPakistan), title:  "screen_user_profile_display_text_app_standardNumericFormat".localized, warning: isEmiratesIDExpired, accessory: .toggleSwitch(false), actionObserver: actionObservers[0]))]),

            SectionModel(model:  "screen_user_profile_display_text_about_us".localized, items:
                            [UserProfileTableViewCellViewModel(UserProfileTableViewItem(icon: UIImage(named: "icon_file_primary_dark", in: .yapPakistan, compatibleWith: nil)?.asTemplate, title:  "screen_user_profile_display_text_terms_conditions".localized, accessory: .button( "common_button_view".localized), actionObserver: actionObservers[5])),
                             UserProfileTableViewCellViewModel(UserProfileTableViewItem(icon: UIImage(named: "icon_instagram_primary_dark", in: .yapPakistan, compatibleWith: nil)?.asTemplate, title:  "screen_user_profile_display_text_instagram".localized, accessory: .button( "screen_user_profile_button_follow_us".localized), actionObserver: actionObservers[7])),
                             UserProfileTableViewCellViewModel(UserProfileTableViewItem(icon: UIImage(named: "icon_twitter_primary_dark", in: .yapPakistan, compatibleWith: nil)?.asTemplate, title:  "screen_user_profile_display_text_twitter".localized, accessory: .button( "screen_user_profile_button_follow_us".localized), actionObserver: actionObservers[8])),
                             UserProfileTableViewCellViewModel(UserProfileTableViewItem(icon: UIImage(named: "icon_facebook_primary_dark", in: .yapPakistan, compatibleWith: nil)?.asTemplate, title:  "screen_user_profile_display_text_facebook".localized, accessory: .button( "screen_user_profile_button_facebook".localized), actionObserver: actionObservers[9])),
                             UserProfileTableViewCellViewModel(UserProfileTableViewItem(icon: UIImage(named: "icon_facebook_primary_dark", in: .yapPakistan, compatibleWith: nil)?.asTemplate, title:  "screen_user_profile_display_text_linkedin".localized, accessory: .button( "screen_user_profile_button_facebook".localized), actionObserver: actionObservers[9])),
                 UserProfileTableViewCellViewModel(UserProfileTableViewItem(icon: nil, title:  "screen_user_profile_button_logout".localized, type: UserProfileItemType.logout, accessory: nil, actionObserver: actionObservers[10]))
            ])
        ]
    }
}

// MARK: - Emirates ID Status
extension UserProfileViewModel {
    enum EmiratesIDStatus {
        case valid
        case expired
        case notSet
        case none

        var isExpired: Bool {
            switch self {
            case .valid:
                return false
            case .expired, .notSet:
                return true
            case .none:
                return false
            }
        }

        var eidViewDetail: String {
            switch self {
            case .valid:
                return  "screen_personal_details_display_text_emirates_id_details".localized
            case .notSet:
                return  "screen_personal_details_display_text_required_emirates_id_details".localized
            case .expired:
                return  "screen_personal_details_display_text_expired_emirates_id_details".localized
            default:
                return ""
            }
        }

        init(isExpired: Bool?) {
            if let isExpired = isExpired {
                self = isExpired ? .expired : .valid
            } else {
                self = .notSet
            }
        }
    }
}
