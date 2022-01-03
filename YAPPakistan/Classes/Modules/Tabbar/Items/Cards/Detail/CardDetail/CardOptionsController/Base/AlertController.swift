//
//  AlertAction.swift
//  YAPPakistan
//
//  Created by Sarmad on 08/12/2021.
//

import Foundation
import RxSwift

class AlertController: UIAlertController {
    var viewModel: AlertViewModel!

    convenience init(viewModel: AlertViewModel) {
        self.init(title: viewModel.title, message: viewModel.message, preferredStyle: viewModel.style)
        self.viewModel = viewModel
        setupViews()
    }

    func setupViews() {
        viewModel.actions.enumerated().map{ index, avm in
            UIAlertAction(title: avm.title, style: avm.style) { [weak self] _ in
                self?.viewModel.inputs.tapIndexObserver.onNext(index)
            }
        }.forEach { [weak self] action in self?.addAction(action) }
    }
}
