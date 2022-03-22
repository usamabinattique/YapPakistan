//
//  AddSendMoneyBeneficiaryViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 14/03/2022.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents
import RxCocoa
import RxDataSources
import RxTheme

protocol AddSendMoneyBeneficiaryViewModelInput {
    var doneObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
    var cellSelected: AnyObserver<ReusableTableViewCellViewModelType> { get }
    var otpResultObserver: AnyObserver<ResultType<Void>> { get }
    var cancelObserver: AnyObserver<Void>{ get }
    var progressObserver: AnyObserver<AddBeneficiaryStage> { get }
    var bankDetailErrorObserver: AnyObserver<String?>{ get }
    var showBeneficiaryAddedObserver: AnyObserver<Void> { get }
}

protocol AddSendMoneyBeneficiaryViewModelOutput {
    
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    
    var showsDone: Observable<Bool> { get }
    var doneText: Observable<String?> { get }
    var doneEnabled: Observable<Bool> { get }
    var back: Observable<Void> { get }
    var showActivity: Observable<Bool> { get }
    var endEditing: Observable<Bool> { get }
    var showError: Observable<String> { get }
    var result: Observable<SendMoneyBeneficiary> { get }
    var beneficairyAdded: Observable<SendMoneyBeneficiary?> { get }
    var title: Observable<String?> { get }
    var otpRequired: Observable<SendMoneyBeneficiary> { get }
    var cancel: Observable<Void>{ get }
    var progress: Observable<AddBeneficiaryStage> { get }
    var bankDetailError: Observable<String?>{ get }
}

protocol AddSendMoneyBeneficiaryViewModelType {
    var inputs: AddSendMoneyBeneficiaryViewModelInput { get }
    var outputs: AddSendMoneyBeneficiaryViewModelOutput { get }
}

