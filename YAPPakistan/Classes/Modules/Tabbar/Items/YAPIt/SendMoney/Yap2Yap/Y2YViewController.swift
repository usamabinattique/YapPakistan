//
//  Y2YViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 10/01/2022.
//

import UIKit
import RxSwift
import YAPComponents
import RxTheme
import RxDataSources
import MessageUI

class Y2YViewController: UIViewController {
    
    // MARK: Views
    
    private lazy var recentBeneficiaryContainerView = UIFactory.makeView()
    
    private lazy var recentHeading = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping, text: "screen_y2y_display_text_prompt".localized)

    private lazy var saperator = UIFactory.makeView()

    // Beneficiaries
    private lazy var beneficiariesView = UIFactory.makeView()

    private lazy var searchButton = UIFactory.makeButton(with: .small, backgroundColor: .groupTableViewBackground, title: "screen_y2y_display_text_search".localized)

    private lazy var yapContactsButton = UIFactory.makeButton(with: .micro, title: "screen_y2y_display_button_yap_contacts".localized)
    
    private lazy var allContactButton = UIFactory.makeButton(with: .micro, backgroundColor: .clear, title: "screen_y2y_display_button_all_contacts".localized)

    private lazy var contactButtonStack = UIFactory.makeStackView(axis: .horizontal, alignment: .center, distribution: .fill, spacing: 20.0, arrangedSubviews: [yapContactsButton, allContactButton])

    private lazy var contactLabel = UIFactory.makeLabel(font: .small)

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // Main stack
    private lazy var mainStack = UIFactory.makeStackView(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 0, arrangedSubviews: [recentBeneficiaryContainerView, beneficiariesView])

    // No YAP contact view
    private lazy var noYapContactView = UIFactory.makeView()
    
    private lazy var noYapContactTitle = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping, text: "screen_y2y_display_text_no_yap_contacts".localized)

    private lazy var inviteButton = UIFactory.makeAppRoundedButton(with: .large, title: "screen_y2y_display_button_invite_now".localized)

    private lazy var placeholderImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)

    private lazy var noYapContactStack = UIFactory.makeStackView(axis: .vertical, alignment: .center, distribution: .fill, spacing: 25.0, arrangedSubviews: [placeholderImage, noYapContactTitle, inviteButton])
    
    private var backButton: UIButton!
    
    // MARK: Properties
    private var viewModel: Y2YViewModelType!
    private var allBeneficiaryDataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    private var themeService: ThemeService<AppTheme>
    private var recentBeneficiaryView: RecentBeneficiaryView!

   // MARK: Initialization

    init(themeService: ThemeService<AppTheme>, viewModel: Y2YViewModelType, recentBeneficiaryView: RecentBeneficiaryView) {
        self.viewModel = viewModel
        self.themeService = themeService
        self.recentBeneficiaryView = recentBeneficiaryView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton = makeAndAddBackButton(of: viewModel.outputs.isPresented ? .closeEmpty : .backEmpty)
        self.title = "screen_y2y_display_text_screen_title".localized
        //navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "icon_invite_friend", in: y2yBundle, compatibleWith: nil), style: .plain, target: self, action: #selector(addAction))
        
        setupSubViews()
        setupConstraints()
        setupBindings()
        setupResources()
        setupTheme()
        setupLocalizedStrings()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        yapContactsButton.roundView()
        allContactButton.roundView()
        searchButton.roundView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        SessionManager.current.refreshCurrencies()
        self.searchButton.isEnabled = true
    }
    
    override func onTapBackButton() {
        viewModel.inputs.closeObserver.onNext(())
    }
    
}

