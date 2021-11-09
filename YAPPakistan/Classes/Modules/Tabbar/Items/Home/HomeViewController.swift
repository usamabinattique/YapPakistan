//
//  HomeViewController.swift
//  YAP
//
//  Created by Muhammad Hassan on 29/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import RxSwift
import YAPComponents

class HomeViewController: UIViewController {

    let label = UIFactory.makeLabel(text: "Home")

    // MARK: - Properties
    var viewModel: HomeViewModelType!

    // MARK: - Init
    convenience init(viewModel: HomeViewModelType) {
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
fileprivate extension HomeViewController {
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
fileprivate extension HomeViewController {
    func bind() {

    }
}
