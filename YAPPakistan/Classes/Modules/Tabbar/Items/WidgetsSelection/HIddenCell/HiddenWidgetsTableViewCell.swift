//
//  HiddenWidgetsTableViewCell.swift
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

class HiddenWidgetsTableViewCell: RxUITableViewCell {

    private var categoryNameText: UILabel = UIFactory.makeLabel(font: .small) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small)
    
    private var trailingButton = UIButtonFactory.createButton( backgroundColor: .clear)
    
    private lazy var iconBackgroundView: UIView = {
        let view = UIView()
//        view.backgroundColor = UIColor.appColor(ofType: .paleLilac)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var leadingIcon = UIFactory.makeImageView() //UIImageViewFactory.createImageView()
    
    private var viewModel: HiddenWidgetsCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    private var stack = UIStackViewFactory.createStackView(with: .horizontal, alignment: .fill, distribution: .fill, spacing: 20)

    private var stackLeading: NSLayoutConstraint!
    
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
        guard let viewModel = viewModel as? HiddenWidgetsCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bind()
    }
}

extension HiddenWidgetsTableViewCell {
    
    func setupViews() {
        contentView.backgroundColor = .white
        iconBackgroundView.addSubview(leadingIcon)
        stack.addArrangedSubview(iconBackgroundView)
        stack.addArrangedSubview(categoryNameText)
        addSubview(stack)
        addSubview(trailingButton)
    }
    
    func setupConstraints() {
       
        stack
        .alignEdgesWithSuperview([.left,.top,.bottom], constants: [22, 10, 10])
        .toLeftOf(trailingButton)
        
        iconBackgroundView
            .height(constant: 40)
            .aspectRatio()
        
        leadingIcon
            .height(constant: 19)
            .aspectRatio()
            .centerInSuperView()
        
        trailingButton
            .height(constant: 25)
            .aspectRatio()
            .alignEdgeWithSuperview(.right, constant: 25)
            .centerVerticallyInSuperview()
        
    }
    
    func bind() {
        viewModel.outputs.labelText.bind(to: categoryNameText.rx.text).disposed(by: disposeBag)
        viewModel.outputs.leadingIcon.unwrap().bind(to: leadingIcon.rx.loadImage()).disposed(by: disposeBag)
        trailingButton.rx.tap.subscribe(onNext: {[weak self] in
            self?.viewModel.inputs.addButtonObserver.onNext(self?.categoryNameText.text)
        }).disposed(by: disposeBag)
        viewModel.outputs.trailingIcon.bind(to: trailingButton.rx.image(for: .normal)).disposed(by: disposeBag)
    }
}

