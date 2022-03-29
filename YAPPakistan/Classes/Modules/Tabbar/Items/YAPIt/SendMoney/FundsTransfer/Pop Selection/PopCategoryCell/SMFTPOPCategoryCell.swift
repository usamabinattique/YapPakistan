//
//  SMFTPOPCategoryCell.swift
//  YAPPakistan
//
//  Created by Yasir on 29/03/2022.
//

import UIKit
import YAPCore
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme

class SMFTPOPCategoryCell: RxUITableViewCell {

    // MARK: Views
    
    private lazy var title = UIFactory.makeLabel(font: .small, alignment: .left, numberOfLines: 0, lineBreakMode: .byWordWrapping) // UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small, alignment: .left, numberOfLines: 0, lineBreakMode: .byWordWrapping)
    
    private lazy var dropdownArrow: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor.gray // ?
        imageView.image = UIImage.init(named: "icon_drop_down", in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }() //UIImageViewFactory.createImageView(mode: .center, image: UIImage.sharedImage(named: "icon_drop_down")?.asTemplate, tintColor: .primaryDark)
    
    private lazy var stack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 5, arrangedSubviews: [title, dropdownArrow])
    
    private lazy var separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Properties
    
    private var viewModel: SMFTPOPCategoryCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initializaion
    
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
        guard let viewModel = viewModel as? SMFTPOPCategoryCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
        setupTheme()
    }
    
    @objc
    private func tapped(_ tap: UITapGestureRecognizer) {
        viewModel.inputs.tapObserver.onNext(())
    }

}

// MARK: View setup

private extension SMFTPOPCategoryCell {
    func setupViews() {
        contentView.addSubview(stack)
        contentView.addSubview(separator)
        contentView.isUserInteractionEnabled = true
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
        contentView.backgroundColor = .white
    }
    
    func setupConstraints() {
        stack
            .alignEdgesWithSuperview([.left, .top, .right], constants: [25, 12, 25])
        
        dropdownArrow
            .width(constant: 26)
            .height(constant: 26)
        
        separator
            .toBottomOf(stack, constant: 12)
            .alignEdgesWithSuperview([.left, .right, .bottom])
            .height(constant: 1)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.greyLight) }, to: [separator.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark) }, to: [title.rx.textColor])
            .disposed(by: rx.disposeBag)
    }
}

// MARK: Binding

private extension SMFTPOPCategoryCell {
    func bindViews() {
        viewModel.outputs.title.bind(to: title.rx.text).disposed(by: disposeBag)
        viewModel.outputs.showsDropdown.map{ !$0 }.bind(to: dropdownArrow.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.dropdownOpened.subscribe(onNext: { [weak self] in
            self?.separator.backgroundColor = $0 ? UIColor.groupTableViewBackground.darker(by: 10) : .lightGray//.greyLight
            self?.dropdownArrow.transform = CGAffineTransform(scaleX: 1, y: $0 ? -1 : 1)
        }).disposed(by: disposeBag)
    }
}
