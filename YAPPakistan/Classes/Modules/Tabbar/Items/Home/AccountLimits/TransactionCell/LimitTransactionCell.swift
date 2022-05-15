//
//  LimitTransactionCell.swift
//  YAPPakistan
//
//  Created by Umair  on 14/05/2022.
//

import Foundation
import YAPComponents
import RxSwift
import RxTheme
import UIKit

class LimitTransactionCell: RxUITableViewCell {
    
    // MARK: Views
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var transactionTitle = UIFactory.makeLabel(font: .large, alignment: .left, numberOfLines: 0, text: "Monthly: PKR 10,000")
    private lazy var progressPlaceholderView = UIFactory.makeView()
    private lazy var progressView = UIFactory.makeView()
    private lazy var consumedLimitLbl = UIFactory.makeLabel(font: .micro, numberOfLines: 0, text: "PKR 0")
    private lazy var allocatedLimitLbl = UIFactory.makeLabel(font: .micro, numberOfLines: 0, text: "PKR 1000")
    private lazy var separatorView = UIFactory.makeView()
    
    // MARK: Properties
    
    var viewModel: LimitTransactionCellViewModel!
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
        setupSubViews()
        setupConstraints()
    }
    
    // MARK: View cycle
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
    }
    
    // MARK: Configurations
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? LimitTransactionCellViewModel else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        setupBindings()
        setupTheme()
    }
    
}

extension LimitTransactionCell: ViewDesignable {
    func setupSubViews() {
        
        containerView.addSubview(transactionTitle)
        containerView.addSubview(progressPlaceholderView)
        progressPlaceholderView.addSubview(progressView)
        containerView.addSubview(consumedLimitLbl)
        containerView.addSubview(allocatedLimitLbl)
        containerView.addSubview(separatorView)
        contentView.addSubview(containerView)

    }
    
    func setupConstraints() {
        
        containerView
            .alignAllEdgesWithSuperview()
        
        transactionTitle
            .alignEdgesWithSuperview([.top, .left, .right], constants: [16, 19, 19])
        
        progressPlaceholderView
            .toBottomOf(transactionTitle, constant: 15)
            .alignEdgesWithSuperview([.left, .right], constants: [19, 19])
            .height(constant: 8)
        
        progressView
            .alignEdgesWithSuperview([.left, .top, .bottom], constants: [0, 0, 0])
            .widthEqualToSuperView(multiplier: 0.5, constant: 0, priority: .defaultHigh)
        
        consumedLimitLbl
            .alignEdge(.left, withView: progressPlaceholderView)
            .toBottomOf(progressView, constant: 7)
            .height(constant: 14)
        
        allocatedLimitLbl
            .alignEdge(.right, withView: progressPlaceholderView)
            .toBottomOf(progressView, constant: 7)
            .height(constant: 14)
        
        separatorView
            .toBottomOf(consumedLimitLbl, constant: 17)
            .alignEdgesWithSuperview([.left, .right, .bottom], constants: [18, 18, 0])
            .height(constant: 1)
    }
    
    func setupBindings() {
        viewModel.outputs.limitProgress
            .subscribe(onNext: { [weak self] progrees in
                self?.progressView
                    .widthEqualToSuperView(multiplier: progrees, constant: 0, priority: .defaultHigh)
                self?.layoutIfNeeded()
            }).disposed(by: disposeBag)
        
        viewModel.outputs.transactionTitle.bind(to: transactionTitle.rx.text).disposed(by: disposeBag)
        viewModel.outputs.limitConsumedValue.bind(to: consumedLimitLbl.rx.text).disposed(by: disposeBag)
        viewModel.outputs.limitAllocatedValue.bind(to: allocatedLimitLbl.rx.text).disposed(by: disposeBag)
        print(viewModel.isLastElement)
        viewModel.outputs.isLast.bind(to: separatorView.rx.isHidden).disposed(by: disposeBag)
    }
    
    func setupTheme() {
        
        self.themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: contentView.rx.backgroundColor)
            .bind({ UIColor($0.primary) }, to: transactionTitle.rx.textColor)
            .bind({ UIColor($0.greyLight) }, to: separatorView.rx.backgroundColor)
            .bind({ UIColor($0.greyLight) }, to: progressPlaceholderView.rx.backgroundColor)
            .bind({ UIColor($0.secondaryBlue) }, to: progressView.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        progressPlaceholderView.layer.cornerRadius = progressPlaceholderView.frame.size.height/2
        progressPlaceholderView.clipsToBounds = true
    }
    
}
