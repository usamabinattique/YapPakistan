//
//  AddTrnasactionNoteViewModel.swift
//  YAPPakistan
//
//  Created by Awais on 23/05/2022.
//

import Foundation
import YAPComponents
import RxSwift
import RxDataSources
import RxTheme
import UIKit

protocol AddTransactionDetailViewModelInput {
    var noteTextViewObserver: AnyObserver<String> { get }
    var saveNoteTappedObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
}

protocol AddTransactionDetailViewModelOutput {
    var isActiveSaveBtn: Observable<Bool> { get }
    var error: Observable<String> { get }
    var note: Observable<String?> { get }
    var back: Observable<Void> { get }
    var success: Observable<TransactionResponse> { get }
}

protocol AddTransactionDetailViewModelType {
    var inputs: AddTransactionDetailViewModelInput { get }
    var outputs: AddTransactionDetailViewModelOutput { get }
}

class AddTransactionDetailViewModel: AddTransactionDetailViewModelType, AddTransactionDetailViewModelInput, AddTransactionDetailViewModelOutput {

    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: AddTransactionDetailViewModelInput { return self }
    var outputs: AddTransactionDetailViewModelOutput { return self }
    var transaction : TransactionResponse
    var transactionRepo : TransactionsRepositoryType
    var previousNote : String?
    
    // MARK: Inputs
    var noteTextViewObserver: AnyObserver<String> { return noteTextViewSubject.asObserver() }
    var saveNoteTappedObserver: AnyObserver<Void> { return saveNoteTappedSubject.asObserver()}
    var backObserver: AnyObserver<Void> { return backSubject.asObserver() }
    
    // MARK: Outputs
    var isActiveSaveBtn: Observable<Bool> { return isActiveSaveBtnSubject.asObservable() }
    var error: Observable<String> { return errorSubject.asObservable() }
    var note: Observable<String?> { return noteSubject.asObservable() }
    var back: Observable<Void> { return backSubject.asObservable() }
    var success: Observable<TransactionResponse> { return successSubject.asObservable() }
    
    // MARK: Subjects
    internal var noteTextViewSubject = BehaviorSubject<String>(value: "")
    internal var isActiveSaveBtnSubject = BehaviorSubject<Bool>(value: false)
    internal var saveNoteTappedSubject = PublishSubject<Void>()
    internal var errorSubject = PublishSubject<String>()
    internal var backSubject = PublishSubject<Void>()
    internal var noteSubject = BehaviorSubject<String?>(value: "Type Something...") //PublishSubject<String>()
    internal var successSubject = PublishSubject<TransactionResponse>()
    
    // MARK: - Init
    init(transaction: TransactionResponse, transactionRepository: TransactionsRepositoryType) {
        self.transaction = transaction
        self.transactionRepo = transactionRepository
        self.previousNote = transaction.transactionNote
        
        saveNoteTapped()
        iSActiveSaveButtonBinding()
        
        noteSubject.onNext(transaction.transactionNote)
    }
    
    func saveNoteTapped() {
//        var theNote: String?
//        let req = saveNoteTappedSubject
//            .withLatestFrom(self.noteTextViewSubject)
//            .flatMap { [unowned self] note in
////                theNote = note
//                transactionRepo.addTransactionNote(trnsactionID: self.transaction.transactionId, transactionNote: note, receiverTransactionNote: nil)
//            }.share()
        let req = saveNoteTappedSubject
            .withLatestFrom(self.noteTextViewSubject).share()
        
        req.subscribe(onNext: { [unowned self] note in
            
            let addNoteReq = transactionRepo.addTransactionNote(trnsactionID: self.transaction.transactionId, transactionNote: note, receiverTransactionNote: nil)
            
            addNoteReq.elements().subscribe(onNext: { [unowned self] date in
                print(date)
                self.transaction.transactionNoteDate = DateFormatter.transactionDateFormatter.date(from:   date.formattedDateString  )  //data
                self.transaction.transactionNote = note
                self.successSubject.onNext(self.transaction)
            }).disposed(by: disposeBag)
            
            let error = addNoteReq.errors().map{ $0.localizedDescription }
            error
                .bind(to: errorSubject).disposed(by: disposeBag)
            
        }).disposed(by: disposeBag)
    }
    
    func iSActiveSaveButtonBinding() {
        noteTextViewSubject.subscribe(onNext: { [unowned self] noteText in
            print(noteText)
            if noteText.isEmpty {
                self.isActiveSaveBtnSubject.onNext(false)
            }
            else if noteText == "Type Something..." {
                self.isActiveSaveBtnSubject.onNext(false)
            }
            else {
                self.isActiveSaveBtnSubject.onNext(true)
            }
        }).disposed(by: disposeBag)
    }
}

