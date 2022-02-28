//
//  NameLettersSequenceSelectionCell.swift
//  YAPPakistan
//
//  Created by Yasir on 04/02/2022.
//

import UIKit
import YAPComponents
import RxTheme

class NameLettersSequenceSelectionCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var title = UIFactory.makeLabel(font: .regular)
    
    private lazy var checkBox: YAPCheckBox = {
        let checkBox = YAPCheckBox(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        checkBox.checkedWithAnimation = false
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        checkBox.imageView.image = UIImage.init(named: "icon_check", in: .yapPakistan)?.asTemplate
        checkBox.imageView.tintColor = .white
        checkBox.layer.cornerRadius = checkBox.frame.size.height / 2
        return checkBox
    }()
    
    // MARK: Properties
    
    var themeService: ThemeService<AppTheme>!
    var viewModel: NameLettersSequenceSelectionCellViewModelType!
    var isChecked: ((Bool) -> Void)?
    
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
        
        guard let viewModel = viewModel as? NameLettersSequenceSelectionCellViewModelType else { return }
        self.viewModel = viewModel
        bindViews()
        setupTheme()
        setupResources()
    }
}

// MARK: View setup

private extension NameLettersSequenceSelectionCell {
    func setupViews() {
        contentView.addSubview(title)
        contentView.addSubview(checkBox)
    }
    
    func setupConstraints() {
        checkBox
            .alignEdgeWithSuperview(.left, constant: 6)
            .alignEdgesWithSuperview([.top, .bottom], constant: 16)
            .width(constant: 24)
            .height(constant: 24)
        
        title
            .alignEdgeWithSuperview(.right, constant: 6)
            .centerVerticallyWith(checkBox)
            .toRightOf(checkBox,constant: 28)
    }
    
    func setupTheme(){
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [title.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [checkBox.rx.fillColor])
        
            .disposed(by: rx.disposeBag)
    }
    
    func setupResources() {
    }
}

// MARK: Binding

private extension NameLettersSequenceSelectionCell {
    func bindViews() {
        let checkShare = viewModel.outputs.check.share()
        checkShare.bind(to: checkBox.rx.checked).disposed(by: disposeBag)
        
        checkShare.subscribe(onNext: { [unowned self] isChecked in
            self.checkBox.backgroundColor =  isChecked ? UIColor(Color(hex: "#5E35B1")) : .clear
        }).disposed(by: disposeBag)
        
        viewModel.outputs.title.bind(to: title.rx.text).disposed(by: disposeBag)
//        checkBox.rx.checked.bind(to: viewModel.inputs.checkObserver).disposed(by: disposeBag)
        
        checkBox.rx.checked.skip(1).subscribe(onNext: { [unowned self] isCheckedBox in
            self.isChecked?(isCheckedBox)
        }).disposed(by: disposeBag)

    }
}
