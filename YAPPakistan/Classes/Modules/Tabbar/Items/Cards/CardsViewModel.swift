//
//  CardsViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import Foundation
import YAPComponents
import RxSwift

protocol CardsViewModelInputs {

}

protocol CardsViewModelOutputs {

}

protocol CardsViewModelType {
    var inputs: CardsViewModelInputs { get }
    var outputs: CardsViewModelOutputs { get }
}

class CardsViewModel: CardsViewModelType, CardsViewModelInputs, CardsViewModelOutputs {

    var inputs: CardsViewModelInputs { return self }
    var outputs: CardsViewModelOutputs { return self }

    // MARK: - Properties
    let disposeBag = DisposeBag()

    // MARK: - Init
    init() {

    }
}

