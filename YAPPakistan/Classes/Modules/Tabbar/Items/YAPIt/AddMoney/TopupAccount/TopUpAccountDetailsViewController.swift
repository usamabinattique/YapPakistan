//
//  TopUpAccountDetailsViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 29/03/2022.
//

import UIKit
import YAPComponents
import RxSwift
import RxDataSources
import RxTheme

class TopUpAccountDetailsViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var shareButton: UIButton = UIFactory.makeButton(with: .large, title: "screen_more_bank_details_button_share".localized)
    //private lazy var shareIcon: ImageView = UIFactory.makeImageView()
    private lazy var shareStack: UIStackView = UIFactory.makeStackView(axis: .horizontal, alignment: .center, distribution: .fill, spacing: 5, arrangedSubviews: [shareButton])
    
    private var backButton: UIButton!
    
    // MARK: Properties
    
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    private var viewModel: TopUpAccountDetailsViewModelType!
    private var themeService: ThemeService<AppTheme>!
    private let disposeBag = DisposeBag()
    
    // MARK: Initialization
    
    init(with viewModel: TopUpAccountDetailsViewModelType, themeService: ThemeService<AppTheme>) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.themeService = themeService
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: View cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton = makeAndAddBackButton(of:.backEmpty)
        title = "screen_more_bank_details_display_text_for_top_up_title".localized
        
        setupSubViews()
        setupConstraints()
        setupBindings()
        setupTheme()
        setupResources()
    }
    
    // MARK: Actions
    
    override public func onTapBackButton() {
        viewModel.inputs.closeObserver.onNext(())
    }
    
}

// MARK: View setup

extension TopUpAccountDetailsViewController: ViewDesignable {
    
    func setupSubViews() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(shareStack)
        
        tableView.register(TopUpAccountDetailsCell.self, forCellReuseIdentifier: TopUpAccountDetailsCell.defaultIdentifier)
        tableView.register(TopUpAccountDetailsUserCell.self, forCellReuseIdentifier: TopUpAccountDetailsUserCell.defaultIdentifier)
    }
    
    func setupConstraints() {
        let bottomSafeArea: CGFloat = (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) == 0 ? 18 : 0
        tableView
            .alignEdgeWithSuperviewSafeArea(.top)
            .alignEdgesWithSuperview([.left, .right], constants: [0, 0])

        shareStack
            .toBottomOf(tableView)
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: bottomSafeArea)
            .height(constant: 52)
            .width(constant: 192)
    }
    
    func setupTheme() {
        self.themeService.rx
            .bind({ UIColor($0.primary) }, to: shareButton.rx.titleColor(for: .normal))
            .bind({ UIColor($0.primaryDark) }, to: backButton.rx.tintColor)
            .disposed(by: disposeBag)
    }
    
    func setupBindings() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { [unowned self] (_, tableView, _, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxUITableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell
        })
        
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        viewModel.outputs.shareInfo.subscribe(onNext: { [weak self] text in
            guard let `self` = self else { return }
            
            let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            self.present(activityViewController, animated: true, completion: nil)
            activityViewController.completionWithItemsHandler = { _, _, _, _ in
                
            }
        }).disposed(by: disposeBag)
        
        shareButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.inputs.shareObserver.onNext("")
            })
            .disposed(by: disposeBag)
    }
    
    func setupResources() {
        if let img = UIImage(named: "icon_share", in: .yapPakistan) {
            self.shareButton.addRightIcon(image: img, tintColor: UIColor(self.themeService.attrs.primary))
        }
        
        //shareIcon.image = UIImage(named: "icon_share", in: .yapPakistan)
    }
}
