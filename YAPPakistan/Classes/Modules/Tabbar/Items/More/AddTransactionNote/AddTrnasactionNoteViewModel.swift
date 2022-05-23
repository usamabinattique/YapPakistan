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
}

protocol AddTransactionDetailViewModelOutput {
    var isActiveSaveBtn: Observable<Bool> { get }
    var error: Observable<String> { get }
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
    var transactionID : String
    var transactionRepo : TransactionsRepositoryType
    
    // MARK: Inputs
    var noteTextViewObserver: AnyObserver<String> { return noteTextViewSubject.asObserver() }
    var saveNoteTappedObserver: AnyObserver<Void> { return saveNoteTappedSubject.asObserver()}
    
    // MARK: Outputs
    var isActiveSaveBtn: Observable<Bool> { return isActiveSaveBtnSubject.asObservable() }
    var error: Observable<String> { return errorSubject.asObservable() }
     
    
    // MARK: Subjects
    internal var noteTextViewSubject = BehaviorSubject<String>(value: "")
    internal var isActiveSaveBtnSubject = BehaviorSubject<Bool>(value: false)
    internal var saveNoteTappedSubject = PublishSubject<Void>()
    internal var errorSubject = PublishSubject<String>()
    
    // MARK: - Init
    init(transactionID: String, transactionRepository: TransactionsRepositoryType) {
        self.transactionID = transactionID
        self.transactionRepo = transactionRepository
        
        saveNoteTapped()
        iSActiveSaveButtonBinding()
    }
    
    func saveNoteTapped() {
        let req = saveNoteTappedSubject.withLatestFrom(self.noteTextViewSubject).share()
        
        req.subscribe(onNext: { [unowned self] note in
            
            var addNoteReq = transactionRepo.addTransactionNote(trnsactionID: self.transactionID, transactionNote: note, receiverTransactionNote: nil)
            
            addNoteReq.elements().subscribe(onNext: { data in
                print(data)
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

