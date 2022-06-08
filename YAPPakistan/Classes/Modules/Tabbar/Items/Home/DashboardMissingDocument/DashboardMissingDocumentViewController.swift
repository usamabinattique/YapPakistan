//
//  DashboardMissingDocumentViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 08/06/2022.
//

import UIKit
import RxSwift
import YAPComponents
import RxCocoa
import RxTheme

final class DashboardMissingDocumentViewController: UIViewController {
    
    // MARK: - Views
    private lazy var bgImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.init(named: "missing_document_bg", in: .yapPakistan)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var screenTitle = UIFactory.makeLabel(font: .title2, alignment: .center, text: "screen_dashboard_missing_document_title_display_text".localized)
    
    lazy var heading: UILabel = {
        let label = UILabel()
        label.text = "screen_dashboard_missing_document_description_display_text".localized
        label.font = .regular
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var briefStack = UIStackViewFactory
        .createStackView(with: .vertical,
                         alignment: .center,
                         distribution: .fill,
                         spacing: 8,
                         arrangedSubviews: [screenTitle,heading])
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
   /* private lazy var bottomStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }() */
    
    private lazy var getStartedButton: AppRoundedButton = {
        let button = AppRoundedButton()
        button.title = "screen_welcome_button_get_started".localized
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    private lazy var doItLaterButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.titleLabel?.font = .large
        button.setTitle("screen_kyc_setpinintro_doitlater".localized, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var bottomStack = UIStackViewFactory
        .createStackView(with: .vertical,
                         alignment: .center,
                         distribution: .fill,
                         spacing: 20,
                         arrangedSubviews: [getStartedButton,doItLaterButton])
    
    // MARK: - Properties
    let viewModel: DashboardMissingDocumentViewModelType
    let themeService: ThemeService<AppTheme>
    let disposeBag: DisposeBag
    
    // MARK: - Init
    init(viewModel: DashboardMissingDocumentViewModelType, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = screenTitle
        
        setupSubViews()
        setupConstraints()
        setupBindings()
        setupTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.inputs.viewDidAppearObserver.onNext(())
    }
}

// MARK: - Setup
extension DashboardMissingDocumentViewController: ViewDesignable {
    
    func setupSubViews(){
        view.addSubview(bgImage)
        view.addSubview(briefStack)
        view.addSubview(tableView)
        view.addSubview(bottomStack)
      //  tableView.register(StorePackageTableViewCell.self, forCellReuseIdentifier: StorePackageTableViewCell.defaultIdentifier)
        
    }
    
    func setupConstraints(){
        
        bgImage
            .alignEdgesWithSuperview([.top,.right,.left])
            .height(constant: 200)
        
        briefStack
            .toBottomOf(bgImage,constant: 8)
            .alignEdgesWithSuperview([.left,.right], constants: [24,24])
        
        tableView
            .toBottomOf(briefStack)
            .alignEdgesWithSuperview([.left,.right])
            .toTopOf(bottomStack,constant: 12)
        
        bottomStack
            .alignEdgesWithSuperview([.left, .right], constants: [24, 24])
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 16)

        getStartedButton
            .width(constant: 190)
            .height(constant: 52)

        doItLaterButton
            .height(constant: 30)
        
        tableView.contentInset = UIEdgeInsets(top: 20, left: 24, bottom: 0, right: 24)
    }
    
    func setupBindings(){
        doItLaterButton.rx.tap.bind(to: viewModel.inputs.doItLaterObserver).disposed(by: disposeBag)
    }
    
    func setupTheme(){
        self.themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor])
            .bind({ UIColor($0.primaryDiffuse) }, to: [ tableView.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark) }, to: [ screenTitle.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [heading.rx.textColor])
            .bind({ UIColor($0.primary) }, to: getStartedButton.rx.enabledBackgroundColor)
            .bind({ UIColor($0.greyDark) }, to: getStartedButton.rx.disabledBackgroundColor)
            .bind({ UIColor($0.primary) }, to: doItLaterButton.rx.titleColor(for: .normal))
            .disposed(by: disposeBag)
    }
}

