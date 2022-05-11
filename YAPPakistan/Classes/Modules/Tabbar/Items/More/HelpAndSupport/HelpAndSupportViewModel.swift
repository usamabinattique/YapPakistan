//
//  HelpAndSupportViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 11/05/2022.
//

import Foundation
import RxSwift
import RxDataSources
import YAPComponents

protocol HelpAndSupportViewModelInput {
    var cellSelectedObserver: AnyObserver<ReusableTableViewCellViewModelType> { get }
}

protocol HelpAndSupportViewModelOutput {
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var startChat: Observable<Void> { get }
    var showError: Observable<String> { get }
    var requestFaqUrl: Observable<Void> { get }
    var faqsUrl: Observable<String?> { get }
}

protocol HelpAndSupportViewModelType {
    var inputs: HelpAndSupportViewModelInput { get }
    var outputs: HelpAndSupportViewModelOutput { get }
}

class HelpAndSupportViewModel: HelpAndSupportViewModelType, HelpAndSupportViewModelInput, HelpAndSupportViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: HelpAndSupportViewModelInput { return self }
    var outputs: HelpAndSupportViewModelOutput { return self }
    //let repository = YAPMoreRepository()
    
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let cellSelectedSubject = PublishSubject<ReusableTableViewCellViewModelType>()
    private let startChatSubject = PublishSubject<Void>()
    private let showErrorSubject = PublishSubject<String>()
    private let faqsUrlSubject = PublishSubject<String?>()
    private let faqRequestSubject = PublishSubject<Void>()
    
    // MARK: - Inputs
    var cellSelectedObserver: AnyObserver<ReusableTableViewCellViewModelType> { return cellSelectedSubject.asObserver() }
    
    // MARK: - Outputs
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    var startChat: Observable<Void> { return startChatSubject.asObservable() }
    var showError: Observable<String> { return showErrorSubject.asObservable() }
    var faqsUrl: Observable<String?> { return faqsUrlSubject.asObservable() }
    var requestFaqUrl: Observable<Void> { return faqRequestSubject.asObservable() }
    
    // MARK: - Init
    init() {
        //let callUsViewModel = HSCallUsTableViewCellViewModel()
        let cellViewModels: [ReusableTableViewCellViewModelType] = [HelpAndSupportTableViewCellViewModel(.faq), HelpAndSupportTableViewCellViewModel(.call)]

        dataSourceSubject.onNext([SectionModel(model: 0, items: cellViewModels)])

//        let action = Observable.merge(cellSelectedSubject.filter { $0 is HelpAndSupportTableViewCellViewModelType }.map { ($0 as! HelpAndSupportTableViewCellViewModel).action }, cellSelectedSubject.filter { $0 is HSCallUsTableViewCellViewModelType }.map { ($0 as! HSCallUsTableViewCellViewModel).action }).unwrap().share()
//
//        action.filter { $0 == .chat }
//            .do(onNext:{ _ in AppAnalytics.shared.logEvent(MoreEvent.livechat()) })
//            .subscribe(onNext: { _ in
//            ChatManager.shared.openChat()
//            /*YAPToast.show("commn_display_text_comming_soon".localized)*/ }).disposed(by: disposeBag)
//
//        action.filter { $0 == .whatsapp }.subscribe(onNext: { [unowned self] _ in self.openWhatsapp() }).disposed(by: disposeBag)
//
//        action.filter { $0 == .faq }
//            .do(onNext:{ _ in AppAnalytics.shared.logEvent(MoreEvent.faqs()) })
//            .map { _ in }.bind(to: faqRequestSubject).disposed(by: disposeBag)
//
//        YAPProgressHud.showProgressHud()
        
//        let helplineNumberRequest = repository.getHelpLineNumber().share().do(onNext: { _ in YAPProgressHud.hideProgressHud() })
//
//        helplineNumberRequest.elements().bind(to: callUsViewModel.inputs.phoneNumberObserver).disposed(by: disposeBag)
//
//        action.filter { $0 == .call }
//            .do(onNext:{ _ in AppAnalytics.shared.logEvent(MoreEvent.call()) })
//            .withLatestFrom(helplineNumberRequest.elements().unwrap().map { $0.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "")}).subscribe(onNext: {
//            guard let number = URL(string: "tel://" + $0 ) else { return }
//            UIApplication.shared.open(number)
//        }).disposed(by: disposeBag)
//
//        helplineNumberRequest.errors().map { $0.localizedDescription }.bind(to: showErrorSubject).disposed(by: disposeBag)
        
//        helplineNumberRequest.errors().map { _ -> [ReusableTableViewCellViewModelType] in
//            cellViewModels.removeLast()
//            return cellViewModels }
//            .map { [SectionModel(model: 0, items: $0)] }
//            .bind(to: dataSourceSubject)
//            .disposed(by: disposeBag)
        
        //getFaqsUrl()
    }
}

private extension HelpAndSupportViewModel {
    func openWhatsapp() {
        let phoneNumber = "971600551214"
        
        let appURL = URL(string: "whatsapp://send?phone=\(phoneNumber)")!
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
            guard let whatsappUrl = URL(string: "https://web.whatsapp.com/") else {
                showErrorSubject.onNext("screen_help_and_support_display_text_whatsapp_not_installed".localized)
                return }
            UIApplication.shared.open(whatsappUrl, options: [:], completionHandler: nil)
        }
    }
}

extension HelpAndSupportViewModel {
    fileprivate func getFaqsUrl() {
        
//        let request =  faqRequestSubject.do(onNext: { _ in YAPProgressHud.showProgressHud() })
//
//        let result = request.flatMap {[unowned self] _ -> Observable<Event<String?>> in
//            return self.repository.getFAQ()
//        }.do(onNext: { _ in YAPProgressHud.hideProgressHud() }).share()
//
//        result
//            .elements()
//            //.map{_ in "https://www.yap.com/support" } //after discussion with android removing hard code value
//            .bind(to: faqsUrlSubject)
//            .disposed(by: disposeBag)
//
//        result
//            .errors()
//            .map { $0.localizedDescription }
//            .bind(to: showErrorSubject)
//            .disposed(by: disposeBag)
    }
}

enum HelpAndSupportActionType {
    case faq
    case chat
    case whatsapp
    case call
}

extension HelpAndSupportActionType {
    var title: String {
        switch self {
        case .faq:
            return "FAQs"
        case .chat:
            return "Live chat"
        case .call:
            return "Call us"
        case .whatsapp:
            return "Live Agent chat via WhatsApp"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .faq:
            return UIImage.init(named: "icon_support", in: .yapPakistan, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate).withAlignmentRectInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        case .chat:
            return UIImage.init(named: "icon_chat", in: .yapPakistan, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        case .call:
            return UIImage.init(named: "icon_phone", in: .yapPakistan, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate).withAlignmentRectInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        case .whatsapp:
            return UIImage.init(named: "icon_whats_app", in: .yapPakistan, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        }
    }
}
