//
//  OnBoardingWaitingListViewController.swift
//  OnBoarding
//
//  Created by Zain on 04/08/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import UIKit
import YAPComponents
import RxSwift
import RxCocoa

class OnBoardingWaitingListViewController: UIViewController {

    // MARK: Views

    private lazy var heading: UILabel = {
        let label = UIFactory.makeLabel(alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)
        label.textColor = .blue // with: .primaryDark,
                                // textStyle: .title2
        return label
    }()

    private lazy var subHeading: UILabel = {
        let label = UIFactory.makeLabel(alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)
        label.textColor = .darkGray // with: .greyDark,
                                    // textStyle: .regular,
        return label
    }()

    private lazy var cardImage = UIFactory
        .makeImageView(contentMode: .scaleAspectFit)
    // createBackgroundImageView(mode: .scaleAspectFit)

    private lazy var keepMePostedButton = AppRoundedButtonFactory.createAppRoundedButton(title: "screen_waiting_list_dispaly_button_keep_me_posted".localized)

    // MARK: Properties

    private var viewModel: OnBoardingWaitingListViewModelType!

    // MARK: Initialization

    init(viewModel: OnBoardingWaitingListViewModelType) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: View cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupConstraints()
        bind()
    }
}

// MARK: View setup

private extension OnBoardingWaitingListViewController {

    func setupViews() {
        view.addSubview(heading)
        view.addSubview(subHeading)
        view.addSubview(cardImage)
        view.addSubview(keepMePostedButton)

        view.backgroundColor = .white
        cardImage.image = UIImage.sharedImage(named: "image_spare_card")
    }

    func setupConstraints() {
        heading
            .alignEdgesWithSuperview([.left, .top, .right], constants: [25, 30, 25])

        subHeading
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
            .toBottomOf(heading, constant: 20)

        cardImage
            .toBottomOf(subHeading, .greaterThanOrEqualTo, constant: 20)
            .toBottomOf(subHeading, .lessThanOrEqualTo, constant: 40)
            .centerHorizontallyInSuperview()
            .toTopOf(keepMePostedButton, .greaterThanOrEqualTo, constant: 20)
            .toTopOf(keepMePostedButton, .lessThanOrEqualTo, constant: 80)

        keepMePostedButton
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 15)
            .height(constant: 52)
            .width(constant: 290)
    }
}

// MARK: Binding

private extension OnBoardingWaitingListViewController {

    func bind() {

        viewModel.outputs.heading.bind(to: heading.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.subHeading.bind(to: subHeading.rx.text).disposed(by: rx.disposeBag)
        keepMePostedButton.rx.tap.bind(to: viewModel.inputs.keepMePostedObserver).disposed(by: rx.disposeBag)
    }
}
