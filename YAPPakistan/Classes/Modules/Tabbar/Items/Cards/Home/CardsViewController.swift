//
//  CardsViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import RxSwift
import YAPComponents

class CardsViewController: UIViewController {

    let label = UIFactory.makeLabel(text: "Cards")

    // MARK: - Properties
    var viewModel: CardsViewModelType!

    // MARK: - Init
    convenience init(viewModel: CardsViewModelType) {
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
fileprivate extension CardsViewController {
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
fileprivate extension CardsViewController {
    func bind() {

    }
}

