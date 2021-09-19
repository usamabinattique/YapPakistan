//
//  WelcomePageChildViewController.swift
//  YAP
//
//  Created by Zain on 19/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit

import YAPComponents
import RxSwift
import RxCocoa
class WelcomePageChildViewController: UIViewController {

    // MARK: Views

    fileprivate lazy var heading: UILabel = {
        let label = UILabel()
        label.font = UIFont.title2
        label.textAlignment = .center
        label.textColor = .blue // UIColor.appColor(ofType: .primaryDark)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    fileprivate lazy var details: UILabel = {
        let label = UILabel()
        label.font = UIFont.title3
        label.textAlignment = .center
        label.textColor = .gray // UIColor.appColor(ofType: .greyDark)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    fileprivate lazy var image: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    // MARK: Properties

    fileprivate var viewModel: WelcomePageChildViewModelType!
    private var headingCenter: NSLayoutConstraint!
    private var detailsCenter: NSLayoutConstraint!
    private var loaded: Bool = false

    private var headingCenterConstant: CGFloat = 0
    private var detailsCenterConstant: CGFloat = 0
    private var pageIndex: Int!
    private var currentPage: Int = 0
    private var isFirstTime: Bool = true

    // MARK: Initializaiton

    init(viewModel: WelcomePageChildViewModelType, index: Int) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.pageIndex = index
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: View cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        loaded = true
        setupViews()
        setupConstraints()
        bindViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutSubviews()

        if isFirstTime, pageIndex == 0 {
            isFirstTime = false
            return
        }

        preparePush()
        completeAnimation()
    }

    // MARK: Property accessors/setters

    func setCurrentPage(_ currentPage: Int) {
        self.currentPage = currentPage
    }
}

// MARK: View setup

extension WelcomePageChildViewController {
    fileprivate func setupViews() {
        view.backgroundColor = .white

        view.addSubview(heading)
        view.addSubview(details)
        view.addSubview(image)
    }

    fileprivate func setupConstraints() {

        heading
            .alignEdgeWithSuperviewSafeArea(.top, constant: 50)

        details
            .toBottomOf(heading, constant: 15)

        image
            .width(constant: UIScreen.main.bounds.width - 50)
            .centerHorizontallyInSuperview()
            .toBottomOf(details, .lessThanOrEqualTo, constant: 80)
            .toBottomOf(details, .greaterThanOrEqualTo, constant: 30)
            .alignEdgeWithSuperview(.bottom)

        heading.setContentHuggingPriority(.required, for: .vertical)
        details.setContentHuggingPriority(.required, for: .vertical)
        heading.setContentCompressionResistancePriority(.required, for: .vertical)
        details.setContentCompressionResistancePriority(.required, for: .vertical)
        image.setContentHuggingPriority(.defaultHigh, for: .vertical)
        image.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        headingCenter = heading.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: headingCenterConstant)
        headingCenter.isActive = true

        detailsCenter = details.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: detailsCenterConstant)
        detailsCenter.isActive = true

    }
}

// MARK: Binding

extension WelcomePageChildViewController {

    fileprivate func bindViews() {
        viewModel.outputs.heading.bind(to: heading.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.details.bind(to: details.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.image.bind(to: image.rx.image).disposed(by: rx.disposeBag)
    }
}

// MARK: Animations

extension WelcomePageChildViewController {

    func preparePush() {
        let multiplier: CGFloat = currentPage > pageIndex ? -1 : 1
        if loaded {
            headingCenter.constant = 300 * multiplier
            detailsCenter.constant = 150 * multiplier
            view.layoutSubviews()
        } else {
            headingCenterConstant = 300 * multiplier
            detailsCenterConstant = 150 * multiplier
        }

    }

    func animatePop(_ completion: @escaping(() -> Void)) {
        self.headingCenter.constant = -300
        self.detailsCenter.constant = -150
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { completion() }
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutSubviews()
        })
    }

    func completeAnimation() {
        self.headingCenter.constant = 0
        self.detailsCenter.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutSubviews()
        }
    }
}
