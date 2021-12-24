//
//  TransactionFilterCheckBoxCell.swift
//  YAPPakistan
//
//  Created by Umair  on 22/12/2021.
//

import Foundation
import YAPComponents
import RxTheme

class TransactionFilterCheckBoxCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var title = UIFactory.makeLabel(font: .regular)
    
    private lazy var checkBox: YAPCheckBox = {
        let checkBox = YAPCheckBox()
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        return checkBox
    }()
    
    // MARK: Properties
    
    var themeService: ThemeService<AppTheme>!
    var viewModel: TransactionFilterCheckBoxCellViewModelType!
    
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
        
        //setupResources()
        //setupLocalizedStrings()
        //setupBindings()
        setupConstraints()
    }
    
    // MARK: Configurations
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        self.themeService = themeService
        
        guard let viewModel = viewModel as? TransactionFilterCheckBoxCellViewModelType else { return }
        self.viewModel = viewModel
        bindViews()
        setupTheme()
    }
}

// MARK: View setup

private extension TransactionFilterCheckBoxCell {
    func setupViews() {
        contentView.addSubview(title)
        contentView.addSubview(checkBox)
    }
    
    func setupConstraints() {
        title
            .alignEdgeWithSuperview(.left, constant: 25)
            .centerVerticallyInSuperview()
        
        checkBox
            .alignEdgeWithSuperview(.right, constant: 25)
            .toRightOf(title, constant: 10)
            .centerVerticallyInSuperview()
            .alignEdgesWithSuperview([.top, .bottom], constant: 7)
            .width(constant: 28)
            .height(constant: 28)
        
    }
    
    func setupTheme(){
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [title.rx.textColor])
        
            .disposed(by: rx.disposeBag)
    }
}

// MARK: Binding

private extension TransactionFilterCheckBoxCell {
    func bindViews() {
        viewModel.outputs.check.bind(to: checkBox.rx.checked).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: title.rx.text).disposed(by: disposeBag)
        checkBox.rx.checked.bind(to: viewModel.inputs.checkObserver).disposed(by: disposeBag)
    }
}
