//
//  AddTopupPCCVCell.swift
//  YAPPakistan
//
//  Created by Yasir on 10/02/2022.
//

import UIKit
import RxSwift
import RxCocoa
import YAPComponents
import YAPCore
import RxDataSources
import RxTheme

class AddTopupPCCVCell: RxUICollectionViewCell {

    // MARK: Views
    private lazy var background: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 2
      //  view.layer.borderColor = UIColor.lightGray.cgColor //UIColor.greyLight.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var addButton: UIVerticalButton = {
        let button = UIVerticalButtonFactory.createVerticalButton(image: UIImage(named: "icon_add_money_debit_credit_card", in: .yapPakistan, compatibleWith: nil))
        button.titleLable.font = .micro
       // button.titleLable.textColor = .primaryDark
        button.stackView.spacing = 14
        button.isUserInteractionEnabled = false
        return button
    }()
    
    // MARK: Properties
    
    private var viewModel: AddTopupPCCVCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: Configuration
    override func configure(with viewModel: Any, theme: ThemeService<AppTheme>) {
        guard let model = viewModel as? AddTopupPCCVCellViewModelType else { return }
        self.viewModel = model
        self.themeService = theme
        bindViews()
        setupTheme()
    }
    
    private func commonInit() {
        setupViews()
        setupConstraints()
    }
    
    // MARK: View cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        render()
        
        background.layer.masksToBounds = false
        background.layer.shadowColor = UIColor.black.cgColor
        background.layer.shadowOffset = CGSize(width: 0, height: 0)
        background.layer.shadowOpacity = 0.08
        background.layer.shadowRadius = 10
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        render()
    }

}

private extension AddTopupPCCVCell {
    func setupViews() {
        contentView.addSubview(background)
        background.addSubview(addButton)
    }
    
    func setupTheme() {
        themeService.rx
//            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark) }, to: [addButton.titleLable.rx.textColor])
            .bind({ UIColor($0.primaryLight).withAlphaComponent(0.50).cgColor }, to: [background.layer.rx.borderColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupConstraints() {
        background
            .alignAllEdgesWithSuperview()
        
        addButton
        .centerInSuperView()
    }
    
    func render() {
        background.layer.shadowColor = UIColor.black.cgColor
        background.layer.shadowOpacity = 0.2
        background.layer.shadowOffset = CGSize(width: 0, height: 0)
        background.layer.shadowRadius = 15
        contentView.clipsToBounds = false
        clipsToBounds = false
    }
}

// MARK: Binding

private extension AddTopupPCCVCell {
    func bindViews() {
        viewModel.outputs.addCardButtonTitle.unwrap().subscribe(onNext: { [weak self] title in
            self?.addButton.title = "+ " + title
//            self?.addButton.titleLable.text =
            print("title is \(title)")
        }).disposed(by: disposeBag)
    }
}
