//
//  WelcomePageChildViewModel.swift
//  YAP
//
//  Created by Zain on 19/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol WelcomePageChildViewModelInput {

}

protocol WelcomePageChildViewModelOutput {
    var heading: Observable<String> { get }
    var details: Observable<String> { get }
    var image: Observable<UIImage?> { get }
}

protocol WelcomePageChildViewModelType {
    var inputs: WelcomePageChildViewModelInput { get }
    var outputs: WelcomePageChildViewModelOutput { get }
}

class WelcomePageChildViewModel: WelcomePageChildViewModelInput, WelcomePageChildViewModelOutput, WelcomePageChildViewModelType {
    var inputs: WelcomePageChildViewModelInput { return self }
    var outputs: WelcomePageChildViewModelOutput { return self }

    fileprivate var headingSubject = BehaviorSubject<String>(value: "")
    fileprivate var detailsSubject = BehaviorSubject<String>(value: "")
    fileprivate var imageSubject = BehaviorSubject<UIImage?>(value: nil)

    // inputs

    // outputs
    var heading: Observable<String> { return headingSubject.asObservable() }
    var details: Observable<String> { return detailsSubject.asObservable() }
    var image: Observable<UIImage?> { return imageSubject.asObservable() }

    init(heading: String, details: String, image: UIImage?) {
        headingSubject.onNext(heading)
        detailsSubject.onNext(details)
        imageSubject.onNext(image)
    }
}
