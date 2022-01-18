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
    
    private lazy var range = UIFactory.makeLabel(font: .regular, alignment: .right)
    
    private lazy var sliderContainer = UIFactory.makeView()
    private lazy var customSlider = YAPRangeSliderFactory()
    
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
        //contentView.addSubview(slider)
        sliderContainer.addSubview(customSlider)
        contentView.addSubview(sliderContainer)
        
        range.adjustsFontSizeToFitWidth = true
        sliderContainer.clipsToBounds = false
        customSlider.maxValue = 1000
        customSlider.minValue = 0
//        customSlider.delegate = self
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
        
        sliderContainer
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .toBottomOf(title, constant: 20)
            .height(constant: 30)
            .alignEdgeWithSuperview(.bottom)
        customSlider
            .alignEdgesWithSuperview([.left, .right])
            .centerVerticallyInSuperview()
            .height(constant: 30)
    }
    
    func setupTheme(){
        themeService.rx
            .bind({ UIColor($0.greyDark) }, to: [title.rx.textColor])
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [range.rx.textColor])
            .bind({ UIColor($0.greyLight) }, to: [separator.rx.backgroundColor])
        
            .disposed(by: rx.disposeBag)
        
        customSlider.setupStyle(for: self.themeService)
    }
}

// MARK: Binding

private extension TransactionFilterSliderCell {
    func bindViews() {
        
//        viewModel.outputs.progress.map { Float($0) }.subscribe(onNext: { [weak self] in
//            print($0)
//            //self?.slider.setValue($0, animated: true)
//        }).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: title.rx.text).disposed(by: disposeBag)
        viewModel.outputs.range.bind(to: range.rx.text).disposed(by: disposeBag)
        
        customSlider.rx.didChange.bind(to: viewModel.inputs.progressObserver).disposed(by: disposeBag)
       
//        viewModel.outputs.selectedRange
//            .map({ range in
//                print("lower rang is \(range.lowerBound)")
//                print("upper rang is \(range.upperBound)")
//            })
        
        viewModel.outputs.selectedRange.subscribe(onNext: { [unowned self] range in
            self.customSlider.selectedMinValue = range.lowerBound
            self.customSlider.selectedMaxValue = range.upperBound
           
        }).disposed(by: rx.disposeBag) 

//        viewModel.outputs.selectedRange.bind(to: customSlider.rx.did)
//                viewModel.outputs.selectedRange.bind(to: customSlider.rx.didChange).disposed(by: disposeBag)
        
        
        
//        viewModel.outputs.progress.map { Float($0) }.subscribe(onNext: { [weak self] in
//          //  self?.slider.setValue($0, animated: true)
//        }).disposed(by: disposeBag)
        
      //  slider.rx.value.map { CGFloat($0) }.bind(to: viewModel.inputs.progressObserver).disposed(by: disposeBag)
        
    }
}
