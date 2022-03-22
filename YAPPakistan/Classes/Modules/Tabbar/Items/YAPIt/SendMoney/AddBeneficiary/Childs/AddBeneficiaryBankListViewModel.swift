//
//  AddBeneficiaryBankListViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 15/03/2022.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents
import RxCocoa
import RxDataSources
import RxTheme

protocol AddBeneficiaryBankListViewModelInput {
    var doneObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
    var cellSelected: AnyObserver<BankDetail> { get }
    var otpResultObserver: AnyObserver<ResultType<Void>> { get }
    var cancelObserver: AnyObserver<Void>{ get }
    var searchObserver: AnyObserver<Void> { get }
}

protocol AddBeneficiaryBankListViewModelOutput {
    
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
    var search: Observable<[BankDetail ]?> { get }
    var bank: Observable<BankDetail> { get }
}

protocol AddBeneficiaryBankListViewModelType {
    var inputs: AddBeneficiaryBankListViewModelInput { get }
    var outputs: AddBeneficiaryBankListViewModelOutput { get }
}

class AddBeneficiaryBankListViewModel: AddBeneficiaryBankListViewModelType, AddBeneficiaryBankListViewModelInput, AddBeneficiaryBankListViewModelOutput {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: AddBeneficiaryBankListViewModelInput { return self }
    var outputs: AddBeneficiaryBankListViewModelOutput { return self }
    
    var repository : YapItRepositoryType!
    
    let beneficiaryAddedSubject = PublishSubject<SendMoneyBeneficiary?>()
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    
    let doneSubject = PublishSubject<Void>()
    let showsDoneSubject = BehaviorSubject<Bool>(value: true)
    let doneTextSubject = BehaviorSubject<String?>(value: nil)
    let doneEnabledSubject = BehaviorSubject<Bool>(value: false)
    let showActivitySubject = BehaviorSubject<Bool>(value: false)
    let endEditingSubject = BehaviorSubject<Bool>(value: false)
    let showErrorSubject = PublishSubject<String>()
    let resultSubject = PublishSubject<SendMoneyBeneficiary>()
    private let backSubject = PublishSubject<Void>()
    let cellSelectedSubject = PublishSubject<BankDetail>()
    let titleSubject = BehaviorSubject<String?>(value: "screen_add_beneficiary_display_text_title".localized)
    let otpRequiredSubject = PublishSubject<SendMoneyBeneficiary>()
    let otpResultSubject = PublishSubject<ResultType<Void>>()
    let cancelSubject = PublishSubject<Void>()
    
    private let searchSubject = PublishSubject<Void>()
    var beneficiary: SendMoneyBeneficiary!
    var viewModels: [ReusableTableViewCellViewModelType] = []
    let sendMoneyType: SendMoneyType
    
    private let bankResultsSubject = BehaviorSubject<[BankDetail]?>(value: nil)
    
    
    // MARK: - Inputs
    var searchObserver: AnyObserver<Void> { return searchSubject.asObserver() }
    var cancelObserver: AnyObserver<Void>{ return cancelSubject.asObserver() }
    var doneObserver: AnyObserver<Void> { return doneSubject.asObserver() }
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    var cellSelected: AnyObserver<BankDetail> { return cellSelectedSubject.asObserver() }
    var otpResultObserver: AnyObserver<ResultType<Void>> { otpResultSubject.asObserver() }
    
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
    var search: Observable<[BankDetail]?> { return searchSubject.withLatestFrom(bankResultsSubject) }
    var bank: Observable<BankDetail> { cellSelectedSubject.asObservable() }
    
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
        
        fetchBankList()
    }
    
    func generateCellViewModels() {
        fatalError("'generateCellViewModels()' not implementd")
    }
    
    internal func loadCells() {
        dataSourceSubject.onNext([SectionModel(model: 0, items: viewModels)])
        showActivitySubject.onNext(false)
    }
    
    func fetchRequiredData() {}
    
    private func showLoadingEffects() {
        var dummyObjects: [AddBeneficiaryCellViewModel] = []
        for _ in 1...12 {
            dummyObjects.append(AddBeneficiaryCellViewModel())
        }
        self.dataSourceSubject.onNext([SectionModel(model: 0, items: dummyObjects)])
    }
}

// MARK: Beneficiary Added

extension AddBeneficiaryBankListViewModel {
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
    
    func fetchBankList() {
        
        showLoadingEffects()
        let bankListRequest = repository.getBankDetail()
            .share()
        
        bankListRequest.errors().map { $0.localizedDescription }.subscribe(onNext: { [weak self] in
            self?.dataSourceSubject.onNext([SectionModel(model: 0, items: [])])
            self?.showErrorSubject.onNext($0)
        }).disposed(by: disposeBag)
        
        bankListRequest.elements().subscribe(onNext:{ [weak self] bankList in
            self?.bankResultsSubject.onNext(bankList)
            let cellVMs = bankList.map { bank -> AddBeneficiaryCellViewModel in
                return AddBeneficiaryCellViewModel(bank)
            }
            self?.dataSourceSubject.onNext([SectionModel(model: 0, items: cellVMs)])
        }).disposed(by: disposeBag)
    }
}