class AddSendMoneyBeneficiaryViewModel: AddSendMoneyBeneficiaryViewModelType, AddSendMoneyBeneficiaryViewModelInput, AddSendMoneyBeneficiaryViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: AddSendMoneyBeneficiaryViewModelInput { return self }
    var outputs: AddSendMoneyBeneficiaryViewModelOutput { return self }
    
    var repository : YapItRepositoryType!
    
    let beneficiaryAddedSubject = PublishSubject<SendMoneyBeneficiary?>()
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let bankDetailErrorSubject = PublishSubject<String?>()
    
    let doneSubject = PublishSubject<Void>()
    let showsDoneSubject = BehaviorSubject<Bool>(value: true)
    let doneTextSubject = BehaviorSubject<String?>(value: nil)
    let doneEnabledSubject = BehaviorSubject<Bool>(value: false)
    let showActivitySubject = BehaviorSubject<Bool>(value: false)
    let endEditingSubject = BehaviorSubject<Bool>(value: false)
    let showErrorSubject = PublishSubject<String>()
    let resultSubject = PublishSubject<SendMoneyBeneficiary>()
    private let backSubject = PublishSubject<Void>()
    let cellSelectedSubject = PublishSubject<ReusableTableViewCellViewModelType>()
    let titleSubject = BehaviorSubject<String?>(value: "screen_add_beneficiary_display_text_title".localized)
    let otpRequiredSubject = PublishSubject<SendMoneyBeneficiary>()
    let otpResultSubject = PublishSubject<ResultType<Void>>()
    let cancelSubject = PublishSubject<Void>()
    private let progressSubject = ReplaySubject<AddBeneficiaryStage>.create(bufferSize: 1)
    private let  showBeneficiaryAddedSubject = PublishSubject<Void>()
    
    var beneficiary: SendMoneyBeneficiary!
    var viewModels: [ReusableTableViewCellViewModelType] = []
    let sendMoneyType: SendMoneyType
    
    // MARK: - Inputs
    var cancelObserver: AnyObserver<Void>{ return cancelSubject.asObserver() }
    var doneObserver: AnyObserver<Void> { return doneSubject.asObserver() }
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    var cellSelected: AnyObserver<ReusableTableViewCellViewModelType> { return cellSelectedSubject.asObserver() }
    var otpResultObserver: AnyObserver<ResultType<Void>> { otpResultSubject.asObserver() }
    var progressObserver: AnyObserver<AddBeneficiaryStage> { return progressSubject.asObserver() }
    var bankDetailErrorObserver:  AnyObserver<String?>  { bankDetailErrorSubject.asObserver() }
    
    // MARK: - Outputs
    var cancel: Observable<Void>{ return cancelSubject.asObservable() }
    var showsDone: Observable<Bool> { return showsDoneSubject.asObservable() }
    var doneText: Observable<String?> { return doneTextSubject.asObservable() }
    var doneEnabled: Observable<Bool> { return doneEnabledSubject.asObservable() }
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return dataSourceSubject.asObservable() }
    var back: Observable<Void> { return backSubject.asObservable() }
    var showActivity: Observable<Bool> { return showActivitySubject.asObservable() }
    var endEditing: Observable<Bool> { return endEditingSubject.asObservable() }
    var showError: Observable<String> { return showErrorSubject.asObservable() }
    var result: Observable<SendMoneyBeneficiary> { return resultSubject.asObservable() }
    var beneficairyAdded: Observable<SendMoneyBeneficiary?> { return beneficiaryAddedSubject.asObservable() }
    var title: Observable<String?> { return titleSubject.asObservable() }
    var otpRequired: Observable<SendMoneyBeneficiary> { otpRequiredSubject.asObservable() }
    var progress: Observable<AddBeneficiaryStage> { return progressSubject.asObservable() }
    var bankDetailError: Observable<String?>  { bankDetailErrorSubject.asObservable() }
    var showBeneficiaryAddedObserver: AnyObserver<Void> { showBeneficiaryAddedSubject.asObserver() }
    
    private var searchableActionSheet: SearchableActionSheet?
    private var themeService: ThemeService<AppTheme>
    
    // MARK: - Init
    init(beneficiary: SendMoneyBeneficiary,
         repository: YapItRepositoryType,
         sendMoneyType: SendMoneyType, themeService: ThemeService<AppTheme>) {
        
        self.sendMoneyType = sendMoneyType
        self.repository = repository
        self.beneficiary = beneficiary
        self.themeService = themeService
        
        loadCells()
        fetchRequiredData()
        
        showBeneficiaryAddedSubject.subscribe(onNext: { [weak self] _ in
            self?.showBeneficiaryAddedAlert()
        }).disposed(by: disposeBag)

    }
    
    func generateCellViewModels() {
        fatalError("'generateCellViewModels()' not implementd")
    }
    
    internal func loadCells() {
        dataSourceSubject.onNext([SectionModel(model: 0, items: viewModels)])
        showActivitySubject.onNext(false)
    }
    
    func fetchRequiredData() {}
}

// MARK: Beneficiary Added

extension AddSendMoneyBeneficiaryViewModel {
    func showBeneficiaryAddedAlert() {
        let title = "screen_add_beneficiary_detail_display_text_alert_title".localized
        let details = "screen_add_beneficiary_detail_display_button_block_alert_description".localized
        let text = title + "\n\n\n" + details + "\n"
        
        let attributted = NSMutableAttributedString(string: text)
        
        attributted.addAttributes([.foregroundColor: UIColor(themeService.attrs.primaryDark), .font: UIFont.title3], range: NSRange(location: 0, length: title.count))
        attributted.addAttributes([.foregroundColor: UIColor(themeService.attrs.greyDark), .font: UIFont.small], range: NSRange(location: text.count - details.count - 1, length: details.count))
        
        let alert = YAPAlertView(theme: themeService, icon: UIImage.init(named: "icon_check_fill_purple", in: .yapPakistan), text: attributted, primaryButtonTitle: "screen_add_beneficiary_detail_display_button_block_alert_yes".localized, cancelButtonTitle: "screen_add_beneficiary_detail_display_button_block_alert_no".localized)
        
        alert.show()
        
        let para = NSMutableParagraphStyle()
        para.alignment = .center
        attributted.addAttributes([.paragraphStyle: para], range: NSRange(location: 0, length: text.count))
        
        Observable.merge(alert.rx.primaryTap.map { [unowned self]  in self.beneficiary }, alert.rx.cancelTap.map({ ele -> SendMoneyBeneficiary? in
            return nil
        })).bind(to: beneficiaryAddedSubject).disposed(by: disposeBag)
    }
    
    
   
}
