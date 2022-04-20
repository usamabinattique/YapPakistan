//
//  WidgetSelectionViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 20/04/2022.
//

import UIKit
import RxSwift
import RxCocoa
import YAPCore
import YAPComponents
import RxTheme

class WidgetSelectionViewController: UIViewController {

    // MARK: - Views
    public lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isEditing = true
        return tableView
    }()
    
    let viewModel: WidgetSelectionViewModel!
    private let disposeBag = DisposeBag()
    private let themeService: ThemeService<AppTheme>
    
//    init(viewModel: WidgetSelectionViewModel) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(themeService: ThemeService<AppTheme>, viewModel: WidgetSelectionViewModel) {
        super.init(nibName: nil, bundle: nil)

        self.themeService = themeService
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        tableView.register(WidgetSelectionSectionTableViewCell.self, forCellReuseIdentifier: WidgetSelectionSectionTableViewCell.reuseIdentifier)
        
        tableView.register(WidgetsTableViewCell.self, forCellReuseIdentifier: WidgetsTableViewCell.reuseIdentifier)
        
        tableView.register(HiddenWidgetsTableViewCell.self, forCellReuseIdentifier: HiddenWidgetsTableViewCell.reuseIdentifier)
        
        addBackButton(of: .backEmpty)
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.viewDidAppearObserver.onNext(())
    }
    
    override func onTapBackButton() {
        viewModel.backObserver.onNext(())
    }
    
    func setupViews()  {
        view.addSubview(tableView)
        addConstraints()
        bind()
    }

}

extension WidgetSelectionViewController {
    
    func addConstraints() {
        tableView.alignEdgesWithSuperview([.left, .right, .top,.bottom], constant: 0)
    }
    
    func bind(){
        viewModel.topHeading.bind(to: navigationItem.rx.title).disposed(by: disposeBag)
        viewModel.reload.subscribe(onNext: { [weak self] in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.showLoader.subscribe(onNext: {
            ($0 ?? true) ? YAPProgressHud.showProgressHud() : YAPProgressHud.hideProgressHud()
        }).disposed(by: disposeBag)
    }
}


extension WidgetSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: WidgetSelectionSectionTableViewCell.reuseIdentifier) as! WidgetSelectionSectionTableViewCell
        cell.configure(with: viewModel.sectionViewModel(for: section))
        return cell
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 0) ? 90 : 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.cellViewModel(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.reusableIdentifier) as! RxUITableViewCell
        cell.configure(with: cellViewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 ? true : false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.swap.onNext((sourceIndexPath, destinationIndexPath))
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "") {[weak self] (action, view, completion) in
            self?.viewModel.hideCellObserver.onNext(indexPath.row)
            completion(true)
        }
        if #available(iOS 13.0, *) {
            deleteAction.image = UIImage.init(named: "icon_hide", in: yapBundle, with: nil)
        }
        deleteAction.backgroundColor = UIColor.appColor(ofType: .primary)
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