fileprivate extension Y2YViewController {
    func setupSubViews() {
        
        view.addSubview(mainStack)

        recentBeneficiaryContainerView.addSubview(recentHeading)
        recentBeneficiaryContainerView.addSubview(recentBeneficiaryView)

        beneficiariesView.addSubview(searchButton)
        beneficiariesView.addSubview(contactButtonStack)
        beneficiariesView.addSubview(contactLabel)
        beneficiariesView.addSubview(tableView)
        beneficiariesView.addSubview(noYapContactView)

        noYapContactView.addSubview(noYapContactStack)

        tableView.register(Y2YContactCell.self, forCellReuseIdentifier: Y2YContactCell.defaultIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)

        viewModel.outputs.refreshData.subscribe(onNext: { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func setupConstraints() {
        mainStack
            .alignEdgesWithSuperview([.left, .right, .safeAreaTop, .bottom])

        recentHeading
            .alignEdgesWithSuperview([.left, .top, .right], constants: [25, 8, 25])

        recentBeneficiaryView
            .alignEdgesWithSuperview([.left, .right, .bottom])
            .toBottomOf(recentHeading, constant: 14)

        searchButton
            .alignEdgesWithSuperview([.left, .top, .right], constants: [25, 15, 25])
            .height(constant: 30)

        contactButtonStack
            .centerHorizontallyInSuperview()
            .toBottomOf(searchButton, constant: 20)

        yapContactsButton
            .width(constant: 100)
            .height(constant: 20)

        allContactButton
            .width(with: .width, ofView: yapContactsButton)
            .height(with: .height, ofView: yapContactsButton)

        contactLabel
            .alignEdgeWithSuperview(.left, constant: 25)
            .toBottomOf(contactButtonStack, constant: 16)

        tableView
            .alignEdgesWithSuperview([.left, .right, .bottom])
            .toBottomOf(contactLabel)

        noYapContactView
            .alignEdgesWithSuperview([.left, .right, .bottom])
            .toBottomOf(contactButtonStack)

        noYapContactStack
            .alignEdgesWithSuperview([.top, .bottom], .greaterThanOrEqualTo, constant: 10)
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .centerInSuperView()

        placeholderImage
            .alignEdgesWithSuperview([.left, .right], .greaterThanOrEqualTo, constant: 20)

        inviteButton
            .width(constant: 190)
            .height(constant: 52)
    }
    
    func setupBindings() {
        viewModel.outputs.showsInviteButton.map { !$0 }.bind(to: inviteButton.rx.isHidden).disposed(by: rx.disposeBag)
        viewModel.outputs.showsInviteButton.map { !$0 }.bind(to: placeholderImage.rx.isHidden).disposed(by: rx.disposeBag)
        viewModel.outputs.noContactTitle.bind(to: noYapContactTitle.rx.text).disposed(by: rx.disposeBag)
        inviteButton.rx.tap.bind(to: viewModel.inputs.inviteObserver).disposed(by: rx.disposeBag)
        viewModel.outputs.allContactsAvailable.bind(to: noYapContactView.rx.isHidden).disposed(by: rx.disposeBag)
        viewModel.outputs.recentContactsAvailable.map { !$0 }.bind(to: recentBeneficiaryContainerView.rx.isHidden).disposed(by: rx.disposeBag)
        searchButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.searchButton.isEnabled = false
            self?.viewModel.inputs.searchObserver.onNext(())
        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.showError.bind(to: rx.showErrorMessage).disposed(by: rx.disposeBag)

        viewModel.outputs.headerText.bind(to: contactLabel.rx.attributedText).disposed(by: rx.disposeBag)
        viewModel.outputs.enableSearch.bind(to: searchButton.rx.isEnabled).disposed(by: rx.disposeBag)
        
        yapContactsButton.rx.tap
            .do(onNext: { [weak self] in
                self?.allContactButton.backgroundColor = .clear
                self?.yapContactsButton.backgroundColor = UIColor((self?.themeService.attrs.primary)!).withAlphaComponent(0.15)
            })
                .bind(to: viewModel.inputs.yapContactObserver).disposed(by: rx.disposeBag)

        allContactButton.rx.tap
            .do(onNext: { [weak self] in
                self?.yapContactsButton.backgroundColor = .clear
                self?.allContactButton.backgroundColor = UIColor((self?.themeService.attrs.primary)!).withAlphaComponent(0.15)
            })
                .bind(to: viewModel.inputs.allContactObserver).disposed(by: rx.disposeBag)

                recentBeneficiaryView.configure(with: self.themeService, viewModel: viewModel.outputs.recentBeneficiaryViewModel)
    }
    
    func setupResources() {
        searchButton.setImage(UIImage(named: "icon_search", in: .yapPakistan)?.asTemplate, for: .normal)
        placeholderImage.image = UIImage(named: "image_empty_set_placeholder", in: .yapPakistan)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark)}, to: [recentHeading.rx.textColor])
            .bind({ UIColor($0.greyDark).withAlphaComponent(0.15) }, to: [saperator.rx.backgroundColor])
            .bind({ UIColor($0.greyDark)}, to: [searchButton.rx.titleColor(for: .normal)])
            .bind({ UIColor($0.greyDark)}, to: [searchButton.rx.tintColor])
            .bind({ UIColor($0.primary).withAlphaComponent(0.15) }, to: [yapContactsButton.rx.backgroundColor])
            .bind({ UIColor($0.primary)}, to: [yapContactsButton.rx.titleColor(for: .normal)])
            .bind({ UIColor($0.primary)}, to: [allContactButton.rx.titleColor(for: .normal)])
            .bind({ UIColor($0.primaryDark)}, to: [contactLabel.rx.textColor])
            .bind({ UIColor($0.backgroundColor)}, to: [noYapContactView.rx.backgroundColor])
            .bind({ UIColor($0.greyDark)}, to: [noYapContactTitle.rx.textColor])
            .bind({ UIColor($0.primaryDark)}, to: [backButton.rx.tintColor])
            .disposed(by: rx.disposeBag)
        
        view.backgroundColor = .white
        tableView.backgroundColor = .white
    }
    
    func setupLocalizedStrings() {
        
    }
}

// MARK: Tableveiw data source

extension Y2YViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.outputs.numberOfCells
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Y2YContactCell.defaultIdentifier) as! Y2YContactCell
        cell.indexPath = indexPath
        cell.configure(with: self.themeService, viewModel: viewModel.outputs.model(forIndex: indexPath))
        return cell
    }
}

// MARK: Table view delegate

extension Y2YViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.inputs.cellSelected(at: indexPath)
    }
}
