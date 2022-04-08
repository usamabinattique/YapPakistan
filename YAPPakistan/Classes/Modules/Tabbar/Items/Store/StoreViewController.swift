//
//  StoreViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import RxSwift
import YAPComponents

class StoreViewController: UIViewController {

    let label = UIFactory.makeLabel(text: "Store")
    private lazy var completeVerificationButton = UIFactory.makeAppRoundedButton(with: .large, title: "Complete verification")

    // MARK: - Properties
    var viewModel: StoreViewModelType!
    private let disposeBag = DisposeBag()

    // MARK: - Init
    convenience init(viewModel: StoreViewModelType) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        bind()
    }
}

// MARK: - Setup
fileprivate extension StoreViewController {
    func setup() {
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        view.backgroundColor = .white
        completeVerificationButton.backgroundColor = UIColor(Color(hex: "#5E35B1"))
        view.addSub(view: label)
        view.addSub(view: completeVerificationButton)
    }

    func setupConstraints() {
        label.centerInSuperView()
        
        completeVerificationButton
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 20)
            .centerHorizontallyInSuperview()
            .height(constant: 52)
            .width(constant: 250)
    }
}

// MARK: - Bind
fileprivate extension StoreViewController {
    func bind() {
        viewModel.outputs.completeVerificationHidden
            .bind(to: completeVerificationButton.rx.isHidden)
            .disposed(by: disposeBag)

        completeVerificationButton.rx.tap
            .bind(to: viewModel.inputs.completeVerificationObserver)
            .disposed(by: disposeBag)
    }
}

