//
//  SendMoneyHomeBeneficiaryCell.swift
//  YAPPakistan
//
//  Created by Awais on 15/03/2022.
//

import Foundation
import YAPComponents
import RxTheme

class SendMoneyHomeBeneficiaryCoolectionCell: RxUICollectionViewCell {

    // MARK: Views
    private lazy var userImage = UIFactory.makeImageView(tintColor: UIColor.red, contentMode: .scaleAspectFill)
    private lazy var nickName = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0)

    // MARK: Properties
    var viewModel: SendMoneyHomeBeneficiaryCollectionCellViewModelType!
    private var themeService: ThemeService<AppTheme>!

    // MARK: Initialization
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {

        setupViews()
        setupConstraints()
    }

    // MARK: View cycle

    override func layoutIfNeeded() {
        super.layoutIfNeeded()

        render()
    }

    // MARK: Configurations
    
    
    override func configure(with viewModel: Any, theme: ThemeService<AppTheme>) {
        
        guard let vm = viewModel as? SendMoneyHomeBeneficiaryCollectionCellViewModelType else { return }
        self.themeService = theme
        self.viewModel = vm
        setupViews()
        setupConstraints()
        bindViews()
        setupTheme()
    }
}

// MARK: View setup

private extension SendMoneyHomeBeneficiaryCoolectionCell {
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark)}, to: [nickName.rx.textColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupViews() {
        contentView.addSubview(userImage)
        contentView.addSubview(nickName)
    }

    func setupConstraints() {
        userImage
            .alignEdgesWithSuperview([.left, .top, .right], constants: [10, 10, 10])
            .height(constant: 42)
            .width(constant: 42)
        
        nickName
            .toBottomOf(userImage, constant: 5)
            .centerHorizontallyWith(userImage)
    }

    func render() {
        userImage.roundView()
    }
}

// MARK: Binding

private extension SendMoneyHomeBeneficiaryCoolectionCell {
    func bindViews() {
        viewModel.outputs.image.bind(to: userImage.rx.loadImage()).disposed(by: disposeBag)
        viewModel.outputs.name.bind(to: nickName.rx.text).disposed(by: disposeBag)
        viewModel.outputs.shimmering.bind(to: nickName.rx.isShimmerOn).disposed(by: disposeBag)
        viewModel.outputs.shimmering.bind(to: userImage.rx.isShimmerOn).disposed(by: disposeBag)
    }
}
