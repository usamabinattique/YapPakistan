//
//  HomeViewModel.swift
//  YAP
//
//  Created by Muhammad Hassan on 29/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import YAPComponents
import RxSwift

protocol HomeViewModelInputs {

}

protocol HomeViewModelOutputs {

}

protocol HomeViewModelType {
    var inputs: HomeViewModelInputs { get }
    var outputs: HomeViewModelOutputs { get }
}

class HomeViewModel: HomeViewModelType, HomeViewModelInputs, HomeViewModelOutputs {

    var inputs: HomeViewModelInputs { return self }
    var outputs: HomeViewModelOutputs { return self }

    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    // MARK: - Init
    init() {

    }
}
