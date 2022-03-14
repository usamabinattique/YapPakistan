//
//  SendMoneyHomeViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 14/03/2022.
//

import UIKit
import YAPCore
import YAPComponents
import RxSwift
import RxCocoa
import RxDataSources
import SwipeCellKit
import RxTheme

class SendMoneyHomeViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var heading: UILabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping, text: "screen_send_money_no_contacts_display_text_sub_heading".localized) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping, text: "screen_send_money_no_contacts_display_text_sub_heading".localized)
    
    private lazy var subHeading: UILabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping, text: "screen_send_money_no_contacts_display_text_detail".localized) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping, text: "screen_send_money_no_contacts_display_text_detail".localized)
    
    private lazy var addNowButton: AppRoundedButton = AppRoundedButtonFactory.createAppRoundedButton(title: "screen_send_money_no_contacts_button_title_add_now".localized)
    
    private lazy var noBeneficiaryView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var beneficiaryView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .fill, distribution: .fill, spacing: 14)
    
    private lazy var recentBeneficiaryView: RecentBeneficiaryView = {
        let view = RecentBeneficiaryView(with: themeService)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var allBeneficiaryView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .groupTableViewBackground
      //  button.tintColor = .greyDark
        button.setImage(UIImage.sharedImage(named: "icon_search")?.asTemplate, for: .normal)
        button.setTitle("screen_send_money_input_text_search_hint".localized, for: .normal)
       // button.setTitleColor(.greyDark, for: .normal)
        button.titleLabel?.font = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var allBeneficiaryLabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0, text: "screen_send_money_display_text_all_beneficiaries".localized) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small, text: "screen_send_money_display_text_all_beneficiaries".localized)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: Properties
    
    private var viewModel: SendMoneyHomeViewModelType!
    private let disposeBag = DisposeBag()
    private var recentBeneficiaryDataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!
    private var allBeneficiaryDataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    private var themeService: ThemeService<AppTheme>
    
    // MARK: Initialization
    
    init(themeService: ThemeService<AppTheme>,viewModel: SendMoneyHomeViewModelType) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "icon_close", in: .yapPakistan), style: .plain, target: self, action: #selector(closeAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "icon_add_beneficiary", in: .yapPakistan, compatibleWith: nil)?.asTemplate, style: .plain, target: self, action: #selector(addBeneficiary))
        
        setupViews()
        setupConstraints()
        setupTheme()
        bindViews()
        bindTableView()
        
        viewModel.inputs.refreshObserver.onNext(())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchButton.roundView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.visibleCells.map{ $0 as? SwipeTableViewCell }.forEach{ $0?.hideSwipe(animated: true) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // SessionManager.current.refreshCurrencies()
    }
    
    // MARK: Actions
    
    @objc
    private func closeAction() {
        viewModel.inputs.closeObserver.onNext(())
    }
    
    @objc
    private func addBeneficiary() {
        self.viewModel.inputs.addObserver.onNext(())
    }
}

// MARK: View setup

private extension SendMoneyHomeViewController {
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(heading)
        view.addSubview(beneficiaryView)
        view.addSubview(noBeneficiaryView)
        
        noBeneficiaryView.addSubview(subHeading)
        noBeneficiaryView.addSubview(addNowButton)
        
        beneficiaryView.addSubview(stackView)
        
        stackView.addArrangedSubview(recentBeneficiaryView)
        stackView.addArrangedSubview(allBeneficiaryView)
        
        allBeneficiaryView.addSubview(searchButton)
        allBeneficiaryView.addSubview(allBeneficiaryLabel)
        allBeneficiaryView.addSubview(tableView)
        
     //   tableView.register(SendMoneyHomeBeneficiaryCell.self, forCellReuseIdentifier: SendMoneyHomeBeneficiaryCell.reuseIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
    }
    
    func setupConstraints() {
        heading
            .alignEdgesWithSuperview([.left, .right, .safeAreaTop], constants: [25, 25, 8])
        
        beneficiaryView
            .toBottomOf(heading, constant: 15)
            .alignEdgesWithSuperview([.left, .right, .bottom])
        
        noBeneficiaryView
            .toBottomOf(heading, constant: 15)
            .alignEdgesWithSuperview([.left, .right, .bottom])
        
        subHeading
            .alignEdgesWithSuperview([.left, .right], constants: [20, 20] )
            .alignEdgeWithSuperview(.top, .lessThanOrEqualTo, constant: 75)
            .alignEdgeWithSuperview(.top, .greaterThanOrEqualTo, constant: 45)
        
        addNowButton
            .centerHorizontallyInSuperview()
            .width(constant: 190)
            .height(constant: 52)
            .toBottomOf(subHeading, .lessThanOrEqualTo, constant: 90)
            .toBottomOf(subHeading, .greaterThanOrEqualTo, constant: 50)
            .alignEdgeWithSuperview(.bottom, .greaterThanOrEqualTo, constant: 0)
        
        stackView
            .alignAllEdgesWithSuperview()
        
        searchButton
            .alignEdgesWithSuperview([.left, .top, .right], constants: [25, 0, 25])
            .height(constant: 30)
        
        allBeneficiaryLabel
            .alignEdgeWithSuperview(.left, constant: 25)
            .toBottomOf(searchButton, constant: 10)
        
        tableView
            .alignEdgesWithSuperview([.left, .right, .bottom])
            .toBottomOf(allBeneficiaryLabel)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark)}, to: [heading.rx.textColor, allBeneficiaryLabel.rx.textColor])
            .bind({ UIColor($0.greyDark)}, to: [subHeading.rx.textColor])//[searchBarButtonItem.barItem.rx.tintColor])
            .bind({ UIColor($0.primary)}, to: [addNowButton.rx.backgroundColor, navigationItem.rightBarButtonItem!.rx.tintColor, navigationItem.leftBarButtonItem!.rx.tintColor])
            .disposed(by: rx.disposeBag)
    }
}

