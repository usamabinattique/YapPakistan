//
//  File.swift
//  YAPPakistan
//
//  Created by Yasir on 15/03/2022.
//

import YAPComponents


class AddBeneficiaryBankListContainerChildViewController: UIViewController {

    var firstReponder: UITextField? {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard UIScreen.screenType != .iPhone5 else { return }
        guard (self.navigationController as? OnBoardingContainerNavigationController)?.keyboardShown ?? false else { return }
        _ = firstReponder?.becomeFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard UIScreen.screenType != .iPhone5 else { return }
        guard !((self.navigationController as? OnBoardingContainerNavigationController)?.keyboardShown ?? false) else { return }
        _ = firstReponder?.becomeFirstResponder()
    }
}
