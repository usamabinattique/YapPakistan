//
//  HideWidgetPopupViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 21/04/2022.
//

import UIKit
import RxSwift
import YAPCore
import YAPComponents
import RxCocoa
import RxTheme
/*
class HideWidgetPopupViewController: UIViewController {
    
    public lazy var sheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public lazy var holder: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public lazy var contentView: HideWidgetPopup = {
        let view = HideWidgetPopup(theme: themeService)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Properties
    public var window: UIWindow?
    public var viewTop: NSLayoutConstraint!
    public var viewModel: HideWidgetPopupViewModel!
    private var themeService: ThemeService<AppTheme>!
    public let disposeBag = DisposeBag()
    public var start: CGFloat = 0
    // MARK: Initialization
    
    public init(viewModel: HideWidgetPopupViewModel, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        bindViews()
        addGestureRecognisers()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.layoutIfNeeded()
        viewTop.constant = -1 * sheetView.bounds.height
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
            self.view.layoutIfNeeded()
        }
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        holder.roundView()
        sheetView.layer.cornerRadius = 18
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.clipsToBounds = true
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.window?.resignKey()
        view.window?.removeFromSuperview()
        window = nil
    }
    
    public func addGestureRecognisers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeAction(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.cancelsTouchesInView = false
        sheetView.addGestureRecognizer(pan)
    }
    
    @objc
    func closeAction() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

}

extension HideWidgetPopupViewController {
    
        func setupViews() {
            view.addSubview(sheetView)
            sheetView.addSubview(holder)
            sheetView.addSubview(contentView)
        }
        
        func setupConstraints() {
        
            sheetView
                .alignEdgesWithSuperview([.left, .right])
                .height(constant: 330)//UIScreen.main.bounds.height*0.59)
            
            holder
                .alignEdgeWithSuperview(.top, constant: 15)
                .height(constant: 4)
                .width(constant: 60)
                .centerHorizontallyInSuperview()
            
            contentView
                .toBottomOf(holder, constant: 15)
                .alignEdgesWithSuperview([.left,.right,.bottom])
                
            
            viewTop = sheetView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
            viewTop.isActive = true
        }
        
    }

extension HideWidgetPopupViewController {
  
    @objc
    public func closeAction(_ tap: UITapGestureRecognizer) {
        guard tap.location(in: view).y < sheetView.frame.origin.y else { return }
        viewModel.cancelObserver.onNext(())
        completeHide(0)
    }
    
    @objc
    public func handlePan(_ pan: UIPanGestureRecognizer) {
        viewModel.cancelObserver.onNext(())
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
    
    func bindViews() {
        contentView.rx.cancel.bind(to: viewModel.cancelObserver).disposed(by: disposeBag)
        contentView.rx.hideWidgets.bind(to: viewModel.hideWidgetObserver).disposed(by: disposeBag)
    }
} */

import UIKit
import YAPCore
import YAPComponents
import RxDataSources
import RxSwift
import RxTheme

class HideWidgetPopupViewController: ListViewController {
    
    // MARK: Views
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15 + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0), right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: Properties
    
    private var viewModel: HideWidgetPopupViewModelType!
    private var tableViewHeight: NSLayoutConstraint!
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    private let disposeBag = DisposeBag()
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    init(_ viewModel: HideWidgetPopupViewModelType, themeService: ThemeService<AppTheme>) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.themeService = themeService
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: View cycle

    override func viewDidLoad() {
        self.__heightMutiplier = 0.35
        super.viewDidLoad()
        self.titleLabel.textAlignment = .center
        listTitle = "Widgets are hidden"
        
        setupViews()
        setupConstraints()
        setupTheme()
        bindViews()
    }
    
    // MARK: KV Observer
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let tableView = object as? UITableView else { return }
        guard self.tableView == tableView else { return }
        
        let targetHeight = self.tableView.contentSize.height + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
        
        guard self.tableView.bounds.height < maxAvailableHeight || targetHeight < maxAvailableHeight else { return }
        
        if !isCompletlyShown {
            self.tableViewHeight.constant = self.tableView.contentSize.height + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            guard let `self` = self else { return }
            self.tableViewHeight.constant = self.tableView.contentSize.height + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
            self.contentHeightChanged()
        }
    }
}

