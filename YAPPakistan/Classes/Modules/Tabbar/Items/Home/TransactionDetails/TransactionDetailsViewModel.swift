//
//  TransactionDetailsViewModel.swift
//  YAPPakistan
//
//  Created by Umair  on 23/05/2022.
//

import Foundation
import YAPComponents
import YAPCore
import RxSwift
import RxCocoa
import RxDataSources
import RxTheme
/*
protocol TransactionDetailsViewModelInput {
    var fetchDataObserver: AnyObserver<Void> { get }
    var closeObserver: AnyObserver<Void> { get }
}

protocol TransactionDetailsViewModelOutput {
    var error: Observable<String> { get }
    var reload: Observable<Void> { get }
    var close: Observable<Void> { get }
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
}

protocol TransactionDetailsViewModelType {
    var inputs: TransactionDetailsViewModelInput { get }
    var outputs: TransactionDetailsViewModelOutput { get }
}

class TransactionDetailsViewModel: TransactionDetailsViewModelType, TransactionDetailsViewModelInput, TransactionDetailsViewModelOutput {
    
    //MARK: Subjects
    private var fetchDataSubject = PublishSubject<Void>()
    private let errorSubject = PublishSubject<String>()
    private let reloadSubject = PublishSubject<Void>()
    private let closeSubject = PublishSubject<Void>()
    
    var inputs: TransactionDetailsViewModelInput { self }
    var outputs: TransactionDetailsViewModelOutput { self }
    
    //MARK: Inputs
    var fetchDataObserver: AnyObserver<Void> { fetchDataSubject.asObserver() }
    var closeObserver: AnyObserver<Void> { closeSubject.asObserver() }
    
    //MARK: Outputs
    var error: Observable<String> { errorSubject.asObservable() }
    var reload: Observable<Void> { reloadSubject }
    var close: Observable<Void> { closeSubject.asObservable() }
    
    //MARK: Properties
    private let disposeBag = DisposeBag()
    var viewModels: [ReusableTableViewCellViewModelType] = []
    
    
    init(repository: TransactionsRepositoryType) {
        
        let limitsRequest = fetchDataSubject
            .do(onNext: { YAPProgressHud.showProgressHud() })
            .flatMap { _ -> Observable<Event<[AccountLimits]?>> in
                return repository.getAccountLimits()
            }
            .share()
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
                
        limitsRequest.errors().subscribe(onNext:{ error in
            
        })
        .disposed(by: disposeBag)
                
        limitsRequest.elements()
            .subscribe(onNext:{ [weak self] limits in
                guard let limits = limits else { return }
                for model in limits {
                    print(model)
                    let cellVM = AccountLimitCellViewModel(model)
                    self?.viewModels.append(cellVM)
                }
                self?.reloadSubject.onNext(())
            })
            .disposed(by: disposeBag)
                
    }
}

extension TransactionDetailsViewModel {
    
    public func cellViewModel(for indexPath: IndexPath) -> ReusableTableViewCellViewModelType {
        let viewModel = self.viewModels[indexPath.row]
        return viewModel
    }
    
    public var numberOfRows: Int {
        return self.viewModels.count
    }
} */

protocol TransactionDetailsViewModelInputs {
    var backObserver: AnyObserver<Void> { get }
    var addNoteActionObserver: AnyObserver<Void> { get }
    var addReceiptViaCameraObserver: AnyObserver<Void> { get }
    var updateTransactionNoteObserver: AnyObserver<String?> { get }
    var photoTapObserver: AnyObserver<Void>{ get }
    var receiptPhotoObserver: AnyObserver<UIImage?>{ get }
    var fetchReceiptsFromServerObserver: AnyObserver<Void>{ get }
    var addAnotherReceiptsOptionObserver: AnyObserver<Void>{ get }
    var changeCategoryObserver: AnyObserver<TapixTransactionCategory?> { get }
    var categoryChangedObserver: AnyObserver<TapixTransactionCategory> { get }
    var improveCategoryAttributeObserver: AnyObserver<Void> { get }
    var transactionTotalPurchaseObserver: AnyObserver<Void> { get }
}

