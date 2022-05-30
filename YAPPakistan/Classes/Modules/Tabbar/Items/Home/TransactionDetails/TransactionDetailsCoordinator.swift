//
//  TransactionDetailsCoordinator.swift
//  YAPPakistan
//
//  Created by Umair  on 23/05/2022.
//

import Foundation
import RxSwift
import YAPComponents
import YAPCore

public class TransactionDetailsCoordinator: Coordinator<ResultType<Void>> {
    
    private let root: UIViewController
    private var localNavRoot: UINavigationController!
    private let result = PublishSubject<ResultType<Void>>()
    private var container: UserSessionContainer!
    let repository: TransactionsRepositoryType
    private let transaction: TransactionResponse
    
    init(root: UIViewController, container: UserSessionContainer, repository: TransactionsRepositoryType, transaction: TransactionResponse) {
        self.root = root
        self.container = container
        self.repository = repository
        self.transaction = transaction
    }
    
    public override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        let viewModel = TransactionDetailsViewModel(repository: self.repository, transaction: transaction, themeService: container.themeService)
        let viewController = TransactionDetailsViewController(themeService: container.themeService, viewModel: viewModel)
        
        self.localNavRoot = UINavigationControllerFactory.createTransparentNavigationBarNavigationController(rootViewController: viewController)
        localNavRoot.setNavigationBarHidden(true, animated: false)
        localNavRoot.modalPresentationStyle = .fullScreen
        
        viewModel.outputs.back.subscribe(onNext: { [weak self] in
            self?.localNavRoot.dismiss(animated: true, completion: nil)
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.openReceipt.subscribe(onNext: { [unowned self] (imageURL, transactionId) in
            
            print("Image URL: \(imageURL)")
            print("TransactionID: \(transactionId)")
            self.navigateToViewReceipt(imageURL: imageURL, transactionID: transactionId)
            
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.share.subscribe(onNext: { [unowned self] transaction in
            let viewModel = TransactionReceiptViewModel(transactionRepository: self.container.makeTransactionsRepository(), transaction: TransactionResponse())
            let viewController = TransactionReceiptViewController(viewModel: viewModel, themeService: self.container.themeService)
            let navController = UINavigationControllerFactory.createAppThemedNavigationController(root: viewController, themeColor: UIColor(container.themeService.attrs.primaryDark), font: UIFont.regular)
            viewModel.outputs.back.subscribe(onNext: { _ in
                print("Back Pressed")
                navController.dismiss(animated: true, completion: nil)
            }).disposed(by: rx.disposeBag)
            localNavRoot.present(navController, animated: true)
            //navigationRoot.present(navController, animated: true)
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.addNote.unwrap().withUnretained(self).subscribe(onNext:  { (`self`, _) in
            self.navigateToAddNote(viewModel: viewModel)
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.totalTransactions.unwrap().withUnretained(self).subscribe(onNext: { `self`,model in
            self.navigateToTotalTransactionList(vm: model, totalPuchase: CurrencyFormatter.formatAmountInLocalCurrency(abs(viewModel.transactionTotalPurchase?.totalSpendAmount ?? 0.00)))
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.addReceipt.withUnretained(self).subscribe(onNext: { `self`,_ in
            self.navigateToTransactionReceipt()
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.receiptUploadSuccess.subscribe(onNext: { [unowned self] _ in
            self.navigateToReceiptSuccessUplaoded(vm: viewModel)
        }).disposed(by: rx.disposeBag)

        root.present(self.localNavRoot, animated: true, completion: nil)
        
        return result
    }
    
    private func navigateToViewReceipt(imageURL : String, transactionID: String) {
        let viewModel = ViewReceiptViewModel(imageURL: imageURL, transcationID: transactionID)
        let viewController = ViewReceiptViewController(viewModel: viewModel, themeService: self.container.themeService)
        let navController = UINavigationControllerFactory.createAppThemedNavigationController(root: viewController, themeColor: UIColor(container.themeService.attrs.primaryDark), font: UIFont.regular)
        localNavRoot.present(navController, animated: true)
    }
    
    private func navigateToReceiptSuccessUplaoded(vm: TransactionDetailsViewModelType) {
        let viewModel = ReceiptUploadSuccessViewModel()
        let viewController = ReceiptUploadSuccessViewController(viewModel: viewModel, themeService: self.container.themeService)
        
        viewModel.outputs.done.subscribe(onNext: { [unowned self] _ in
            localNavRoot.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.addAnotherReceipt.subscribe(onNext: { [unowned self] _ in
            localNavRoot.dismiss(animated: true, completion: nil)
            vm.inputs.openReciptImagePicker.onNext(())
        }).disposed(by: rx.disposeBag)
        
        localNavRoot.present(viewController, animated: true, completion: nil)
    }
    
    private func navigateToAddNote(viewModel: TransactionDetailsViewModelType) {
        let noteTransactionViewModel = AddTransactionDetailViewModel(transaction: transaction, transactionRepository: self.container.makeTransactionsRepository())

        let noteTransactionViewController = AddTransactionNoteViewController(viewModel: noteTransactionViewModel, themeService: self.container.themeService)

        let navController = UINavigationControllerFactory.createAppThemedNavigationController(root: noteTransactionViewController, themeColor: UIColor(container.themeService.attrs.primaryDark), font: UIFont.regular)

        noteTransactionViewModel.outputs.back.subscribe(onNext: { updatedTransaction in



            navController.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)

        noteTransactionViewModel.outputs.success.subscribe(onNext: { updatedTransaction in
            print("Note successfully update")

            navController.dismiss(animated: true, completion: nil)
            viewModel.inputs.updatedTransactionOnNoteObserver.onNext(updatedTransaction)
        }).disposed(by: rx.disposeBag)

        localNavRoot.present(navController, animated: true)
        
        
    }
    
    private func navigateToTotalTransactionList(vm: TotalTransactionModel, totalPuchase :String) {
        let viewModel = TotalTransactionsViewModel(txnType: vm.transaction.type.rawValue, productCode: vm.transaction.productCode.rawValue , receiverCustomerId: vm.receiverCustomerId, senderCustomerId: vm.senderCustomerId, beneficiaryId: vm.beneficiaryId, merchantName: vm.transaction.receiverName, totalPurchase: totalPuchase, transactionRepository: self.container.makeTransactionsRepository(), themeService: self.container.themeService)
        
        let viewController = TotalTransactionsViewController(viewModel: viewModel, themeService: self.container.themeService)
        
        let navController = UINavigationControllerFactory.createAppThemedNavigationController(root: viewController, themeColor: UIColor(container.themeService.attrs.primaryDark), font: UIFont.regular)
        
        viewModel.outputs.back.subscribe(onNext: { _ in
            
            print("Back Pressed")
            
            navController.dismiss(animated: true, completion: nil)
            
        }).disposed(by: rx.disposeBag)
        
        localNavRoot.present(navController, animated: true)
    }
    
    private func navigateToTransactionReceipt() {
        let viewModel = TransactionReceiptViewModel(transactionRepository: self.container.makeTransactionsRepository(), transaction: transaction)
        
        let viewController = TransactionReceiptViewController(viewModel: viewModel, themeService: self.container.themeService)
        
        let navController = UINavigationControllerFactory.createAppThemedNavigationController(root: viewController, themeColor: UIColor(container.themeService.attrs.primaryDark), font: UIFont.regular)
        
        viewModel.outputs.back.subscribe(onNext: { _ in
            
            print("Back Pressed")
            
            navController.dismiss(animated: true, completion: nil)
            
        }).disposed(by: rx.disposeBag)
        
        localNavRoot.present(navController, animated: true)
    }
}
