//
//  CardOptionPickerCollectionViewCell.swift
//  YAPPakistan
//
//  Created by Umair  on 26/12/2021.
//

import Foundation
import YAPComponents
import RxTheme

class CardOptionPickerCollectionViewCell: RxUICollectionViewCell {
    
    //MARK: - Views
    lazy var iconImageView = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    lazy var titleLabel = UIFactory.makeLabel(font: .micro)
    lazy var contentStackView = UIFactory.makeStackView(axis: .vertical, alignment: .center, distribution: .fillProportionally, spacing: 15, arrangedSubviews: nil)
    
    var themeService: ThemeService<AppTheme>?
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selection
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.backgroundColor = self!.isSelected ? UIColor((self?.themeService!.attrs.greyLight)!) : UIColor.clear
            }
        }
    }
    
    func setupViews() {
        contentStackView.addArrangedSubviews([iconImageView])
        contentStackView.addArrangedSubviews([titleLabel])
        
        addSubview(contentStackView)
        contentStackView.centerInSuperView()
        layer.cornerRadius = 12.0
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1
    }
    
    func setupTheme() {
        themeService!.rx
            .bind({ UIColor($0.primaryDark) }, to: [titleLabel.rx.textColor])
            .disposed(by: rx.disposeBag)
    }
    
    // MARK: - Configure
    func configure(with optionPickerItem: OptionPickerItem<PaymentCardBlockOption>, themeService: ThemeService<AppTheme>) {
        self.themeService = themeService
        iconImageView.image = optionPickerItem.icon
        titleLabel.text = optionPickerItem.title
//        iconImageView.tintColor =
        setupTheme()
    }
}
