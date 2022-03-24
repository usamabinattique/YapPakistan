//
//  SearchableActionSheetViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 14/03/2022.
//

import UIKit
import RxSwift
import RxDataSources
import YAPComponents
import RxTheme

class SearchableActionSheetViewController: UIViewController {
    
    // MARK: - Views
    
    private lazy var sheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var holder: UIView = {
        let view = UIView()
       // view.backgroundColor = .greyLight
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = UIFactory.makeLabel(font: .large, numberOfLines: 0) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .large, numberOfLines: 0)
    
    private lazy var searchBar: UITextField = {
        let textfield = UITextField()
        textfield.borderStyle = .none
        textfield.font = .small
        textfield.placeholder = "Search"
        textfield.translatesAutoresizingMaskIntoConstraints = false
        return textfield
    }()
    
    private lazy var searchIcon = UIFactory.makeImageView(contentMode: .scaleAspectFit) //UIImageViewFactory.createImageView(mode: .scaleAspectFit, image: UIImage.sharedImage(named: "icon_search"), tintColor: .greyDark)
    
    private lazy var searchStack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 7, arrangedSubviews: [searchIcon, searchBar])
    
    private lazy var searchView: UIView = {
        let view = UIView()
     //   view.backgroundColor = UIColor.greyLight.withAlphaComponent(0.36)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var saperator: UIView = {
        let view = UIView()
    //    view.backgroundColor = .greyLight
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Properties
    
    private var start: CGFloat = 0
    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    private var viewModel: SearchableActionSheetViewModelType!
    var window: UIWindow?
    var tableViewBottom: NSLayoutConstraint!
    private var themeService: ThemeService<AppTheme>
    
    // MARK: - Initialization
    
    init(themeService: ThemeService<AppTheme> ,_ viewModel: SearchableActionSheetViewModelType) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        bindViews(viewModel)
        addGestureRecognisers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        holder.roundView()
        sheetView.layer.cornerRadius = 18
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.clipsToBounds = true
        searchView.roundView()
        
        sheetView.frame = CGRect(x: sheetView.frame.origin.x, y: view.bounds.height, width: sheetView.bounds.width, height: sheetView.bounds.height)
        
        completeShow(0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.window?.resignKey()
        view.window?.removeFromSuperview()
        window = nil
    }
    
    // MARK: - Gestures
    
    private func addGestureRecognisers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeAction(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.cancelsTouchesInView = false
        sheetView.addGestureRecognizer(pan)
    }

}

// MARK: - View setup

private extension SearchableActionSheetViewController {
    func setupViews() {
        
        view.addSubview(sheetView)
        sheetView.addSubview(holder)
        sheetView.addSubview(titleLabel)
        sheetView.addSubview(searchView)
        searchView.addSubview(searchStack)
        sheetView.addSubview(saperator)
        sheetView.addSubview(tableView)
        
        tableView.register(SearchableActionSheetTableViewCell.self, forCellReuseIdentifier: SearchableActionSheetTableViewCell.defaultIdentifier)
    }
    
    func setupConstraints() {
        
        sheetView
            .alignEdgesWithSuperview([.left, .right])
            .height(constant: UIScreen.main.bounds.height*0.88)
            .alignEdgeWithSuperview(.bottom, .lessThanOrEqualTo, constant: 0)
        
        holder
            .alignEdgeWithSuperview(.top, constant: 15)
            .height(constant: 4)
            .width(constant: 60)
            .centerHorizontallyInSuperview()
        
        titleLabel
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .toBottomOf(holder, constant: 20)
        
        searchView
            .height(constant: 30)
            .toBottomOf(titleLabel, constant: 13)
            .alignEdgesWithSuperview([.left, .right], constant: 25)
        
        searchStack
            .alignEdgesWithSuperview([.left, .right], constant: 15)
            .alignEdgesWithSuperview([.top, .bottom])
        
        searchIcon
            .height(constant: 18)
            .width(constant: 18)
        
        saperator
            .toBottomOf(searchView, constant: 25)
            .alignEdgesWithSuperview([.left, .right])
            .height(constant: 1)
        
        
        tableView
            .toBottomOf(saperator)
            .alignEdgesWithSuperview([.left, .right])
        
        tableViewBottom = sheetView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
        tableViewBottom.isActive = true
    }
}

