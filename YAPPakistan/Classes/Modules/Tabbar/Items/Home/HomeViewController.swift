//
//  HomeViewController.swift
//  YAP
//
//  Created by Wajahat Hassan on 26/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxTheme
import YAPComponents
import RxDataSources

class HomeViewController: UIViewController {

    // MARK: Views
    private lazy var menuButtonItem = barButtonItem(image: UIImage(named: "icon_menu_dashboard", in: .yapPakistan), insectBy:.zero)
    private lazy var searchBarButtonItem = barButtonItem(image: UIImage(named: "icon_search", in: .yapPakistan)?.asTemplate, insectBy:.zero)
    private lazy var analyticsBarButtonItem = barButtonItem(image: UIImage(named: "icon_analytics", in: .yapPakistan), insectBy:.zero)
    private lazy var userBarButtonItem = barButtonItem(image: UIImage(named: "kyc-user", in: .yapPakistan), insectBy:.zero)
    
    private lazy var balanceValueLabel = UIFactory.makeLabel(font: .title1,
                                                        alignment: .left,
                                                        numberOfLines: 0,
                                                        lineBreakMode: .byWordWrapping)
    private lazy var showButton = UIFactory.makeButton(with: .regular)
    private lazy var hideButton = UIFactory.makeButton(with: .regular)
    private lazy var balanceDateLabel = UIFactory.makeLabel(font: .micro,
                                                        alignment: .left,
                                                        numberOfLines: 0,
                                                        lineBreakMode: .byWordWrapping)
    private lazy var separtorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var balanceView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var stack = UIFactory.makeStackView(axis: .vertical, alignment: .center, distribution: .fill, spacing: 20)
    
    private lazy var logo = UIFactory.makeImageView(image: UIImage(named: "icon_app_logo", in: .yapPakistan),
                                                    contentMode: .scaleAspectFit)
    private lazy var headingLabel = UIFactory.makeLabel(font: .title1,
                                                        alignment: .center,
                                                        numberOfLines: 0,
                                                        lineBreakMode: .byWordWrapping)

    private lazy var logoutButton = UIFactory.makeAppRoundedButton(with: .large)

    private lazy var biometryLabel = UIFactory.makeLabel(font: .regular)

    private lazy var biometrySwitch = UIFactory.makeAppSwitch()

    private lazy var biometryStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [biometryLabel, biometrySwitch])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    private lazy var completeVerificationButton = UIFactory.makeAppRoundedButton(with: .large, title: "Complete verification")
    
    // MARK: Properties

    private var themeService: ThemeService<AppTheme>!

    private let disposeBag = DisposeBag()
    var viewModel: HomeViewModelType!
    private var balanceHeight: NSLayoutConstraint!
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!

    // MARK: Initialization

    init(themeService: ThemeService<AppTheme>, viewModel: HomeViewModelType) {
        super.init(nibName: nil, bundle: nil)

        self.themeService = themeService
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: View Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = userBarButtonItem.barItem
       // navigationItem.rightBarButtonItem = menuButtonItem.barItem
        navigationItem.rightBarButtonItems = [menuButtonItem.barItem,searchBarButtonItem.barItem,analyticsBarButtonItem.barItem]
        setupViews()
        setupTheme()
        setupConstraints()
        bindViewModel()
        bindTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
            print(self)
        }
    }

    // MARK: View Setup

    private func setupViews() {
        
        balanceView.addSubviews([balanceValueLabel,showButton,hideButton,balanceDateLabel,separtorView])
       // containerView.addSubviews([balanceView,tableView])
//        containerView.backgroundColor = .red
//        balanceView.backgroundColor = .yellow
//        tableView.backgroundColor = .gray
        containerView.addSubview(balanceView)
        containerView.addSubview(tableView)
        view.addSubview(containerView)
        separtorView.alpha = 0
        
        tableView.register(CreditLimitCell.self, forCellReuseIdentifier: CreditLimitCell.defaultIdentifier)
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 15, right: 0)
        
      //  stack.addArrangedSubviews([balanceView, tableView])
        showButton.imageView?.contentMode = .scaleAspectFit
        showButton.setImage(UIImage.init(named: "icon_view_cell", in: .yapPakistan)?.asTemplate, for: .normal)
        hideButton.setImage(UIImage.init(named: "eye_close", in: .yapPakistan), for: .normal)
        hideButton.isHidden = true
        separtorView.alpha = 0
        separtorView.backgroundColor = .yellow
        
        balanceValueLabel.text = "PKR 50,174.78"
        balanceDateLabel.text = "Today's balance"
