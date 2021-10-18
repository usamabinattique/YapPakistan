//
//  CaptureViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 14/10/2021.
//

import YAPComponents
import RxSwift
import RxTheme

class CaptureViewController: UIViewController {

    private var themeService: ThemeService<AppTheme>!
    var viewModel: CaptureViewModelType!

    convenience init(themeService: ThemeService<AppTheme>, viewModel: CaptureViewModelType) {
        self.init(nibName: nil, bundle: nil)

        self.themeService = themeService
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
}
