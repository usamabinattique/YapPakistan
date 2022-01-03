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

    // MARK: - Properties
    var viewModel: StoreViewModelType!

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
        view.addSub(view: label)
    }

    func setupConstraints() {
        label.centerInSuperView()
    }
}

// MARK: - Bind
fileprivate extension StoreViewController {
    func bind() {

    }
}