//        view.addSubview(logo)
//        view.addSubview(headingLabel)
//        view.addSubview(logoutButton)
//        view.addSubview(biometryStackView)
//        view.addSubview(completeVerificationButton)
    }

    private func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.greyDark) }, to: headingLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: logoutButton.rx.backgroundColor,(searchBarButtonItem.button?.rx.tintColor)!)
            .bind({ UIColor($0.greyDark) }, to: [biometryLabel.rx.textColor,balanceDateLabel.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [completeVerificationButton.rx.backgroundColor,showButton.rx.tintColor])
            .bind({ UIColor($0.primaryDark) }, to: [separtorView.rx.backgroundColor,balanceValueLabel.rx.textColor])
        
            .disposed(by: disposeBag)
    }

    private func setupConstraints() {
        
        containerView
            .alignAllEdgesWithSuperview()
            //.alignEdgesWithSuperview([.left, .right, .bottom,.top])
        
        balanceView
            .height(constant: 70)
            .alignEdgesWithSuperview([.left, .top, .right], constants: [0, 0, 0])
        
        tableView
            .toBottomOf(balanceView)
            .alignEdgesWithSuperview([.left, .right,.bottom], constants: [0, 0,0])
        
        balanceValueLabel
            .alignEdgesWithSuperview([.left, .top, .right], constants: [24, 12, 24])
        
        showButton
            .height(constant: 18)
            .width(constant: 20)
            .toBottomOf(balanceValueLabel,constant: 12)
            .alignEdgesWithSuperview([.left], constants: [24])
        
        hideButton
            .height(constant: 18)
            .width(constant: 20)
            .toBottomOf(balanceValueLabel,constant: 12)
            .alignEdgesWithSuperview([.left], constants: [24])
        
        separtorView
            .height(constant: 1)
            .width(constant: 134)
            .toBottomOf(balanceValueLabel,constant: 4)
            .alignEdgesWithSuperview([.left], constants: [24])
        
       balanceDateLabel
            .height(constant: 14)
            .toRightOf(showButton,constant: 8)
            .toBottomOf(balanceValueLabel,constant: 12)
        
        balanceHeight = balanceValueLabel.heightAnchor.constraint(equalToConstant: 24)
        balanceHeight.priority = .required
        balanceHeight.isActive = true
        
       /* headingLabel
            .alignEdgeWithSuperviewSafeArea(.top, constant: 30)
            .alignEdgesWithSuperview([.left, .right], constant: 25)
        
        stack
            .toBottomOf(headingLabel, constant: 30)
            .alignEdgesWithSuperview([.left, .right, .bottom])
        
        collectionView
            .alignEdgesWithSuperview([.left, .right], constant: 25)
        
        recentBeneficiaryView
            .alignEdgesWithSuperview([.left, .right])
        
       logo
            .alignEdgeWithSuperviewSafeArea(.top, constant: 120)
            .centerHorizontallyInSuperview()

        headingLabel
            .toBottomOf(logo, constant: 40)
            .alignEdgesWithSuperview([.left, .right], constants: [20, 20])
            .centerHorizontallyInSuperview()

        logoutButton
            .toBottomOf(headingLabel, constant: 70)
            .height(constant: 52)
            .width(constant: 250)
            .centerHorizontallyInSuperview()

        biometryStackView
            .toBottomOf(logoutButton, constant: 20)
            .width(with: .width, ofView: logoutButton)
            .centerHorizontallyInSuperview()

        completeVerificationButton
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 20)
            .centerHorizontallyInSuperview()
            .height(constant: 52)
            .width(constant: 250) */
    }

    // MARK: Binding

    private func bindViewModel() {
     /*   viewModel.outputs.biometrySupported.map { $0 }.subscribe(onNext: {[unowned self] isHidden in
            self.biometryLabel.isHidden = !isHidden
            self.biometrySwitch.isHidden = !isHidden
        }).disposed(by: disposeBag)

        viewModel.outputs.biometryTitle
            .map { "Sign in with \($0 ?? "")" }
            .bind(to: biometryLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.biometry
            .bind(to: biometrySwitch.rx.value)
            .disposed(by: disposeBag)

        viewModel.outputs.headingText
            .bind(to: headingLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.logOutButtonTitle
            .bind(to: logoutButton.rx.title(for: .normal))
            .disposed(by: disposeBag)

        logoutButton.rx.tap
            .bind(to: viewModel.inputs.logoutObserver)
            .disposed(by: disposeBag)

        viewModel.outputs.completeVerificationHidden
            .bind(to: completeVerificationButton.rx.isHidden)
            .disposed(by: disposeBag)

        completeVerificationButton.rx.tap
            .bind(to: viewModel.inputs.completeVerificationObserver)
            .disposed(by: disposeBag)

        biometrySwitch.rx.value
            .bind(to: viewModel.inputs.biometryChangeObserver)
            .disposed(by: disposeBag) */

        viewModel.outputs.showActivity
            .bind(to: view.rx.showActivity)
            .disposed(by: disposeBag)

        viewModel.outputs.error
            .bind(to: rx.showErrorMessage)
            .disposed(by: disposeBag)
        
        //viewModel.outputs.profilePic.bind(to: (userBarButtonItem.barItem.rx.loadImage())).disposed(by: disposeBag)
        viewModel.outputs.profilePic.subscribe(onNext: { [weak self] _arg0 in
            let (imageUrl,placeholderImg) = _arg0
            
            self?.userBarButtonItem.button?.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            self?.userBarButtonItem.button?.layer.cornerRadius = (self?.userBarButtonItem.button?.frame.size.height  ?? 30 )/2
            self?.userBarButtonItem.button?.clipsToBounds = true
            
            self?.userBarButtonItem.button?.setImage(placeholderImg, for: .normal)
           /* if let url = imageUrl {
                self?.userBarButtonItem.button?.sd_setImage(with: url, for: .normal)
            } else {
                self?.userBarButtonItem.button?.setImage(placeholderImg, for: .normal)
            } */
            
        }).disposed(by: disposeBag)

        showButton.rx.tap.withUnretained(self).subscribe(onNext: { `self`, _ in
            self.animateView(balanceShown: false)
        }).disposed(by: disposeBag)
        
        hideButton.rx.tap.withUnretained(self).subscribe(onNext: { `self`, _ in
            self.animateView(balanceShown: true)
        }).disposed(by: disposeBag)

    }
}

private extension HomeViewController {
    func animateView(balanceShown: Bool) {
        balanceHeight.constant = balanceShown ? 24 : 0
       // delegate?.recentBeneficiaryViewWillAnimate(self)
        UIView.animate(withDuration: 0.3, animations: {
          //  self.view.layoutAllSuperViews()
            self.view.layoutAllSubviews()
            self.separtorView.alpha = !balanceShown ? 1 : 0
        }) { (completion) in
            guard completion else { return }
            self.balanceValueLabel.isHidden = !balanceShown
            self.showButton.isHidden = !balanceShown
            self.hideButton.isHidden = balanceShown
//            self.delegate?.recentBeneficiaryViewDidAnimate(self)
        }
    }
}

private extension HomeViewController {
    func bindTableView() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { (_, tableView, _, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! ConfigurableTableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell as! UITableViewCell
        })
        
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }

}