protocol TransactionDetailsViewModelOutputs {
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var back: Observable<Void> { get }
    var titleHeading: Observable<String?> { get }
    var addNoteAction: Observable<Void> { get }
    var loading: Observable<Bool> { get }
    var error: Observable<String> { get }
    var success: Observable<Void> { get }
    var updateTransactionNote: Observable<String?> { get }
    var addNote: Observable<CDTransaction?> { get }
    var addReceipt: Observable<Void> { get }
    var receiptsSelected: Observable<IndexPath> { get }
    var photoTap: Observable<Void>{ get }
    var receiptPhoto: Observable<UIImage?>{ get }
    var addReceiptSuccessAlert: Observable<Void>{ get }
    var fetchReceiptsFromServer: Observable<Void>{ get }
    var receipts: Observable<[String]?>{ get }
    var reloadTableView: Observable<Void>{ get }
    var addReceiptViaCamera: Observable<Void>{ get }
    var addAnotherReceiptsOption: Observable<Void>{ get }
    var totalPurchase: Observable<TotalPurchase?>{ get }
    var changeCategory: Observable<TapixTransactionCategory?> { get }
    var improveCategoryAttribute: Observable<Void> { get }
    var transactionTotalPurchases: Observable<Void> { get }
    var totalTransactions: Observable<TotalTransactionModel?> {get}
    var totalSpentAmount: Observable<Double?> {get}
    var transactionCategoryChanged: Observable<TapixTransactionCategory> {get}
    var transactionUserUrl: Observable<(ImageWithURL, UIImageView.ContentMode)>{ get }
    var transactionUserBackgroundImage: Observable<(ImageWithURL, UIImageView.ContentMode)>{ get }
}

protocol TransactionDetailsViewModelType {
    var inputs: TransactionDetailsViewModelInputs { get }
    var outputs: TransactionDetailsViewModelOutputs { get }
}

class TransactionDetailsViewModel: TransactionDetailsViewModelType, TransactionDetailsViewModelInputs, TransactionDetailsViewModelOutputs {
    
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let repository: TransactionsRepositoryType
    private var globalNote: String?
    private var transaction: TransactionResponse //CDTransaction
    private var receiptsArray : [String]? = nil
    private var transactionTotalPurchase : TotalPurchase? = nil
    
    var inputs: TransactionDetailsViewModelInputs {  self}
    var outputs: TransactionDetailsViewModelOutputs {  self }
    
    private let loadingSubject = PublishSubject<Bool>()
    private let errorSubject = PublishSubject<String>()
    private let backSubject = PublishSubject<Void>()
    private let titleSubject = BehaviorSubject<String?>(value: nil)
    private let addNoteActionSubject = PublishSubject<Void>()
    private let successSubject = PublishSubject<Void>()
    private let updateTransactionNoteSubject = PublishSubject<String?>()
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let addNoteSubject = BehaviorSubject<CDTransaction?>(value: nil)
    private let receiptsSelectedSubject = PublishSubject<IndexPath>()
    private let addReceiptSubject = PublishSubject<Void>()
    private let photoTapSubject = PublishSubject<Void>()
    private let receiptPhotoSubject = BehaviorSubject<UIImage?>(value: nil)
    private let addReceiptSuccessAlertSubject = PublishSubject<Void>()
    private let fetchReceiptsFromServerSubject = PublishSubject<Void>()
    private let receiptsSubject = BehaviorSubject<[String]?>(value: nil)
    private let reloadTableViewSubject = PublishSubject<Void>()
    private let addReceiptViaCameraSubject = PublishSubject<Void>()
    private let addAnotherReceiptsOptionSubject = PublishSubject<Void>()
    private let totalPurchaseSubject = BehaviorSubject<TotalPurchase?>(value: nil)
    private let changeCategorySubject = PublishSubject<TapixTransactionCategory?>()
    private let categoryChangedSubject = PublishSubject<TapixTransactionCategory>()
    private let improveCategoryAttributeSubject = PublishSubject<Void>()
    private let transactionTotalPurchaseSubject = PublishSubject<Void>()
    private let totalTransactionsSubject = PublishSubject<TotalTransactionModel?>()
    private let totalSpentAmountSubject = BehaviorSubject<Double?>(value: nil)
    private let transactionUserUrlSubject = ReplaySubject<(ImageWithURL, UIImageView.ContentMode)>.create(bufferSize: 1)
    private let transactionUserBackgroundImageSubject = ReplaySubject<(ImageWithURL, UIImageView.ContentMode)>.create(bufferSize: 1)
    
