//
//  YAPActionSheetViewController.swift
//  YAPKit
//
//  Created by Zain on 03/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxTheme
import RxDataSources
import YAPComponents

class YAPActionSheetViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var sheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var holder: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor( themeService.attrs.grey )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = UIFactory.makeLabel(font: .title2, alignment: .center, numberOfLines: 0) //UILabelFactory.createUILabel(with: .primaryBlue0, textStyle: .large, numberOfLines: 0)
    //private lazy var subTitleLabel: UILabel = UIFactory.makeLabel(font: .small, alignment: .left, numberOfLines: 0) //UILabelFactory.createUILabel(with: .secondaryGrey2, textStyle: .small, numberOfLines: 0)
    
    private lazy var titleStack = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 5, arrangedSubviews: [titleLabel])
    
    private lazy var saperator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(themeService.attrs.grey)
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
    
    // MARK: Properties
    private var themeService: ThemeService<AppTheme>!
    var window: UIWindow?
    private var tableViewHeight: NSLayoutConstraint!
    private var viewTop: NSLayoutConstraint!
    private var viewModel: YAPActionSheetViewModelType!
    private var start: CGFloat = 0
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    private let disposeBag = DisposeBag()
    
    // MARK: Initialization
    
    init(themeService: ThemeService<AppTheme>, viewModel: YAPActionSheetViewModelType) {
        super.init(nibName: nil, bundle: nil)
        self.themeService = themeService
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: View cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        setupViews()
        setupTheme()
        setupConstraints()
        addGestureRecognisers()
        bindViews()
        bindTableView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        holder.roundView()
        sheetView.layer.cornerRadius = 18
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableViewHeight.constant = tableView.contentSize.height + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0 )
        view.layoutIfNeeded()
        
        tableView.contentInset = tableView.contentSize.height > tableView.bounds.size.height ? UIEdgeInsets(top: 0, left: 0, bottom: (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0 ), right: 0) : .zero
        
        viewTop.constant = -1 * sheetView.bounds.height
        
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.window?.resignKey()
        view.window?.removeFromSuperview()
        window = nil
    }
    
    // MARK: Gestures
    
    private func addGestureRecognisers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeAction(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.cancelsTouchesInView = false
        sheetView.addGestureRecognizer(pan)
    }
}

// MARK: Actions

private extension YAPActionSheetViewController {
    @objc
    private func closeAction(_ tap: UITapGestureRecognizer) {
        guard tap.location(in: view).y < sheetView.frame.origin.y else { return }
        
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

// MARK: View setup

private extension YAPActionSheetViewController {
    func setupTheme() {
        themeService.rx
            .bind( { UIColor($0.primaryDark) }, to: [titleLabel.rx.textColor])
            //.bind({ UIColor($0.grey) }, to: [subTitleLabel.rx.textColor])
    }
    
    func setupViews() {
        view.backgroundColor = .clear
        
        view.addSubview(sheetView)
        sheetView.addSubview(holder)
        sheetView.addSubview(titleStack)
        sheetView.addSubview(saperator)
        sheetView.addSubview(tableView)
        
        tableView.register(YAPActionSheetTableViewCell.self, forCellReuseIdentifier: YAPActionSheetTableViewCell.defaultIdentifier)
        tableView.register(YAPActionSheetBigIconTableViewCell.self, forCellReuseIdentifier: YAPActionSheetBigIconTableViewCell.defaultIdentifier)
    }
    
    func setupConstraints() {
        sheetView
            .alignEdgesWithSuperview([.left, .right])
            .height(.lessThanOrEqualTo, constant: UIScreen.main.bounds.height*0.88)
        
        holder
            .alignEdgeWithSuperview(.top, constant: 15)
            .height(constant: 4)
            .width(constant: 60)
            .centerHorizontallyInSuperview()
        
        titleStack
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .toBottomOf(holder, constant: 20)
        
        saperator
            .alignEdgesWithSuperview([.left, .right])
            .height(constant: 1)
            .toBottomOf(titleStack, constant: 24)
        
        tableView
            .toBottomOf(saperator)
            .alignEdgesWithSuperview([.left, .right, .bottom])
        
        tableViewHeight = tableView.heightAnchor.constraint(lessThanOrEqualToConstant: 200)
        tableViewHeight.isActive = true
        
        viewTop = sheetView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        viewTop.isActive = true
    }
}

// MARK: Binding

private extension YAPActionSheetViewController {
    func bindViews() {
        viewModel.outputs.title.bind(to: titleLabel.rx.text).disposed(by: disposeBag)
        //viewModel.outputs.subTitle.bind(to: subTitleLabel.rx.text).disposed(by: disposeBag)
        //viewModel.outputs.subTitle.map{ $0 == nil }.bind(to: subTitleLabel.rx.isHidden).disposed(by: disposeBag)
    }
    
    func bindTableView() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { (_, tableView, _, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxUITableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell
        })
        
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        tableView.rx.modelSelected(YAPActionSheetTableViewCellViewModel.self)
            .do(onNext: { [weak self] _ in self?.completeHide(0) })
            .subscribe(onNext: { $0.action.handler($0.action) }).disposed(by: disposeBag)
    }
}

// MARK: Gesture recogniser handling

private extension YAPActionSheetViewController {
    
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
            self.navigationController?.dismiss(animated: false, completion: nil)
        }
    }
}
