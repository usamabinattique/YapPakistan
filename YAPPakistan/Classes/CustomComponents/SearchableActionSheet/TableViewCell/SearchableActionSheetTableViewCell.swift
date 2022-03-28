//
//  SearchableActionSheetTableViewCell.swift
//  YAPPakistan
//
//  Created by Yasir on 14/03/2022.
//

import UIKit
import RxSwift
import YAPComponents
import RxTheme

class SearchableActionSheetTableViewCell: RxUITableViewCell {
    
    // MARK: - Views
    
    private lazy var icon = UIFactory.makeImageView(contentMode: .scaleAspectFit) //UIImageViewFactory.createImageView(mode: .scaleAspectFit)
    
    private lazy var titleLabel = UIFactory.makeLabel(font:.regular) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .regular)
    
    private lazy var stack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fill, spacing: 35, arrangedSubviews: [icon, titleLabel])
    
    // MARK: - Properties
    
    private var viewModel: SearchableActionSheetTableViewCellViewModelType!
    
    // MARK: - Initialization
    
    private func commonInit() {
        selectionStyle = .none
        setupViews()
        setupConstraints()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: - Configurations
    
    override func configure(with themeService: ThemeService<AppTheme> ,viewModel: Any) {
        guard let `viewModel` = viewModel as? SearchableActionSheetTableViewCellViewModelType else { return }
        self.viewModel = viewModel
        bindViews(viewModel)
    }
    
}

// MARK: - View setup

private extension SearchableActionSheetTableViewCell {
    func setupViews() {
        contentView.addSubview(stack)
    }
    
    func setupConstraints() {
        stack
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .alignEdgesWithSuperview([.top, .bottom])
        
        icon
            .height(constant: 24)
            .width(constant: 24)
            .alignEdgesWithSuperview([.top, .bottom], constant: 10)
    }
}

// MARK: - Binding

private extension SearchableActionSheetTableViewCell {
    func bindViews(_ viewModel: SearchableActionSheetTableViewCellViewModelType) {
        viewModel.outputs.icon.bind(to: icon.rx.image).disposed(by: disposeBag)
        viewModel.outputs.showsIcon.map{ !$0 }.bind(to: icon.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.selected
            .subscribe(onNext: { [weak self] in
                print($0)
               // self?.contentView.backgroundColor = $0 ? UIColor.greyLight.withAlphaComponent(0.14) : .white
            }).disposed(by: disposeBag)
        viewModel.outputs.showsAttributedTitle.filter{ $0 }.withLatestFrom(viewModel.outputs.attributedTitle).bind(to: titleLabel.rx.attributedText).disposed(by: disposeBag)
        viewModel.outputs.showsAttributedTitle.filter{ !$0 }.withLatestFrom(viewModel.outputs.title).bind(to: titleLabel.rx.text).disposed(by: disposeBag)
    }
}
