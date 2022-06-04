//
//  NoDataIndecationCellViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 16/05/2022.
//

import Foundation
import RxSwift

class AnalyticsEmptyDataCellViewModel: ReusableTableViewCellViewModelType {
    
    //MARK: - Properties
    var reusableIdentifier: String { return AnalyticsEmptyDataCell.defaultIdentifier }
    
    private let noDataSubject = BehaviorSubject<String>(value: "Nothing to report yet this month")
    
    //MARK: - Inputs
    
    //MARK: - Outputs
    public var noData: Observable<String>{ noDataSubject.asObservable() }
    
    //MARK: - Constructor/init
    
    init() { }
    
    
}

