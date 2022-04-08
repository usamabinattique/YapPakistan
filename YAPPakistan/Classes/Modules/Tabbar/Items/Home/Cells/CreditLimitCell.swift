//
//  CreditLimitCell.swift
//  YAPPakistan
//
//  Created by Yasir on 31/03/2022.
//

import Foundation
import YAPComponents
import RxSwift
import RxTheme
import UIKit

class CreditLimitCell: RxUITableViewCell {
    
    // MARK: Views
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.backgroundColor = UIColor(Color(hex: "#F1EDFF"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var limitLabel = UIFactory.makeLabel(font: .micro,alignment: .center)
    private lazy var infoButton: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        btn.setImage(UIImage(named: "icon_info", in: .yapPakistan)?.asTemplate, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: Properties
    
    var viewModel: CreditLimitCellViewModelType!
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
    
    // MARK: View cycle
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        render()
    }
    
    // MARK: Configurations
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        guard let viewModel = viewModel as? CreditLimitCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
        setupTheme()
        setupResources()
    }
    
}

// MARK: View setup

private extension CreditLimitCell {
    func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(limitLabel)
        containerView.addSubview(infoButton)
    }
    
    func setupConstraints() {
        containerView
            .alignEdgesWithSuperview([.top, .left, .right ,.bottom], constants: [0, 24, 24, 0])
        limitLabel
            .alignEdgesWithSuperview([.top, .bottom], constants: [12, 12])
            .centerHorizontallyInSuperview()
        infoButton
            .width(constant: 20)
            .aspectRatio()
            .toRightOf(limitLabel,constant: 8)
            .centerVerticallyWith(limitLabel)
    }
    
    func render() {
       
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.greyDark) }, to: [limitLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [infoButton.rx.tintColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupResources() {
       
    }
}

// MARK: Binding

private extension CreditLimitCell {
    func bindViews() {
        
        
        viewModel.outputs.credit.bind(to: limitLabel.rx.attributedText).disposed(by: disposeBag)
        infoButton.rx.tap.bind(to: viewModel.inputs.creditInfo).disposed(by: disposeBag)
//        viewModel.outputs.shimmering.bind(to: name.rx.isShimmerOn).disposed(by: disposeBag)
//        viewModel.outputs.shimmering.bind(to: userImage.rx.isShimmerOn).disposed(by: disposeBag)
    }
}
