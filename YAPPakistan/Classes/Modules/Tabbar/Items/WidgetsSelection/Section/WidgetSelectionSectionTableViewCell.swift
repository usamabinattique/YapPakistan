//
//  WidgetSelectionSectionTableViewCell.swift
//  YAPPakistan
//
//  Created by Yasir on 20/04/2022.
//

import Foundation
import RxSwift
import RxCocoa
import YAPCore
import YAPComponents
import RxTheme

class WidgetSelectionSectionTableViewCell: RxUITableViewCell {

    private var headerText: UILabel = UIFactory.makeLabel(font: .small) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .small, text: "")
    private var activeText: UILabel = UIFactory.makeLabel(font: .small, text: "Active") //UILabelFactory.createUILabel(with: .primary, textStyle: .small, text: "Active")
    private var swipeText: UILabel = //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, text: "Swipe to hide")
    private var appSwitch = UIAppSwitchFactory.createUIAppSwitch()
    private var viewModel: WidgetSelectionSectionCellViewModel!
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
        setupConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: Configuration
    override public func configure(with viewModel: Any) {
        guard let viewModel = viewModel as? WidgetSelectionSectionCellViewModel else { return }
        self.viewModel = viewModel
        bind()
    }
}

extension WidgetSelectionSectionTableViewCell {
    
    func setupViews() {
        contentView.backgroundColor = .white
        addSubview(headerText)
        addSubview(appSwitch)
        addSubview(activeText)
        addSubview(swipeText)
    }
    
    func setupConstraints() {
        headerText
            .alignEdgeWithSuperview(.left, constant: 25)
            .alignEdgeWithSuperview(.top, constant: 25)
        
        appSwitch
            .width(constant: 53)
            .height(constant: 30)
            .alignEdgeWithSuperview(.right, constant: 25)
            .alignEdgeWithSuperview(.top, constant: 15)
            
        activeText
            .toBottomOf(headerText, constant: 29)
            .width(constant: 50)
            .alignEdgeWithSuperview(.left, constant: 25)
        
        swipeText
            .toRightOf(activeText)
            .alignCenterWith(activeText)
            .alignEdgeWithSuperview(.right, constant: 25)
    }
    
    func bind() {
        viewModel.outputs.hideSwitch.bind(to: appSwitch.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.hideSwitch.bind(to: activeText.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.hideSwitch.bind(to: swipeText.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.switchValue.bind(to: appSwitch.rx.isOn).disposed(by: disposeBag)
        appSwitch.rx.isOn.skip(1).bind(to: viewModel.inputs.switchObserver).disposed(by: disposeBag)
        
        viewModel.outputs.text.subscribe(onNext: {[weak self] in
            self?.headerText.text = $0
            self?.headerText.textColor = $1
        }).disposed(by: disposeBag)
    }
    
}
