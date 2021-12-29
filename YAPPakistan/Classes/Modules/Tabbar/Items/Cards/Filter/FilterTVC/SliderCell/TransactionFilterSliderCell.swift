//
//  TransactionFilterSliderCell.swift
//  YAPPakistan
//
//  Created by Umair  on 22/12/2021.
//

import Foundation
import YAPComponents
import UIKit
import RxTheme

class TransactionFilterSliderCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var separator: UIView = UIFactory.makeView()
    
    private lazy var title = UIFactory.makeLabel(font: .regular)
    
    private lazy var range = UIFactory.makeLabel(font: .regular, alignment: .right) //UILabelFactory.createUILabel(with: .primary, textStyle: .regular, alignment: .right)
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.tintColor = UIColor.blue
        slider.setThumbImage(UIImage(named: "icon_map_pin_purple", in: .yapPakistan), for: .normal)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    // MARK: Properties
    var themeService: ThemeService<AppTheme>!
    var viewModel: TransactionFilterSliderCellViewModelType!
    
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
    
    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
        self.themeService = themeService
        guard let viewModel = viewModel as? TransactionFilterSliderCellViewModelType else { return }
        self.viewModel = viewModel
        bindViews()
        setupTheme()
    }
}

// MARK: View setup

private extension TransactionFilterSliderCell {
    func setupViews() {
        contentView.addSubview(separator)
        contentView.addSubview(title)
        contentView.addSubview(range)
        contentView.addSubview(slider)
        
        range.adjustsFontSizeToFitWidth = true
    }
    
    func setupConstraints() {
        
        separator
            .alignEdgesWithSuperview([.left, .top, .right], constants: [25, 20, 25])
            .height(constant: 1)
        
        title
            .alignEdgeWithSuperview(.left, constant: 25)
            .toBottomOf(separator, constant: 20)
        
        range
            .alignEdgeWithSuperview(.right, constant: 25)
            .alignEdge(.centerY, withView: title)
            .toRightOf(title, constant: 10)
        
        slider
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .toBottomOf(title, constant: 20)
            .height(constant: 30)
            .alignEdgeWithSuperview(.bottom)
    }
    
    func setupTheme(){
        themeService.rx
            .bind({ UIColor($0.greyDark) }, to: [title.rx.textColor])
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [range.rx.textColor])
        
            .disposed(by: rx.disposeBag)
    }
}

// MARK: Binding

private extension TransactionFilterSliderCell {
    func bindViews() {
        
        viewModel.outputs.progress.map { Float($0) }.subscribe(onNext: { [weak self] in
            self?.slider.setValue($0, animated: true)
        }).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: title.rx.text).disposed(by: disposeBag)
        viewModel.outputs.range.bind(to: range.rx.text).disposed(by: disposeBag)
        
        slider.rx.value.map { CGFloat($0) }.bind(to: viewModel.inputs.progressObserver).disposed(by: disposeBag)
    }
}
