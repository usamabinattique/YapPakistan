//
//  SMFTPOPCategoryCellViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 29/03/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift

protocol SMFTPOPCategoryCellViewModelInput {
    var tapObserver: AnyObserver<Void> { get }
    var selectionObserver: AnyObserver<Bool> { get }
}

protocol SMFTPOPCategoryCellViewModelOutput {
    var title: Observable<String?> { get }
    var showsDropdown: Observable<Bool> { get }
    var dropdownOpened: Observable<Bool> { get }
    var tap: Observable<TransferReason> { get }
}

protocol SMFTPOPCategoryCellViewModelType {
    var inputs: SMFTPOPCategoryCellViewModelInput { get }
    var outputs: SMFTPOPCategoryCellViewModelOutput { get }
}

class SMFTPOPCategoryCellViewModel: SMFTPOPCategoryCellViewModelType, SMFTPOPCategoryCellViewModelInput, SMFTPOPCategoryCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: SMFTPOPCategoryCellViewModelInput { return self }
    var outputs: SMFTPOPCategoryCellViewModelOutput { return self }
    var reusableIdentifier: String { return SMFTPOPCategoryCell.defaultIdentifier }
    
    private let titleSubject: BehaviorSubject<String?>
    private let showsDropdownSubject: BehaviorSubject<Bool>
    private let dropdownOpenedSubject = BehaviorSubject<Bool>(value: false)
    private let tapSubject = PublishSubject<Void>()
    private let selectionSubject = PublishSubject<Bool>()
    
    // MARK: - Inputs
    var tapObserver: AnyObserver<Void> { tapSubject.asObserver() }
    var selectionObserver: AnyObserver<Bool> { selectionSubject.asObserver() }
    
    // MARK: - Outputs
    var title: Observable<String?> { titleSubject.asObservable() }
    var showsDropdown: Observable<Bool> { showsDropdownSubject.asObservable() }
    var dropdownOpened: Observable<Bool> { dropdownOpenedSubject.asObservable() }
    var tap: Observable<TransferReason> { tapSubject.map{ [unowned self] in self.pop }.asObservable() }
    
    let pop: TransferReason!
    
    // MARK: - Init
    init(_ pop: TransferReason) {
        self.pop = pop
        titleSubject = BehaviorSubject<String?>(value: pop.transferReason)
        showsDropdownSubject = BehaviorSubject<Bool>(value: false)//pop.isCategory)
        
        selectionSubject.bind(to: dropdownOpenedSubject).disposed(by: disposeBag)
    }
}

