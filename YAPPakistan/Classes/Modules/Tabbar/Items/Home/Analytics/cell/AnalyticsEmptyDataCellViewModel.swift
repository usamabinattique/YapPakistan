//
//  NoDataIndecationCellViewModel.swift
//  Cards
//
//  Created by Wajahat Hassan on 16/02/2021.
//  Copyright © 2021 YAP. All rights reserved.
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

