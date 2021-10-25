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
    var caputredImage: UIImage!
    private var backButton: UIButton!

    lazy var selfieView = CaptureSelfie.getScanner { image in
        self.caputredImage = image
        self.viewModel.inputs.nextObserver.onNext(image)
        print(image?.size)
        return ()
    }

    convenience init(themeService: ThemeService<AppTheme>, viewModel: CaptureViewModelType) {
        self.init(nibName: nil, bundle: nil)
        self.themeService = themeService
        self.viewModel = viewModel
    }

    override func loadView() {
        view = selfieView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupTheme()
        setupLanguageStrings()
        setupBindings()
        setupConstraints()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selfieView.startSession()
    }

    func setupViews() {
        backButton = addBackButton(of: .backEmpty)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [ selfieView.rx.themeColor ])
            .bind({ UIColor($0.primary) }, to: [ backButton.rx.tintColor ])
            .disposed(by: rx.disposeBag)
    }

    func setupLanguageStrings() {

    }

    func setupBindings() {
        backButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
    }

    func setupConstraints() {

    }
}