// MARK: View setup

private extension HideWidgetPopupViewController {
    func setupViews() {
        container.addSubview(tableView)
        
        tableView.register(HideWidgetBottomSheetCell.self, forCellReuseIdentifier: HideWidgetBottomSheetCell.defaultIdentifier)
    }
    
    func setupConstraints() {
        tableView
            .alignAllEdgesWithSuperview()
        
        tableViewHeight = tableView.heightAnchor.constraint(lessThanOrEqualToConstant: view.frame.size.height)//200)
        tableViewHeight.isActive = true
    }
    
    func setupTheme() {
        themeService.rx
            //.bind({ UIColor($0.greyLight) }, to: [separator.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark)}, to: [titleLabel.rx.tintColor])
            .disposed(by: rx.disposeBag)



    }
}

// MARK: Binding

private extension HideWidgetPopupViewController {
    func bindViews() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { [unowned self] (_, tableView, _, viewModel) in
           
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxUITableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell
        })
        
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
//        viewModel.outputs.dismiss.subscribe(onNext:{ [weak self] _ in
//            self?.hide()
//
//        }).disposed(by: disposeBag)
        
        //tableView.rx.modelSelected(SMFTPOPCellViewModel.self).map{ $0.reason }.unwrap().bind(to: viewModel.inputs.popSelectedObserver).disposed(by: disposeBag)
//        tableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
}

// MARK: Table view delegate
/*extension HideWidgetPopupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionViewModel = viewModel.outputs.sectionViewModels[section]
        let cell = tableView.dequeueReusableCell(withIdentifier: sectionViewModel.reusableIdentifier) as! RxUITableViewCell
        cell.configure(with: themeService, viewModel: sectionViewModel)
        return cell
    }
} */


import Foundation
import YAPComponents
import RxSwift
import RxTheme
import UIKit

class HideWidgetBottomSheetCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var descriptionLabel =  UIFactory.makeLabel(font: .micro,alignment: .center,numberOfLines: 0)
    
    private lazy var hideWidgetButton = UIFactory.makeAppRoundedButton(with: .large, title: "Hide Widgets") //UIFactory.makeButton(with: .large, backgroundColor: .clear, title: "Hide Widgets")
    private var cancelButton = UIButtonFactory.createButton(title: "Cancel", backgroundColor: .clear)
    
    // MARK: Properties
    var viewModel: HideWidgetBottomSheetCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
        setupViews()
        setupConstraints()
    }
    
    // MARK: View cycle
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
    
    // MARK: Configurations
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? HideWidgetBottomSheetCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
        setupTheme()
        setupResources()
    }
    
}

// MARK: View setup

private extension HideWidgetBottomSheetCell {
    func setupViews() {
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(hideWidgetButton)
        contentView.addSubview(cancelButton)
    }
    
    func setupConstraints() {
        descriptionLabel
            .alignEdgesWithSuperview([.left, .top, .right], constants: [20, 0, 24])
            
        hideWidgetButton
            .height(constant: 52)
            .width(constant: 192)
            .toBottomOf(descriptionLabel,constant: 28)
            .centerHorizontallyInSuperview()
        
        
        cancelButton
            .toBottomOf(hideWidgetButton, constant: 13)
            .width(constant: 192)
            .height(constant: 28)
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.bottom, .greaterThanOrEqualTo, constant: 8)
    }
    
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.greyDark) }, to: [descriptionLabel.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [cancelButton.rx.titleColor(for: .normal), hideWidgetButton.rx.backgroundColor])
//            .bind({ UIColor($0.primaryDark) }, to: [gotItButton.rx.tintColor,gotItButton.rx.titleColor(for: .normal
//                                                                                                      )])
            .disposed(by: rx.disposeBag)
    }
    
    func setupResources() {
       
    }
}

// MARK: Binding

private extension HideWidgetBottomSheetCell {
    func bindViews() {
        viewModel.outputs.description.bind(to: descriptionLabel.rx.text).disposed(by: disposeBag)
        hideWidgetButton.rx.tap.bind(to: viewModel.inputs.gotItObserver).disposed(by: disposeBag)
        cancelButton.rx.tap.bind(to: viewModel.inputs.cancelObserver).disposed(by: disposeBag)

    }
}
