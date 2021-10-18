//
//  CaptureViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 14/10/2021.
//

import Foundation
import RxSwift

protocol CaptureViewModelInputs {

}

protocol CaptureViewModelOutputs {

}

protocol CaptureViewModelType {
    var inputs: CaptureViewModelInputs { get }
    var outputs: CaptureViewModelOutputs { get }
}

class CaptureViewModel: CaptureViewModelType, CaptureViewModelInputs, CaptureViewModelOutputs {

    var inputs: CaptureViewModelInputs { self }
    var outputs: CaptureViewModelOutputs { self }

    init() {

    }
    
}