    // MARK: - Inputs
    var backObserver: AnyObserver<Void> { return backSubject.asObserver()}
    var addNoteActionObserver: AnyObserver<Void> { return addNoteActionSubject.asObserver() }
    var updateTransactionNoteObserver: AnyObserver<String?> { return updateTransactionNoteSubject.asObserver() }
    var addReceiptViaCameraObserver: AnyObserver<Void> { return addReceiptViaCameraSubject.asObserver() }
    var photoTapObserver: AnyObserver<Void>{ return photoTapSubject.asObserver() }
    var receiptPhotoObserver: AnyObserver<UIImage?>{ return receiptPhotoSubject.asObserver() }
    var fetchReceiptsFromServerObserver: AnyObserver<Void>{ return fetchReceiptsFromServerSubject.asObserver() }
    var addAnotherReceiptsOptionObserver: AnyObserver<Void>{ return addAnotherReceiptsOptionSubject.asObserver() }
    var changeCategoryObserver: AnyObserver<TapixTransactionCategory?> { changeCategorySubject.asObserver() }
    var categoryChangedObserver: AnyObserver<TapixTransactionCategory> { categoryChangedSubject.asObserver() }
    var improveCategoryAttributeObserver: AnyObserver<Void> { improveCategoryAttributeSubject.asObserver() }
    var transactionTotalPurchaseObserver: AnyObserver<Void> {
        transactionTotalPurchaseSubject.asObserver() }
    var totalTransactions: Observable<TotalTransactionModel?> {
        totalTransactionsSubject }
    
    // MARK: - Outputs
    var error: Observable<String> { return errorSubject.asObservable() }
    var loading: Observable<Bool> { return loadingSubject.asObservable() }
    var titleHeading: Observable<String?> { return titleSubject.asObservable() }
    var back: Observable<Void> { return backSubject.asObservable()}
    var addNoteAction: Observable<Void> { return addNoteActionSubject.asObservable() }
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { return dataSourceSubject.asObservable()}
    var success: Observable<Void> { return successSubject.asObservable() }
    var updateTransactionNote: Observable<String?> { return updateTransactionNoteSubject.asObservable() }
    var addNote: Observable<CDTransaction?> { return addNoteSubject.asObservable() }
    var addReceipt: Observable<Void> { return addReceiptSubject.asObservable() }
    var receiptsSelected: Observable<IndexPath> { return receiptsSelectedSubject.asObservable() }
    var photoTap: Observable<Void>{ return photoTapSubject.asObservable() }
    var receiptPhoto: Observable<UIImage?>{ return receiptPhotoSubject.asObservable() }
    var addReceiptSuccessAlert: Observable<Void>{ return addReceiptSuccessAlertSubject.asObservable() }
    var fetchReceiptsFromServer: Observable<Void>{ return fetchReceiptsFromServerSubject.asObservable() }
    var receipts: Observable<[String]?>{ return receiptsSubject.asObservable() }
    var reloadTableView: Observable<Void>{ return reloadTableViewSubject.asObservable() }
    var addReceiptViaCamera: Observable<Void>{ return addReceiptViaCameraSubject.asObservable() }
    var addAnotherReceiptsOption: Observable<Void>{ return addAnotherReceiptsOptionSubject.asObservable() }
    var totalPurchase: Observable<TotalPurchase?>{ return totalPurchaseSubject.asObservable() }
    var changeCategory: Observable<TapixTransactionCategory?> { changeCategorySubject.filter { _ in self.transaction.tapixCategory != nil && self.transaction.tapixCategory?.name.lowercased() != "general" }.map { _ in TapixTransactionCategory(name: self.transaction.tapixCategory?.name ?? "", iconUrl: self.transaction.tapixCategory?.iconUrl) } }
    var improveCategoryAttribute: Observable<Void> { improveCategoryAttributeSubject }
    var transactionTotalPurchases: Observable<Void> { transactionTotalPurchaseSubject }
    var totalSpentAmount: Observable<Double?> { totalSpentAmountSubject }
    var transactionCategoryChanged: Observable<TapixTransactionCategory> { categoryChangedSubject }
    var transactionUserUrl: Observable<(ImageWithURL, UIImageView.ContentMode)>{ transactionUserUrlSubject.asObservable() }
    var transactionUserBackgroundImage: Observable<(ImageWithURL, UIImageView.ContentMode)>{ transactionUserBackgroundImageSubject.asObservable() }
    
