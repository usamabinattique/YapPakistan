//
//  StoreViewModelInputs.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import Foundation
import YAPComponents
import RxSwift

protocol StoreViewModelInputs {

}

protocol StoreViewModelOutputs {

}

protocol StoreViewModelType {
    var inputs: StoreViewModelInputs { get }
    var outputs: StoreViewModelOutputs { get }
}

class StoreViewModel: StoreViewModelType, StoreViewModelInputs, StoreViewModelOutputs {

    var inputs: StoreViewModelInputs { return self }
    var outputs: StoreViewModelOutputs { return self }

    // MARK: - Properties
    let disposeBag = DisposeBag()

    // MARK: - Init
    init() {

    }
}

