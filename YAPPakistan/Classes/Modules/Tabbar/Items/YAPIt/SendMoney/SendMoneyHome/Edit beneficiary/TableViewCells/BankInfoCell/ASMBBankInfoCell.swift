//
//  ASMBBankInfoCell.swift
//  YAPPakistan
//
//  Created by Muhammad Sohaib on 16/03/2022.
//

import UIKit
import YAPCore
import YAPComponents
import RxSwift
import RxCocoa
import RxDataSources
import RxTheme

class ASMBBankInfoCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var bankImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var name = UIFactory.makeLabel(font: .regular) //primaryDark, //greyDark
    
    private lazy var address = UIFactory.makeLabel(font: .micro, numberOfLines: 0)
    
    private lazy var bottomBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Properties
    private var themeService: ThemeService<AppTheme>!
    private var viewModel: ASMBBankInfoCellViewModelType!
    
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
        setupView()
        setupConstraints()
        setupSensitiveViews()
    }
    
    // MARK: View cycle

    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        render()
    }
    
    // MARK: Configurations
    
    override public func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? ASMBBankInfoCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
        setupTheme()
    }
    
}

// MARK: View setup

private extension ASMBBankInfoCell {
    func setupView() {
        contentView.addSubviews([bankImage, name, address, bottomBar])
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark)}, to: [name.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [address.rx.textColor])
            .bind({ UIColor($0.separatorColor) }, to: [bottomBar.rx.backgroundColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupConstraints() {
        
        bankImage
            .alignEdgesWithSuperview([.left, .top], constants: [30, 0])
            .width(constant: 17.5)
            .height(constant: 17.5)
        
        name
            .toRightOf(bankImage, constant: 14)
            .alignEdge(.centerY, withView: bankImage)
        
        address
            .toBottomOf(name, constant: 4)
            .alignEdge(.left, withView: name)
        
        bottomBar
            .height(constant: 1)
            .toBottomOf(address, constant: 14)
            .alignEdgesWithSuperview([.left, .right, .bottom], constants: [25, 25, 31])
    }
    
    func setupSensitiveViews() {
        //UIView.markSensitiveViews([bankImage, name, address])
    }
    
    func render() {
        bankImage.roundView()
    }
}

// MARK: Binding

private extension ASMBBankInfoCell {
    func bindViews() {
        viewModel.outputs.image.bind(to: bankImage.rx.loadImage()).disposed(by: disposeBag)
        viewModel.outputs.name.bind(to: name.rx.text).disposed(by: disposeBag)
        viewModel.outputs.address.bind(to: address.rx.text).disposed(by: disposeBag)
    }
}