    private var themeService: ThemeService<AppTheme>
    
    init(repository: TransactionsRepositoryType, transaction: TransactionResponse, themeService: ThemeService<AppTheme>) {
        self.themeService = themeService
        self.repository = repository
        self.transaction = transaction
        bindCategoryUpdate()
        self.globalNote = self.transaction.type == .credit ? self.transaction.receiverTransactionNote ?? nil : nil != nil ? self.transaction.receiverTransactionNote ?? nil : self.transaction.transactionNote ?? nil
        generateTransactionCellViewModels()
//        addNoteAction.map { return self.transaction }.bind(to: addNoteSubject).disposed(by: disposeBag)
//        updateNotes(cdTransaction: cdTransaction)
        
//        uploadReceiptPhoto(repository: self.repository, transactionId: self.transaction.transactionId )
        
//        if self.transaction.productCode.isForReceipt && self.transaction.category == "TRANSACTION" {
//            fetchAllReceipts(repository: self.repository, transactionId: self.transaction.transactionId)
//        }
        
//        if let transactionUserUrlPath = transaction.transactionUserUrl {
//            transactionUserUrlSubject.onNext((transactionUserUrlPath, transaction.transactionUserName?.thumbnail))
//        } else {
//            transactionUserBackgroundImageSubject.onNext((nil, transactionBackgroundImage))
//        }
        
        
        
        let merchantNameImage = transaction.merchantName?.initialsImage(color: UIColor.colorFor(listItemIndex: 5))
        if transaction.productCode == .posPurchase || transaction.productCode == .eCom /*|| transaction.productCode == .billPayments*/ {
            transactionUserUrlSubject.onNext(((transaction.merchantLogoUrl, merchantNameImage), transaction.icon.contentMode))
            let bgImage = transactionBackgroundImage != nil ? transactionBackgroundImage : "".initialsImage(color: UIColor.colorFor(listItemIndex: 5))
            transactionUserBackgroundImageSubject.onNext(((transaction.merchantLogoUrl, bgImage  ), transaction.icon.contentMode))
        } else {
            transactionUserUrlSubject.onNext(((transaction.icon.imageUrl, transaction.icon.image), transaction.icon.contentMode))
            let bgImage = transactionBackgroundImage != nil ? transactionBackgroundImage : transaction.icon.emptyThumbnail
            transactionUserBackgroundImageSubject.onNext(((transaction.icon.imageUrl,bgImage ), transaction.icon.contentMode))
        }
        
        
        
        receipts.unwrap().subscribe(onNext: {[weak self] receipts in
            self?.receiptsArray = receipts
            self?.generateTransactionCellViewModels()
        }).disposed(by: disposeBag)
        
        fetchReceiptsFromServerSubject.onNext(())
        
        totalPurchase.unwrap().subscribe(onNext:{[weak self] in
            self?.transactionTotalPurchase = $0
            self?.totalSpentAmountSubject.onNext($0.totalSpendAmount)
            self?.generateTransactionCellViewModels()
        }).disposed(by: disposeBag)
        
        transactionTotalPurchaseSubject.subscribe(onNext: { [unowned self]
            _ in
            
            let title = transaction.merchantName ?? "Unknown"
            guard let txnCount = self.transactionTotalPurchase?.txnCount else {return}
            let transactionDetail = TotalTransactionModel(transactionCount: txnCount , vendorName: title, iconUrl: "logo_starBucks", transaction: self.transaction)
            self.totalTransactionsSubject.onNext(transactionDetail)
        }).disposed(by: disposeBag)
        fetchTotalPurchaseDate(repository: repository, transactionId: transaction.transactionId, transaction: transaction)
    }
    