// MARK: Binding

private extension SendMoneyHomeViewController {
    func bindViews() {
        addNowButton.rx.tap.bind(to: viewModel.inputs.addObserver).disposed(by: disposeBag)
        viewModel.outputs.beneficiaryAvailable.bind(to: noBeneficiaryView.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.beneficiaryAvailable.map { !$0 }.bind(to: beneficiaryView.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.showError.bind(to: rx.showErrorMessage).disposed(by: disposeBag)
        viewModel.outputs.recentBeneficiaryAvailable.map { !$0 }.bind(to: recentBeneficiaryView.rx.isHidden).disposed(by: disposeBag)
        
        searchButton.rx.tap.bind(to: viewModel.inputs.searchObserver).disposed(by: disposeBag)
        
//        tableView.rx.modelSelected(SendMoneyHomeBeneficiaryCellViewModel.self).filter { (model) -> Bool in
//            return !model.isShimmering
//        }.map{ $0.beneficiary }.bind(to: viewModel.inputs.beneficiaryObserver).disposed(by: disposeBag)
        
        viewModel.outputs.showActivity.bind(to: navigationController?.view.rx.showActivity ?? view.rx.showActivity).disposed(by: disposeBag)
        
      //  recentBeneficiaryView.configure(with: viewModel.outputs.recentBeneficiaryViewModel)
        
        viewModel.outputs.title.debug("Screen title:").bind(to: navigationItem.rx.title).disposed(by: disposeBag)
        viewModel.outputs.listLabel.bind(to: allBeneficiaryLabel.rx.text).disposed(by: disposeBag)
    }
    
    func bindTableView() {
//        allBeneficiaryDataSource = RxTableViewSectionedReloadDataSource(configureCell: { [unowned self] (_, tableView, _, viewModel) in
//            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxSwipeTableViewCell
//            cell.configure(with: viewModel)
//            cell.delegate = self
//            return cell
//        })
        
     //   viewModel.outputs.allBeneficiaryDataSource.bind(to: tableView.rx.items(dataSource: allBeneficiaryDataSource)).disposed(by: disposeBag)
    }
}

// MARK: Collection view flow layout delegete

extension SendMoneyHomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: collectionView.bounds.height)
    }
}
/*
extension SendMoneyHomeViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let edit = SwipeAction(style: .default, title: "screen_send_money_display_text_edit".localized) { [unowned self] (_, indexPath) in
            self.viewModel.inputs.editBeneficiaryObserver.onNext(((tableView.cellForRow(at: indexPath) as! SendMoneyHomeBeneficiaryCell).viewModel as! SendMoneyHomeBeneficiaryCellViewModel).beneficiary)
        }
        edit.backgroundColor = .primary
        edit.image = UIImage.init(named: "icon_edit", in: sendMoneyBundle, compatibleWith: nil)?.asTemplate
        
        let delete = SwipeAction(style: .default, title: "screen_send_money_display_text_delete".localized) { [unowned self] (_, indexPath) in
            self.deleteBeneficiary(at: indexPath)
        }
        
        delete.backgroundColor = .secondaryMagenta
        delete.image = UIImage.sharedImage(named: "icon_close")?.asTemplate
        
        return [delete, edit]
    }
}

// MARK: Delete

private extension SendMoneyHomeViewController {
    func deleteBeneficiary(at indexPath: IndexPath) {
        
        guard !(SessionManager.current.currentProfile?.restrictions.contains(.otpBlocked) ?? false) else {
            UserAccessRestriction.otpBlocked.showFeatureBlockAlert()
            return
        }
        
        showAlert(message: "Are you sure you want to delete this beneficiary?", defaultButtonTitle: "common_button_cancel".localized, secondayButtonTitle: "screen_send_money_display_text_delete".localized, defaultButtonHandler: nil, secondaryButtonHandler: { _ in
            self.viewModel.inputs.deleteBeneficiaryObserver.onNext(((self.tableView.cellForRow(at: indexPath) as! SendMoneyHomeBeneficiaryCell).viewModel as! SendMoneyHomeBeneficiaryCellViewModel).beneficiary)
        }, completion: nil)
    }
}
*/
extension SendMoneyHomeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
     let verticalStack = UIStackView()

        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.isLayoutMarginsRelativeArrangement = true
        verticalStack.axis = .vertical
        verticalStack.alignment = .center
        verticalStack.distribution = .fillProportionally
        
        return true
    }
}
