//
//  SelfieCoordinator.swift
//  YAPPakistan
//
//  Created by Sarmad on 13/10/2021.
//

import Foundation
import RxSwift
import YAPCore

class SelfieCoordinator: Coordinator<ResultType<Void>> {
    private let container: KYCFeatureContainer
    private let root: UINavigationController!
    private let result = PublishSubject<ResultType<Void>>()

    init(container: KYCFeatureContainer,
         root: UINavigationController) {
        self.container = container
        self.root = root
        super.init()
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {

        return result
    }
}