   /* fileprivate func updateNotes(cdTransaction: TransactionResponse) {
        updateTransactionNote
            .do(onNext: {
                if self.transaction.type == .debit {
                    cdTransaction.transactionNote =  $0
                    cdTransaction.transactionNoteDate = Date()
                }else{
                    cdTransaction.receiverTransactionNote =  $0
                    cdTransaction.receiverTransactionNoteDate = Date()
                }
                try? cdTransaction.managedObjectContext?.save()
            })
            .subscribe(onNext: { [weak self] in
                self?.globalNote = $0
                self?.generateTransactionCellViewModels()
            })
            .disposed(by: disposeBag)
    } */
}

private extension TransactionDetailsViewModel {
    
    func bindCategoryUpdate() {
        categoryChangedSubject.subscribe(onNext: { [weak self] category in
            self?.transaction.tapixCategory?.name = category.name
            self?.transaction.tapixCategory?.iconUrl = category.iconUrl
            self?.generateTransactionCellViewModels()
        }).disposed(by: disposeBag)
    }
    
    func generateTransactionCellViewModels() {
        var cellViewModels = [ReusableTableViewCellViewModelType]()
        
        let transactionNoteDate = transaction.transactionNoteDate != nil ? transaction.transactionNoteDate!.transactonNoteUserReadableDateString : transaction.receiverTransactionNoteDate != nil ? transaction.receiverTransactionNoteDate!.transactonNoteUserReadableDateString : ""
        
        if let catImage = transactionBackgroundImage {
          /*  cellViewModels.append(TransactionDetailsMapCellViewModel(catImage: catImage, showLocation: self.showLocation, cdTransaction: transaction)) */
        }
        
        cellViewModels.append(TDTransactionDetailTableViewCellViewModel(transaction: self.transaction, themeService: themeService))
        
        if transaction.productCode.shouldDisplayCategory {
            cellViewModels.append(TransactionDetailCategoryCellViewModel(transaction: transaction, themeService: themeService))
        }
        
        cellViewModels.append(TDTransactionOptionsTableViewModel(actionTitle: (self.globalNote?.isEmpty ?? true) ? TransactionDetailsLocalizations.addNote.localized : TransactionDetailsLocalizations.editNote.localized + transactionNoteDate, actionDescription: (self.globalNote?.isEmpty ?? true) ? TransactionDetailsLocalizations.noteDescription.localized : self.globalNote ?? "", actionLogo: UIImage.init(named: "icon_edit_primary_dark", in: .yapPakistan)!))
        
        if /*self.transaction.productCode.isForReceipt && */ self.transaction.category == "TRANSACTION" {
            let receiptVm = TDReceiptsTableViewCellViewModel(receipts: receiptsArray ?? nil)
            cellViewModels.append(receiptVm)
            
            receiptVm
                .outputs
                .itemSelected
                .unwrap()
                .bind(to: receiptsSelectedSubject).disposed(by: disposeBag)
        }
        
        makeTotalPurchaseCellViewModels(self.transactionTotalPurchase, cellViewModels: &cellViewModels)
        
        cellViewModels.append(TransactionDetailsAmountInfoCellViewModel(transaction: transaction, isHidePaymentDetails: validateTotalPurchaseCriteria))
        
        if transaction.productCode.shouldDisplayImproveAttributes {
//            cellViewModels.append(TransactionDetailImproveAttributesCellViewModel())
        }
        self.titleSubject.onNext(self.transaction.date.transactionDetailsReadableDate)
        self.dataSourceSubject.onNext([SectionModel(model: 1, items: cellViewModels)])
        
    }
    
