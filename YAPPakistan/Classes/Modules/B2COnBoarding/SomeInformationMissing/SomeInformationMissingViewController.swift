//
//  SomeInformationMissing.swift
//  YAPPakistan
//
//  Created by Yasir on 09/02/2022.
//

import Foundation
import UIKit
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme

class SomeInformationMissingViewController: UIViewController {

    // MARK: Views

    private lazy var heading: UILabel = {
        let label = UIFactory.makeLabel(font: .title2,alignment: .center,  numberOfLines: 0, lineBreakMode: .byWordWrapping)
        return label
    }()

    private lazy var message: UILabel = {
        let label = UIFactory.makeLabel(font: .micro,alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)
        return label
    }()

    private lazy var cardImage = UIFactory
        .makeImageView(contentMode: .scaleAspectFit)
    
    private lazy var goToDashboardButton = UIFactory.makeAppRoundedButton(with: .large, title: "screen_y2y_funds_transfer_success_button_back".localized)

    // MARK: Properties

    fileprivate var viewModel: SomeInformationMissingViewModelType!
    fileprivate var themeService: ThemeService<AppTheme>!

    // MARK: Initialization

    init(themeService: ThemeService<AppTheme>, viewModel: SomeInformationMissingViewModelType!) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: View cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupTheme()
        setupConstraints()
        bind()
    }
}

// MARK: View setup

fileprivate extension SomeInformationMissingViewController {

    func setupViews() {
        view.addSubview(heading)
        view.addSubview(cardImage)
        view.addSubview(message)
        view.addSubview(goToDashboardButton)

        view.backgroundColor = .white
        cardImage.image = UIImage(named: "missing_information", in: .yapPakistan)
    }
    
    private func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: heading.rx.textColor)
            .bind({ UIColor($0.primary) }, to: goToDashboardButton.rx.backgroundColor)
            .bind({ UIColor($0.greyDark) }, to: message.rx.textColor)
            .disposed(by: rx.disposeBag)
    }

    func setupConstraints() {
        heading
            .alignEdgesWithSuperview([.left, .top, .right], constants: [34, 94, 34])

        cardImage
            .toBottomOf(heading,constant: 44)
            .alignEdgesWithSuperview([.left, .right], constants: [0,  0])
            .centerHorizontallyInSuperview()

        message
            .alignEdgesWithSuperview([.left, .right], constants: [34, 34])
            .toBottomOf(cardImage, constant: 32)
            .toTopOf(goToDashboardButton,.greaterThanOrEqualTo,constant: 20)
        
        goToDashboardButton
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 32)
            .height(constant: 52)
            .width(constant: 230)
    }
}

// MARK: Binding

private extension SomeInformationMissingViewController {

    func bind() {
        viewModel.outputs.heading.bind(to: heading.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.subHeading.bind(to: message.rx.text).disposed(by: rx.disposeBag)
        goToDashboardButton.rx.tap.bind(to: viewModel.inputs.goToDashboardObserver).disposed(by: rx.disposeBag)
    }
}
