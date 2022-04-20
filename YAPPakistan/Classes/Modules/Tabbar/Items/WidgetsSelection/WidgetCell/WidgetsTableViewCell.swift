//
//  WidgetsTableViewCell.swift
//  YAPPakistan
//
//  Created by Yasir on 20/04/2022.
//

import UIKit
import RxSwift
import YAPCore
import YAPComponents
import RxCocoa
import RxTheme

class WidgetsTableViewCell: RxUITableViewCell {

    private var categoryNameText: UILabel = UIFactory.makeLabel(font: .small) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small)
    
    private lazy var iconBackgroundView: UIView = {
        let view = UIView()
       // view.backgroundColor = UIColor.appColor(ofType: .paleLilac)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var leadingIcon = UIFactory.makeImageView() //UIImageViewFactory.createImageView()
    
    private var viewModel: WidgetsCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    private var stack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .fill, distribution: .fill, spacing: 20)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        iconBackgroundView.roundView()
    }
    
    // MARK: Configuration    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? WidgetsCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bind()
    }
}

extension WidgetsTableViewCell {
    
    func setupViews() {
        contentView.backgroundColor = .white
        iconBackgroundView.addSubview(leadingIcon)
        stack.addArrangedSubview(iconBackgroundView)
        stack.addArrangedSubview(categoryNameText)
        addSubview(stack)
    }
    
    func setupConstraints() {
       
        stack
            .alignEdgesWithSuperview([.left,.top,.bottom, .right], constants: [55, 10, 10, 30])
        
        iconBackgroundView
            .height(constant: 40)
            .aspectRatio()
        
        leadingIcon
            .height(constant: 19)
            .aspectRatio()
            .centerInSuperView()
        
    }
    
    func bind() {
        viewModel.outputs.labelText.bind(to: categoryNameText.rx.text).disposed(by: disposeBag)
        viewModel.outputs.leadingIcon.unwrap().bind(to: leadingIcon.rx.loadImage()).disposed(by: disposeBag)
    }
}
