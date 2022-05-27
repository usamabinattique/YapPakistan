//
//  TransactionReceiptTableViewCell.swift
//  YAPPakistan
//
//  Created by Awais on 24/05/2022.
//

import UIKit
import YAPComponents
import RxSwift
import RxTheme
import RxCocoa

class TransactionReceiptTableViewCell: RxUITableViewCell {
    
    // MARK: Views
    private lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.image = UIImage(named: "icon_app_logo", in: .yapPakistan)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel = UIFactory.makeLabel(font: .large, alignment: .center, numberOfLines: 0)
    
    // MARK: - Views
    private lazy var outerStackView = UIFactory.makeStackView( axis: .vertical,
                                                               alignment: .fill,
                                                               distribution: .fill,
                                                               spacing: 15 )
    
    private lazy var receiptTilteLabel = UIFactory.makeLabel(alignment: .left, text: "Name")
    private lazy var receiptValueLabel = UIFactory.makeLabel(alignment: .left, text: "Awais Iqbal")
    
    
    
    // MARK: Properties
    private var viewModel: TransactionReceiptTableViewCellViewModelType!
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
    
    // MARK: Layouting
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
    }
    
    // MARK: Configuration
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? TransactionReceiptTableViewCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        
        setupTheme()
        bindViews()
    }
    
    func setupView() {
        
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [titleLabel.rx.tintColor])
    }
    
}

// MARK: View setup

private extension TransactionReceiptTableViewCell {
    func setupViews() {
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(outerStackView)
        
        //        self.view.layer.cornerRadius = 10;
        //        view.clipsToBounds  =  true
        
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor //UIColor(themeService.attrs.greyDark).cgColor
        
        
        titleLabel.text = "Transaction Details"
        
        
//        outerStackView.addArrangedSubview(innerStackName)
//        //        contentView.addSubview(titleLabel)
//        //        contentView.addSubview(nextImage)
    }
    
    func setupConstraints() {
        icon
            .alignEdgesWithSuperview([.top], constants: [24])
            .centerHorizontallyInSuperview()
            .height(constant: 40)
            .width(constant: 100)
        
        titleLabel
            .alignEdgesWithSuperview([.left, .right], constants: [20,20])
            .toBottomOf(icon, constant: 18)
        
        outerStackView
            .alignEdgesWithSuperview([.left, .right, .bottom], constants: [20,20,20])
            .toBottomOf(titleLabel, constant: 40)
    }
    
    private func addTransactionDetail(withTitle title: String, withvalue value: String) {
        let titleLabel = UIFactory.makeLabel(font: .small, alignment: .left, numberOfLines: 0, text : title)
        let valueLabel = UIFactory.makeLabel(font: .small, alignment: .right, numberOfLines: 0, text : value)
        
        let innerStackName = UIFactory.makeStackView( axis: .horizontal,
                                                                   alignment: .fill,
                                                                   distribution: .fill,
                                                                   spacing: 3)
        
        innerStackName.addArrangedSubviews([titleLabel, valueLabel])
        titleLabel.textColor = UIColor(themeService.attrs.greyDark)
        valueLabel.textColor = UIColor(themeService.attrs.primary)
        self.outerStackView.addArrangedSubview(innerStackName)
    }
}

// MARK: Bindind

private extension TransactionReceiptTableViewCell {
    func bindViews() {
        viewModel.outputs.transactionDate.subscribe(onNext: { [unowned self] date in
            self.addTransactionDetail(withTitle: "Transaction Date", withvalue: date)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.amount.subscribe(onNext: { [unowned self] amount in
            self.addTransactionDetail(withTitle: "Amount", withvalue: amount)
        }).disposed(by: disposeBag)

        viewModel.outputs.refernceNumber.subscribe(onNext: { [unowned self] referenceNumber in
            self.addTransactionDetail(withTitle: "Reference number", withvalue: referenceNumber)
        }).disposed(by: disposeBag)
    }
}
