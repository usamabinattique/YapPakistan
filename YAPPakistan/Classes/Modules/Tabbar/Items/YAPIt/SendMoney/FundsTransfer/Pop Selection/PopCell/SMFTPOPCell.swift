//
//  SMFTPOPCell.swift
//  YAPPakistan
//
//  Created by Yasir on 29/03/2022.
//

import UIKit
import YAPCore
import RxSwift
import YAPComponents
import RxTheme

class SMFTPOPCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var title = UIFactory.makeLabel(font: .small, alignment: .left, numberOfLines: 0, lineBreakMode: .byWordWrapping) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small, alignment: .left, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var separator: UIView = {
        let view = UIView()
       // view.backgroundColor = .red //.greyLight
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Properties
    
    private var viewModel: SMFTPOPCellViewModelType!
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
    
    // MARK: Configurations
    
    // MARK: Configurations
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? SMFTPOPCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
    }
}

// MARK: View setup

private extension SMFTPOPCell {
    func setupViews() {
        contentView.addSubview(title)
        contentView.addSubview(separator)
        contentView.backgroundColor = .groupTableViewBackground
    }
    
    func setupConstraints() {
        title
            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constants: [34, 11, 25, 11])
//            .alignEdgesWithSuperview([.left, .top, .right], constants: [34, 11, 25])
        
        separator
            .alignEdgesWithSuperview([.left, .right, .bottom])
            .alignEdgesWithSuperview([.left, .right])
           // .toBottomOf(title)
            .height(constant: 1)
    }
}

// MARK: Binding

private extension SMFTPOPCell {
    func bindViews() {
        viewModel.outputs.title.bind(to: title.rx.text).disposed(by: disposeBag)
        viewModel.outputs.showsSeperator.map{ !$0 }.bind(to: separator.rx.isHidden).disposed(by: disposeBag)
    }
}
