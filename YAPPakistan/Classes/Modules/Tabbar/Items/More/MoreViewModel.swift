//
//  MoreViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import Foundation
import YAPComponents
import RxSwift

protocol MoreViewModelInputs {

}

protocol MoreViewModelOutputs {

}

protocol MoreViewModelType {
    var inputs: MoreViewModelInputs { get }
    var outputs: MoreViewModelOutputs { get }
}

class MoreViewModel: MoreViewModelType, MoreViewModelInputs, MoreViewModelOutputs {

    var inputs: MoreViewModelInputs { return self }
    var outputs: MoreViewModelOutputs { return self }

    // MARK: - Properties
    let disposeBag = DisposeBag()

    // MARK: - Init
    init() {

    }
}

