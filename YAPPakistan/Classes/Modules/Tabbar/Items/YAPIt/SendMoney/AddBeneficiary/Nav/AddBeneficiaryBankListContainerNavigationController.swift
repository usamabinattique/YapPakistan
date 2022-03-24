//
//  AddBeneficiaryBankListContainerNavigationController.swift
//  YAPPakistan
//
//  Created by Yasir on 15/03/2022.
//

import UIKit
import YAPComponents
import RxCocoa
import RxSwift
import RxTheme

class AddBeneficiaryBankListContainerNavigationController: UINavigationController {

    var keyboardShown: Bool = false
    fileprivate var themeService: ThemeService<AppTheme>!

    init(themeService: ThemeService<AppTheme>!, rootViewController: UIViewController) {
        self.themeService = themeService
        super.init(rootViewController: rootViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardDidShowNotification)
            .withUnretained(self)
            .subscribe { $0.0.keyboardDidShow($0.1) }
            .disposed(by: rx.disposeBag)

        NotificationCenter.default.rx
            .notification(UIResponder.keyboardDidHideNotification)
            .withUnretained(self)
            .subscribe { $0.0.keyboardDidHide($0.1) }
            .disposed(by: rx.disposeBag)

        setupTheme()

    }

    func setupTheme() {
        view.backgroundColor = .clear
//        themeService.rx
//            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
//            .disposed(by: rx.disposeBag)
    }
}

fileprivate extension AddBeneficiaryBankListContainerNavigationController {

    @objc func keyboardDidShow(_ notification: Notification) {
        keyboardShown = true
    }

    @objc func keyboardDidHide(_ notification: Notification) {
        keyboardShown = false
    }
}
