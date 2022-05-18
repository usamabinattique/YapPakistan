//
//  FAQDetails.swift
//  YAPPakistan
//
//  Created by Awais on 18/05/2022.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents
import RxTheme
import RxDataSources

class FAQDetailViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var categoryTitle = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0)
    private lazy var question = UIFactory.makeLabel(font: .large, alignment: .left, numberOfLines: 0)
    private lazy var answer = UIFactory.makeLabel(font: .small, alignment: .left, numberOfLines: 0)
    private lazy var backBarButtonItem = barButtonItem(image: UIImage(named: "icon_back", in: .yapPakistan), insectBy:.zero)
    private lazy var searchBarButtonItem = barButtonItem(image: UIImage(named: "icon_search", in: .yapPakistan), insectBy:.zero)
    
    // MARK: Properties
    
    private var viewModel: FAQDetailViewModelType!
    private let disposeBag = DisposeBag()
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    
    init(viewModel: FAQDetailViewModelType, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "FAQs"
        
        setupViews()
        setupConstraints()
        setupTheme()
        bindViews()
        //addBackButton(.closeEmpty)
    }
    
    // MARK: Actions
    
    // MARK: Actions
    @objc
    private func backAction() {
        //accountAlert.hide()
        //viewModel.inputs.backObserver.onNext(())
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func onTapBackButton() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: View setup

private extension FAQDetailViewController {
    func setupViews() {
        navigationItem.leftBarButtonItem = backBarButtonItem.barItem
        //navigationItem.rightBarButtonItem = searchBarButtonItem.barItem
        view.backgroundColor = .white
        view.addSubview(categoryTitle)
        view.addSubview(question)
        view.addSubview(answer)
    }
    
    func setupConstraints() {
        categoryTitle
            .alignEdgesWithSuperview([.safeAreaTop, .safeAreaLeft], constants: [20,20])
        question
            .alignEdgesWithSuperview([.safeAreaLeft, .safeAreaRight], constants: [20,20])
            .toBottomOf(categoryTitle, constant: 20)
        answer
            .alignEdgesWithSuperview([.safeAreaLeft,.safeAreaRight], constants: [20,20])
            .toBottomOf(question, constant: 10)
    }
    
    func setupTheme() {
        themeService.rx
            .bind( { UIColor($0.greyDark) } , to: [categoryTitle.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [question.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [answer.rx.textColor])
    }
}

private extension FAQDetailViewController {
    func bindViews() {
        searchBarButtonItem.button?.rx.tap.bind(to: viewModel.inputs.searchObserver).disposed(by: disposeBag)
        backBarButtonItem.button?.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: categoryTitle.rx.text).disposed(by: disposeBag)
        viewModel.outputs.question.bind(to: question.rx.text).disposed(by: disposeBag)
        viewModel.outputs.answer.bind(to: answer.rx.text).disposed(by: disposeBag)
    }
}


