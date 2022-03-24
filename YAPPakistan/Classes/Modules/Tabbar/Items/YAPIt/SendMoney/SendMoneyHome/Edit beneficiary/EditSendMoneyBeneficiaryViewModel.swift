//
//  EditSendMoneyBeneficiaryViewModel.swift
//  YAPPakistan
//
//  Created by Muhammad Sohaib on 15/03/2022.
//

import Foundation
import RxSwift
import RxDataSources
import YAPCore
import YAPComponents

protocol EditSendMoneyBeneficiaryViewModelInput {
    var backObserver: AnyObserver<Void> { get }
    var retakeObserver: AnyObserver<Void> { get }
    var imageObserver: AnyObserver<UIImage?> { get }
    var sendMoneyObserver: AnyObserver<Void> { get }
    var saveBeneficiaryObserver: AnyObserver<Void> { get }
    var showDeletePopupObserver: AnyObserver<Void> { get }
    var deleteBeneficiaryObserver: AnyObserver<Void> { get }
    var addProfilePictureObserver: AnyObserver<Void> { get }
    var profilePictureUpdatedObserver: AnyObserver<String> { get }
    var cellSelectedObserver: AnyObserver<ReusableTableViewCellViewModelType> { get }
}

protocol EditSendMoneyBeneficiaryViewModelOutput {
    var back: Observable<Void> { get }
    var result: Observable<Void> { get }
    var error: Observable<String> { get }
    var image: Observable<UIImage?> { get }
    var showDeletePopup: Observable<Void> { get }
    var addProfilePicture: Observable<Void> { get }
    var profilePictureUpdated: Observable<String> { get }
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
}

protocol EditSendMoneyBeneficiaryViewModelType {
    var inputs: EditSendMoneyBeneficiaryViewModelInput { get }
    var outputs: EditSendMoneyBeneficiaryViewModelOutput { get }
}

class EditSendMoneyBeneficiaryViewModel: EditSendMoneyBeneficiaryViewModelType, EditSendMoneyBeneficiaryViewModelInput, EditSendMoneyBeneficiaryViewModelOutput {
        
    // MARK: Properties
    let disposeBag = DisposeBag()
    var inputs: EditSendMoneyBeneficiaryViewModelInput { self }
    var outputs: EditSendMoneyBeneficiaryViewModelOutput { self }
    
    var repository : YapItRepository!
    
    private let backSubject = PublishSubject<Void>()
    private let resultSubject = PublishSubject<Void>()
    private let errorSubject = PublishSubject<String>()
    private let imageSubject = PublishSubject<UIImage?>()
    private let sendMoneySubject = PublishSubject<Void>()
    private let saveBeneficiarySubject = PublishSubject<Void>()
    private let showDeletePopupSubject = PublishSubject<Void>()
    private let deleteBeneficiarySubject = PublishSubject<Void>()
    private let addProfilePictureSubject = PublishSubject<Void>()
    let profilePictureUpdatedSubject = PublishSubject<String>()
    private let cellSelectedSubject = PublishSubject<ReusableTableViewCellViewModelType>()
    private let dataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    
    var beneficiary: SendMoneyBeneficiary!
    let sendMoneyType: SendMoneyType
    var viewModels: [ReusableTableViewCellViewModelType] = []
    
    // MARK: inputs
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    var imageObserver: AnyObserver<UIImage?> { imageSubject.asObserver() }
    var sendMoneyObserver: AnyObserver<Void> { sendMoneySubject.asObserver() }
    var retakeObserver: AnyObserver<Void> { addProfilePictureSubject.asObserver() }
    var saveBeneficiaryObserver: AnyObserver<Void> { saveBeneficiarySubject.asObserver() }
    var showDeletePopupObserver: AnyObserver<Void> { showDeletePopupSubject.asObserver() }
    var deleteBeneficiaryObserver: AnyObserver<Void> { deleteBeneficiarySubject.asObserver() }
    var addProfilePictureObserver: AnyObserver<Void> { addProfilePictureSubject.asObserver() }
    var profilePictureUpdatedObserver: AnyObserver<String> { profilePictureUpdatedSubject.asObserver() }
    var cellSelectedObserver: AnyObserver<ReusableTableViewCellViewModelType> { cellSelectedSubject.asObserver() }
    
    // MARK: outputs
    var back: Observable<Void> { backSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var result: Observable<Void> { resultSubject.asObservable() }
    var image: Observable<UIImage?> { imageSubject.asObservable() }
    var showDeletePopup: Observable<Void> { showDeletePopupSubject.asObservable() }
    var addProfilePicture: Observable<Void> { addProfilePictureSubject.asObservable() }
    var profilePictureUpdated: Observable<String> { profilePictureUpdatedSubject.asObservable() }
    var dataSource: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { dataSourceSubject.asObservable() }
    
    // MARK: - Init
    init(beneficiary: SendMoneyBeneficiary,
         sendMoneyType: SendMoneyType, repository: YapItRepository) {
        
        self.beneficiary = beneficiary
        self.sendMoneyType = sendMoneyType
        self.repository = repository
        
        editBeneficiary(repository)
        deleteBeneficiary(repository)
        generateCellViewModels()
        loadCells()
    }
    
    func generateCellViewModels() {
        fatalError("'generateCellViewModels()' not implementd")
    }
    
    internal func loadCells() {
        dataSourceSubject.onNext([SectionModel(model: 0, items: viewModels)])
    }
}

// MARK: Save Beneficiary API

extension EditSendMoneyBeneficiaryViewModel {

    func editBeneficiary(_ repository: YapItRepository) {

        let request = saveBeneficiarySubject
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
                .flatMap { repository.editBeneficiary([], id: String(self.beneficiary.id ?? 0), nickname: self.beneficiary.nickName) }
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .share()

        request.errors().map { $0.localizedDescription }.bind(to: errorSubject).disposed(by: disposeBag)

        request.elements().map { _ in }.bind(to: resultSubject).disposed(by: disposeBag)
    }
    
    func deleteBeneficiary(_ repository: YapItRepository) {

        let request = deleteBeneficiarySubject
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
                .flatMap { repository.deleteBeneficiary(id: String(self.beneficiary.id ?? 0) ) }
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .share()

        request.errors().map { $0.localizedDescription }.bind(to: errorSubject).disposed(by: disposeBag)

        request.elements().map { _ in }.bind(to: resultSubject).disposed(by: disposeBag)
    }
}
