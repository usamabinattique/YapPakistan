//
//  PaymentCardOnboardingStatusView.swift
//  YAPPakistan
//
//  Created by Yasir on 13/04/2022.
//

import UIKit
import RxSwift
import RxTheme

public class PaymentCardOnboardingStatusView: UIView {
    
    // MARK: - Views
    private let tableView: UITableView = UITableView()
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var viewModel: PaymentCardInitiatoryStageViewModel?
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: - Init
    public init(theme:ThemeService<AppTheme>, viewModel: Any) {
        super.init(frame: CGRect.zero)
        guard let viewModel = viewModel as? PaymentCardInitiatoryStageViewModel else { return }
        self.viewModel = viewModel
        self.themeService = theme
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
//        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        commonInit()
    }
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = false
        backgroundColor = .white
        tableView.register(PaymentCardOnboardingStatusTableViewCell.self,
                           forCellReuseIdentifier: PaymentCardOnboardingStatusTableViewCell.defaultIdentifier)
        setupViews()
        setupConstraints()
        bind(viewModel: viewModel)
    }
    
    // MARK: - Setup
    func setupViews() {
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.delegate = self
    }
    
    func setupConstraints() {
        tableView
            .alignEdgesWithSuperview([.left, .right], constants: [25, 0])
            .alignEdgesWithSuperview([.safeAreaTop, .bottom], constants: [25, 15])
    }
    
    func bind(viewModel: PaymentCardInitiatoryStageViewModel?) {
        guard let viewModel = viewModel else { fatalError("ViewModel is nil") }
        viewModel.stages.bind(to: tableView.rx.items) { [unowned self] tableView, item, stage in
           
            let cell = tableView
                .dequeueReusableCell(withIdentifier: PaymentCardOnboardingStatusTableViewCell.defaultIdentifier) as! PaymentCardOnboardingStatusTableViewCell
            cell.configure(with: self.themeService, viewModel: stage)
            return cell
        }.disposed(by: disposeBag)
    }
}

extension PaymentCardOnboardingStatusView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
