//
//  SampleViewController.swift
//  YAPPakistan
//
//  Created by Tayyab on 09/08/2021.
//

import YAPComponents
import UIKit

open class SampleViewController: UIViewController {

    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0)

        let textField = DefaultTextField()
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Default Text Field"

        view.addSubview(textField)

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            view.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 16.0)
        ])
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