    func makeTotalPurchaseCellViewModels(_ totalPurchase: TotalPurchase?, cellViewModels: inout [ReusableTableViewCellViewModelType]) {
        
        guard let totalPurchaseData = totalPurchase else { return }
        
        cellViewModels
            .append(TDTransactionTotalPurchaseTableViewModel(
                        totalPurchaseCount: totalPurchaseData.txnCount,
                        avgAmount: totalPurchaseData.avgSpendAmount,
                        totalAmount: totalPurchaseData.totalSpendAmount )
            )
    }
}
// MARK: - Multipart requests
private extension TransactionDetailsViewModel {
    
    func fetchTotalPurchaseDate(repository: TransactionsRepositoryType, transactionId: String?, transaction: TransactionResponse) {
        
        let request = Observable.of(self.validateTotalPurchaseCriteria)
            .filter{ $0 }
            .map{_ in }
            .flatMap {[weak self] in
//                repository.fetchTotalPurchaseData(transactionType: self?.processTransactionType.rawValue ?? "", beneficiaryId: self?.beneficiaryIdInCaseOfSendMoney, receiverCustomerId: self?.receiverCustomerIdInCaseOfY2Y, productCode: transaction.transactionProductCode.rawValue ?? "", merchantName: self?.merchantNameInCaseOfPOSEcom, senderCustomerId: self?.senderCustomerIdInCaseOfY2Y)
                
                repository.fetchTotalPurchasesCount(txnType: self?.processTransactionType.rawValue ?? "", productCode: transaction.productCode.rawValue, receiverCustomerId: self?.receiverCustomerIdInCaseOfY2Y, senderCustomerId: self?.senderCustomerIdInCaseOfY2Y, beneficiaryId: self?.beneficiaryIdInCaseOfSendMoney, merchantName: self?.merchantNameInCaseOfPOSEcom)
                
            }
            .share(replay: 1, scope: .whileConnected)
        
        request
            .elements()
            .bind(to: totalPurchaseSubject)
            .disposed(by: disposeBag)
        
        request
            .errors()
            .map { $0.localizedDescription }
            .bind(to: errorSubject).disposed(by: disposeBag)
    }
    
/*    func uploadReceiptPhoto(repository: TransactionsRepository, transactionId: String?) {
        
        let imageValidation = receiptPhoto
            .unwrap()
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .delay(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .flatMap { (image: UIImage) -> Observable<Event<Data>> in
                return Observable.create { observer in
                    let compressedImage = image.jpegData(compressionQuality: 0.5)!
                    do {
                        try UploadingImageValiadtor(data: compressedImage).validate()
                    } catch {
                        observer.onError(error)
                    }
                    observer.onNext(compressedImage)
                    return Disposables.create()
                }.materialize()
            }.share(replay: 1, scope: .whileConnected)
        
        let request = imageValidation.elements()
            //            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
            .flatMap {
                repository.addReceiptPhoto(transactionId ?? "", $0, "receipt-image", "receipt_image.jpg", "image/jpg") }
            .share(replay: 1, scope: .whileConnected)
        
        request.elements()
            .map {_ in }
            .do(onNext: {[weak self] _ in YAPProgressHud.hideProgressHud(); self?.fetchReceiptsFromServerSubject.onNext(()) })
            .delaySubscription(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: addReceiptSuccessAlertSubject)
            .disposed(by: disposeBag)
        
        Observable.merge(imageValidation.errors(),
                         request.errors())
            .map { $0.localizedDescription }
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .delaySubscription(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
    } */
    
  /*  func fetchAllReceipts(repository: TransactionsRepository, transactionId: String?) {
        let request = fetchReceiptsFromServer
            .flatMap { repository.getAllReceipts(transactionId ?? "") }
            .share(replay: 1, scope: .whileConnected)
        
        request.elements()
            .unwrap()
            .map{ $0 }
            .bind(to: receiptsSubject)
            .disposed(by: disposeBag)
        
        request
            .errors()
            .map { $0.localizedDescription }
            .bind(to: errorSubject).disposed(by: disposeBag)
    } */
}

