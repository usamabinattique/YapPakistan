//
//  YAPItViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/11/2021.
//

import RxSwift
import YAPComponents

class YAPItViewController: UIViewController {

    let label = UIFactory.makeLabel(text: "YAP it")

    // MARK: - Properties
    var viewModel: YAPItViewModelType!

    // MARK: - Init
    convenience init(viewModel: YAPItViewModelType) {
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
fileprivate extension YAPItViewController {
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
fileprivate extension YAPItViewController {
    func bind() {

    }
}

