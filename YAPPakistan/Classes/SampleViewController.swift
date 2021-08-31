//
//  SampleViewController.swift
//  YAPPakistan
//
//  Created by Tayyab on 09/08/2021.
//

import YAPComponents
import UIKit
import RxSwift
import RxTheme

open class SampleViewController: UIViewController {

    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0)
        /*
        //let label = UILabelFactory.createUILabel(with: .grey, textStyle: .title1, fontWeight: .regular, alignment: .center, numberOfLines: 0, lineBreakMode: .byClipping, text: "Label component from component library", alpha: 1, adjustFontSize: true)
        
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            view.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 16.0)
        ]) */
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