// MARK: - Bind view

private extension SearchableActionSheetViewController {
    func bindViews(_ viewModel: SearchableActionSheetViewModelType) {
        viewModel.outputs.title.bind(to: titleLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.searchPlaceholder.subscribe(onNext: { [weak self] in
            self?.searchBar.placeholder = $0
        }).disposed(by: disposeBag)
        
        searchBar.rx.text.bind(to: viewModel.inputs.searchTextObserver).disposed(by: disposeBag)
        
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { [unowned self] (_, tableView, _, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! ConfigurableTableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell as! UITableViewCell
        })
        
        viewModel.outputs.sectionModels.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        tableView.rx.modelSelected(SearchableActionSheetTableViewCellViewModel.self).map{ $0.index }
            .subscribe(onNext: { [weak self] in
                self?.viewModel.inputs.itemSelectedObserver.onNext($0)
                self?.viewModel.inputs.itemSelectedObserver.onCompleted()
                self?.completeHide(0)
            }).disposed(by: disposeBag)
    }
}

// MARK: - Actions

private extension SearchableActionSheetViewController {
    @objc
    private func closeAction(_ tap: UITapGestureRecognizer) {
        guard tap.location(in: view).y < sheetView.frame.origin.y else { return }
        viewModel.inputs.closeObserver.onNext(())
        completeHide(0)
    }
    
    @objc
    private func handlePan(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            start = pan.location(in: sheetView).y
            
        case .changed:
            changePosition(pan.location(in: view).y - start)
            
        case .ended:
            let progress = ((sheetView.frame.origin.y - (view.bounds.height - sheetView.bounds.height)) / sheetView.bounds.height)
            let velocity = pan.velocity(in: view).y
            if progress < 0.25 {
                velocity < 900 ? completeShow(velocity) : completeHide(velocity)
            } else {
                velocity > -900 ? completeHide(velocity) : completeShow(velocity)
            }
            
        default:
            break
        }
    }
}

// MARK: - Gesture recogniser handling

private extension SearchableActionSheetViewController {
    
    func changePosition(_ y: CGFloat) {
        guard y >= (view.bounds.height - sheetView.bounds.height) else { return }
        var frame = sheetView.frame
        frame.origin.y = y
        sheetView.frame = frame
        let progress = ((sheetView.frame.origin.y - (view.bounds.height - sheetView.bounds.height)) / sheetView.bounds.height)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5 * (1 - progress))
    }
    
    func completeShow(_ velocity: CGFloat) {
        let distance = sheetView.frame.origin.y - (view.bounds.height - sheetView.bounds.height)
        
        var time: TimeInterval = abs(velocity) > 0 ? TimeInterval(abs(distance)/abs(velocity)) : 0.25
        time = time > 0.25 ? 0.25 : time
        
        UIView.animate(withDuration: time) {
            self.sheetView.frame.origin.y = self.view.bounds.height - self.sheetView.bounds.height
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    
    func completeHide(_ velocity: CGFloat) {
        let distance = view.bounds.height - sheetView.frame.origin.y
        
        var time: TimeInterval = abs(velocity) > 0 ? TimeInterval(abs(distance)/abs(velocity)) : 0.25
        time = time > 0.25 ? 0.25 : time
        
        UIView.animate(withDuration: time, animations: {
            self.sheetView.frame.origin.y = self.view.bounds.height
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        }) { (completed) in
            guard completed else { return }
            self.sheetView.isHidden = true
            self.navigationController?.dismiss(animated: false, completion: nil)
        }
    }
}

// MARK: - Keyboard handling

private extension SearchableActionSheetViewController {

    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableViewBottom.constant = keyboardSize.height
            UIView.animate(withDuration: 0.25) { [unowned self] in
                self.view.layoutSubviews()
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        tableViewBottom.constant = 0
        UIView.animate(withDuration: 0.25) { [unowned self] in
            self.view.layoutSubviews()
        }
    }
}
