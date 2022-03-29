//
//  TopUpAccountDetailsCellViewModel.swift
//  YAP
//
//  Created by Zain on 14/02/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import YAPComponents
import RxSwift

public enum TopUpAccountDetailType {
    case accountName
    case iban
    case bankName
    case bankAddress
    case accountNumber
    case swiftCode
}

protocol TopUpAccountDetailsCellViewModelInput {
    var copyObserver: AnyObserver<Void>{ get }
}

protocol TopUpAccountDetailsCellViewModelOutput {
    var title: Observable<String?> { get }
    var details: Observable<String?> { get }
    var isHideCopyButton: Observable<Bool>{ get }
}

protocol TopUpAccountDetailsCellViewModelType {
    var inputs: TopUpAccountDetailsCellViewModelInput { get }
    var outputs: TopUpAccountDetailsCellViewModelOutput { get }
}

class TopUpAccountDetailsCellViewModel: TopUpAccountDetailsCellViewModelType, TopUpAccountDetailsCellViewModelInput, TopUpAccountDetailsCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: TopUpAccountDetailsCellViewModelInput { return self }
    var outputs: TopUpAccountDetailsCellViewModelOutput { return self }
    var reusableIdentifier: String { TopUpAccountDetailsCell.defaultIdentifier }
    var topupAcoountDetailsType: TopUpAccountDetailType!
    
    private let titleSubject = BehaviorSubject<String?>(value: nil)
    private let detailsSubject = BehaviorSubject<String?>(value: nil)
    private let isHideCopyButtonSubject = BehaviorSubject<Bool>(value: true)
    private let copySubject = PublishSubject<Void>()
    
    // MARK: - Inputs
    var copyObserver: AnyObserver<Void>{ return copySubject.asObserver() }
    
    // MARK: - Outputs
    var title: Observable<String?> { titleSubject.asObservable() }
    var details: Observable<String?> { detailsSubject.asObservable() }
    var isHideCopyButton: Observable<Bool>{ return isHideCopyButtonSubject.asObservable() }
    
    // MARK: - Init
    init(type: TopUpAccountDetailType, details: String) {
        self.topupAcoountDetailsType = type
        titleSubject.onNext(titleString)
        detailsSubject.onNext(details)
        
        if self.topupAcoountDetailsType == .iban || self.topupAcoountDetailsType == .swiftCode || self.topupAcoountDetailsType == .accountNumber {
            self.isHideCopyButtonSubject.onNext(false)
            copySubject.subscribe(onNext: { _ in
                print("Details = ", details)
                UIPasteboard.general.string =  self.topupAcoountDetailsType == .iban ? "IBAN: " + details : self.topupAcoountDetailsType == .swiftCode ? "Swift/BIC: " + details : "Account number:" + details
                YAPToast.show("Copied to clipboard")
            }).disposed(by: disposeBag)
            
            /*if we apply filter and take TopUpAccountDetailType values from observable then it will subcribe 6 time and actual required subscription is only two, thats why i used it if condition that make sure only two required subcriptions.*/
        }
    }
}


extension TopUpAccountDetailsCellViewModel {
    var titleString: String {
        switch self.topupAcoountDetailsType {
        case .accountName:
            return "Account name"
        case .iban:
            return "IBAN"
        case .bankName:
            return "Bank name"
        case .bankAddress:
            return "Bank address"
        case .accountNumber:
            return "Account number"
        case .swiftCode:
            return "Swift/BIC"
        case .none:
            return ""
        }
    }
}
