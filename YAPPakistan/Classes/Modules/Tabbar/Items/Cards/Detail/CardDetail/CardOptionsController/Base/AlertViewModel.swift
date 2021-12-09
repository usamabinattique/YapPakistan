//
//  AlertViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 08/12/2021.
//

import Foundation
import RxSwift

protocol AlertViewModelOutput {
    var tapIndex: Observable<Int> { get }
}

protocol AlertViewModelInput {
    var tapIndexObserver: AnyObserver<Int?> { get }
}

protocol AlertViewModelType: AlertViewModelOutput, AlertViewModelInput {
    var inputs: AlertViewModelInput { get }
    var outputs: AlertViewModelOutput { get }
}

struct AlertViewModel: AlertViewModelType {
    var tapIndexSubject = BehaviorSubject<Int?>(value: nil)

    var tapIndex: Observable<Int> { tapIndexSubject.unwrap().asObservable() }

    var tapIndexObserver: AnyObserver<Int?> { tapIndexSubject.asObserver() }

    var inputs: AlertViewModelInput { self }
    var outputs: AlertViewModelOutput { self }

    let title: String?
    let message: String?
    let style: UIAlertController.Style
    let actions: [ActionViewModel]

    struct ActionViewModel {
        let title: String
        let style: UIAlertAction.Style
    }
}
