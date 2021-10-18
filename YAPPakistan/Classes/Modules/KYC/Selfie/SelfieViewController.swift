//
//  SelfieViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 07/10/2021.
//

import UIKit
import YAPComponents

class SelfieViewController: UIViewController {

    let label = UIFactory.makeLabel(font: .title3, alignment: .center, numberOfLines: 1, text: "SELFIE PENDING")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(label)

        label.textColor = .darkText

        label.centerHorizontallyInSuperview()
        label.centerVerticallyInSuperview()

    }

}
