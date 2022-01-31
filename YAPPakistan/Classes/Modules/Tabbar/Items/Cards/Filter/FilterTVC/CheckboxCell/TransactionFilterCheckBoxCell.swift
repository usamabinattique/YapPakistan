//
//  TransactionFilterCheckBoxCell.swift
//  YAPPakistan
//
//  Created by Umair  on 22/12/2021.
//

import Foundation
import YAPComponents
import RxTheme
import UIKit
//import YAP_PK_Dev

class TransactionFilterCheckBoxCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var title = UIFactory.makeLabel(font: .regular)
    
    private lazy var checkBox: YAPCheckBox = {
        let checkBox = YAPCheckBox()
        checkBox.translatesAutoresizingMaskIntoConstraints = false
       // checkBox.imageView.image = UIImage.init(named: "icon_check", in: .yapPakistan)?.asTemplate
//        checkBox.imageView.image = UIImage.init(named: "icon_check", in: .yapPakistan)
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
        setupResources()
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
            .bind({ UIColor($0.backgroundColor) }, to: [checkBox.rx.tintColor])
            .bind({ UIColor($0.primary) }, to: [checkBox.rx.fillColor])
        
            .disposed(by: rx.disposeBag)
    }
    
    func setupResources() {
        //checkBox.imageView.image = UIImage.init(named: "icon_check", in: .yapPakistan)?.asTemplate
    }
}

// MARK: Binding

private extension TransactionFilterCheckBoxCell {
    func bindViews() {
      //  viewModel.outputs.check.bind(to: checkBox.rx.checked).disposed(by: disposeBag)
        let checkShare = viewModel.outputs.check.share()
        checkShare.bind(to: checkBox.rx.checked).disposed(by: disposeBag)
        
        checkShare.subscribe(onNext: { [unowned self] isChecked in
            self.checkBox.backgroundColor =  isChecked ? UIColor(Color(hex: "#5E35B1")) : .clear
        }).disposed(by: disposeBag)

        
        viewModel.outputs.title.bind(to: title.rx.text).disposed(by: disposeBag)
        checkBox.rx.checked.bind(to: viewModel.inputs.checkObserver).disposed(by: disposeBag)
    }
}
