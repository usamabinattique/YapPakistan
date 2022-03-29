//
//  TableViewButtonCellViewModel.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 17/11/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import RxSwift

public enum ButtonBackgroundType {
    case fill
    case light
}

protocol TableViewButtonCellViewModelInput {
    var buttonObserver: AnyObserver<Void>{ get }
}

public protocol TableViewButtonCellViewModelOutput {
    var title: Observable<String?> { get }
    var buttonType: Observable<ButtonBackgroundType?>{ get }
    var button: Observable<Void>{ get }
}

protocol TableViewButtonCellViewModelType {
    var inputs: TableViewButtonCellViewModelInput { get }
    var outputs: TableViewButtonCellViewModelOutput { get }
}

public class TableViewButtonCellViewModel: TableViewButtonCellViewModelType, TableViewButtonCellViewModelInput, TableViewButtonCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: TableViewButtonCellViewModelInput { return self }
    public var outputs: TableViewButtonCellViewModelOutput { return self }
    public var reusableIdentifier: String { TableViewButtonCell.defaultIdentifier }
    
    private let titleSubject: BehaviorSubject<String?>
    private let buttonTypeSubject: BehaviorSubject<ButtonBackgroundType?>
    private let buttonSubject = PublishSubject<Void>()
    
    // MARK: - Inputs
    var buttonObserver: AnyObserver<Void>{ return buttonSubject.asObserver() }
    
    // MARK: - Outputs
    public var button: Observable<Void>{ return buttonSubject.asObservable() }
    public var title: Observable<String?> { titleSubject.asObservable() }
    public var buttonType: Observable<ButtonBackgroundType?> { buttonTypeSubject.asObservable() }
    
    // MARK: - Init
    public init(title: String, background: ButtonBackgroundType? = .fill) {
        titleSubject = BehaviorSubject<String?>(value: title)
        buttonTypeSubject = BehaviorSubject<ButtonBackgroundType?>(value: background)
    }
}
