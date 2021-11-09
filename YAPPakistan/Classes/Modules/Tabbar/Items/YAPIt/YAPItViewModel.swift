//
//  YAPItViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import Foundation
import YAPComponents
import RxSwift

protocol YAPItViewModelInputs {

}

protocol YAPItViewModelOutputs {

}

protocol YAPItViewModelType {
    var inputs: YAPItViewModelInputs { get }
    var outputs: YAPItViewModelOutputs { get }
}

class YAPItViewModel: YAPItViewModelType, YAPItViewModelInputs, YAPItViewModelOutputs {

    var inputs: YAPItViewModelInputs { return self }
    var outputs: YAPItViewModelOutputs { return self }

    // MARK: - Properties
    let disposeBag = DisposeBag()

    // MARK: - Init
    init() {

    }
}

