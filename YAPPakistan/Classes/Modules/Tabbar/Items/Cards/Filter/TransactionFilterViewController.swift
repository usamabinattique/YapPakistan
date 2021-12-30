//
//  TransactionFilterViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 22/12/2021.
//

import Foundation
import YAPComponents
import RxTheme
import RxSwift
import RxCocoa
import RxDataSources


public class TransactionFilterViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    private lazy var topSeparator = UIFactory.makeView()
    
    private lazy var separator = UIFactory.makeView()
    
    
    private lazy var applyButton = UIFactory.makeAppRoundedButton(with: .regular, title: "screen_transaction_filter_display_apply_button_title".localized)
    private lazy var clearButton = UIFactory.makeAppRoundedButton(with: .regular, title: "screen_transaction_filter_display_clear_button_title".localized)
    
    // MARK: Properties
    let themeService: ThemeService<AppTheme>
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    private var viewModel: TransactionFilterViewModelType!
    
    // MARK: Initialization
    init(viewModel: TransactionFilterViewModelType, themeService: ThemeService<AppTheme>) {
        
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubViews()
        setupResources()
        setupTheme()
        setupLocalizedStrings()
        setupBindings()
        bindTableView()
        setupConstraints()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        navigationItem.title = "screen_transaction_filter_display_text_title".localized
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_close",in: .yapPakistan), style: .plain, target: self, action: #selector(onTapBackButton))
    }
    
    override public func onTapBackButton() {
        navigationController?.dismiss(animated: true, completion: nil)
        viewModel.inputs.closeObserver.onNext(())
    }
}

// MARK: View setup

private extension TransactionFilterViewController {
    func setupSubViews() {
        view.backgroundColor = .white
        
        view.addSubview(topSeparator)
        view.addSubview(tableView)
        view.addSubview(separator)
        view.addSubview(clearButton)
        view.addSubview(applyButton)
        
        clearButton.backgroundColor = .clear
        
        tableView.register(TransactionFilterCheckBoxCell.self, forCellReuseIdentifier: TransactionFilterCheckBoxCell.defaultIdentifier)
        tableView.register(TransactionFilterSliderCell.self, forCellReuseIdentifier: TransactionFilterSliderCell.defaultIdentifier)
    }
    
    func setupResources() {
        //        let biomImgName: String = (BiometryType.faceID == BiometricsManager().deviceBiometryType) ?
        //                "icon_face_id": "icon_touch_id"
        //        let bioMImg = UIImage(named: biomImgName, in: .yapPakistan)
        //        let backImg = UIImage(named: "icon_delete_purple", in: .yapPakistan)
        //
        //        pinKeyboard.biomatryButton.setImage(bioMImg?.asTemplate, for: .normal)
        //        pinKeyboard.backButton.setImage(backImg?.asTemplate, for: .normal)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
        
            .bind({ UIColor($0.primary        ) }, to: [applyButton.rx.enabledBackgroundColor])
            .bind({ UIColor($0.backgroundColor) }, to: [clearButton.rx.enabledBackgroundColor])
            .bind({ UIColor($0.primary) }, to: [clearButton.rx.titleColor(for: .normal)])
        
            .bind({ UIColor($0.greyLight) }, to: [separator.rx.backgroundColor])
        
            .bind({ UIColor($0.greyLight) }, to: [topSeparator.rx.backgroundColor])
        
            .disposed(by: rx.disposeBag)
    }
    
    func setupLocalizedStrings() {
//        viewModel.outputs.localizedText.withUnretained(self).subscribe { `self`, string in
//            self.headingLabel.text = string.heading
//            self.signinButton.setTitle(string.signIn, for: .normal)
//            self.forgotButton.setTitle(string.forgot, for: .normal)
//        }.disposed(by: rx.disposeBag)
    }
    
    func setupConstraints() {
        
        topSeparator
            .alignEdgesWithSuperview([.left, .safeAreaTop, .right])
            .height(constant: 1)
        
        tableView
            .toBottomOf(topSeparator)
            .alignEdgesWithSuperview([.left, .right])
        
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
        
        separator
            .alignEdgesWithSuperview([.left, .right])
            .toBottomOf(tableView)
            .height(constant: 1)
            .toTopOf(clearButton, constant: 15)
        
        clearButton
            .alignEdgesWithSuperview([.left, .safeAreaBottom], constants: [25, 15])
            .width(constant: 150)
            .height(constant: 42)
        
        applyButton
            .alignEdgeWithSuperview(.right, constant: 25)
            .alignEdge(.centerY, withView: clearButton)
            .width(with: .width, ofView: clearButton)
            .height(with: .height, ofView: clearButton)
        
    }
}

// MARK: Binding

private extension TransactionFilterViewController {
    func bindTableView() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { [weak self] (_, tableView, _, viewModel) in
            
            guard let self = self else { return UITableViewCell() }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxUITableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell
        })
        
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)
        tableView.rx.modelSelected(ReusableTableViewCellViewModelType.self)
            .filter{ $0 is TransactionFilterCheckBoxCellViewModelType }
            .map{ $0 as? TransactionFilterCheckBoxCellViewModel }
            .subscribe(onNext: {
                $0?.inputs.selectedObserver.onNext(())
            }).disposed(by: rx.disposeBag)
    }
    
    func setupBindings() {
        
        applyButton.rx.tap.subscribe(onNext: {[weak self] _ in
//            if CheckInternetConnectivity.isConnectedToInternet {
                self?.viewModel.inputs.applyObserver.onNext(())
                self?.navigationController?.dismiss(animated: true, completion: nil)
//            }else{
//                self?.alert.show(inView: self!.view, type: .error, text:  "common_display_text_error_no_internet".localized, autoHides: true)
//            }
        }).disposed(by: rx.disposeBag)

        clearButton.rx.tap.subscribe(onNext: {[weak self] _ in
//            if CheckInternetConnectivity.isConnectedToInternet {
                self?.viewModel.inputs.clearObserver.onNext(())
//            }else{
//                self?.alert.show(inView: self!.view, type: .error, text:  "common_display_text_error_no_internet".localized, autoHides: true)
//            }
        }).disposed(by: rx.disposeBag)
    }
}

public protocol ReusableTableViewCellViewModelType {
    var reusableIdentifier: String { get }
}