private extension TransactionDetailsViewModel {
    
    var validateTotalPurchaseCriteria: Bool {
        
        if transaction.productCode.isValidForTotalPurchase && transaction.type == .debit {
            if transaction.productCode == .uaeftsTransfer
                || transaction.productCode == .swift {
                
                if transaction.transactionStatus != .inProgress {
                    return true
                }else{
                    return false
                }
            }
            return true
        }else{
            if transaction.productCode == .y2yTransfer && transaction.type == .credit {
                return true
            }
            return false
        }
    }
    
    var beneficiaryIdInCaseOfSendMoney: String? {
        (transaction.productCode.isSendMoney || transaction.productCode == .ibftTransaction ) ? self.transaction.beneficiaryId : nil
    }
    
    var receiverCustomerIdInCaseOfY2Y: String? {
        transaction.productCode == .y2yTransfer && transaction.type == .debit ? self.transaction.customerId : nil
    }
    
    var senderCustomerIdInCaseOfY2Y: String? {
        transaction.productCode == .y2yTransfer && transaction.type == .credit ? self.transaction.customerId : nil
    }
    
    var merchantNameInCaseOfPOSEcom: String? {
        transaction.productCode == .posPurchase || transaction.productCode == .eCom ? self.transaction.merchantName : nil
    }
    
    var processTransactionType: TransactionType {
        return senderCustomerIdInCaseOfY2Y != nil ? .credit : .debit
    }
    
}

private extension TransactionDetailsViewModel {
    enum TransactionDetailsLocalizations: String {
        case spent = "screen_transaction_details_display_text_spent"
        case received = "screen_transaction_details_display_text_received"
        case fee = "screen_transaction_details_display_text_fee"
        case totalAmount = "screen_transaction_details_display_text_total_amount"
        case addNote = "screen_transaction_details_display_text_add_note"
        case addReceipt = "screen_transaction_details_display_text_add_receipt"
        case addReceiptDescription = "screen_transaction_details_display_text_add_receipt_description"
        case editNote = "screen_transaction_details_display_text_edit_note"
        case noteDescription = "screen_transaction_details_display_text_note_description"
        case senderName = "screen_transaction_details_display_text_sendare_name"
        case receiverName = "screen_transaction_details_display_text_receiver_name"
        case vat = "screen_transaction_details_display_text_vat"
        
        var localized: String { rawValue.localized }
    }
    
}

private extension TransactionDetailsViewModel {
    var transactionBackgroundImage: UIImage? {
        
        guard !transaction.productCode.isFee else {
            return UIImage.init(named: "td_image_light_red_background", in: .yapPakistan, compatibleWith: nil)
        }
        
        switch transaction.productCode {
        
        case .y2yTransfer:
            return UIImage.init(named: "td_image_blue_background", in: .yapPakistan, compatibleWith: nil)
            
        case .addFundsSupplementaryCard, .removeFundsSuplementaryCard:
            return UIImage.init(named: "td_image_brown_background", in: .yapPakistan, compatibleWith: nil)
            
        case .uaeftsTransfer, .domestic, .swift, .rmt, .cashPayout, .topUpByExternalCard, .inwardRemittance, .localInwardRemittance, .fundLoad://, .billPayments:
            return UIImage.init(named: "td_image_light_blue_background", in: .yapPakistan, compatibleWith: nil)
            
        case .debitCardReorder:
            return UIImage.init(named: "td_image_light_red_background", in: .yapPakistan, compatibleWith: nil)
            
        case .atmWithdrawl, .posPurchase, .cashDepositInBank, .chequeDepositInBank, .masterCardATMWithdrawl, .eCom ,.atmDeposit:
        /*    return UIImage.init(named: "icon_location_map", in: .yapPakistan, compatibleWith: nil) */
            return UIImage.init(named: "td_image_light_red_background", in: .yapPakistan, compatibleWith: nil)
        default:
            return nil
        }
    }
    
    var showLocation: Bool {
        switch transaction.productCode {
            case .atmWithdrawl, .posPurchase ,.eCom:
                return true
            default:
                return false
        }
    }
}

