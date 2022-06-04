//
//  SendMoneyHomeBeneficiaryCell.swift
//  YAPPakistan
//
//  Created by Awais on 15/03/2022.
//

import Foundation
import YAPComponents
import RxTheme

class SendMoneyHomeBeneficiaryCell: RxSwipeTableViewCell {

    // MARK: Views
    
    private lazy var userImage = UIFactory.makeImageView(tintColor: UIColor.red, contentMode: .scaleAspectFill)
    private lazy var nickName = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0)
    private lazy var fullName = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0)
    private lazy var nameStack: UIStackView = UIFactory.makeStackView(axis: .vertical, alignment: .leading, spacing: 2, arrangedSubviews: [nickName, fullName])
    private lazy var typeImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private lazy var flag = UIFactory.makeImageView(contentMode: .scaleAspectFit)

    // MARK: Properties
    var viewModel: SendMoneyHomeBeneficiaryCellViewModel!
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
        guard let vm = viewModel as? SendMoneyHomeBeneficiaryCellViewModel else { return }
        self.themeService = themeService
        self.viewModel = vm
        setupViews()
        setupConstraints()
        bindViews()
        setupTheme()
    }
}

// MARK: View setup

private extension SendMoneyHomeBeneficiaryCell {
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark)}, to: [nickName.rx.textColor])
            .bind({ UIColor($0.greyDark)}, to: [fullName.rx.textColor])//[searchBarButtonItem.barItem.rx.tintColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupViews() {
        contentView.addSubview(userImage)
        contentView.addSubview(nameStack)
        contentView.addSubview(typeImage)
        contentView.addSubview(flag)
    }

    func setupConstraints() {
        userImage
            .alignEdgesWithSuperview([.top, .left, .bottom], constants: [10, 25, 10])
            .height(constant: 42)
            .width(constant: 42)

        nameStack
            .toRightOf(userImage, constant: 15)
            .centerVerticallyWith(userImage)

        flag
            .alignEdgeWithSuperview(.right, constant: 25)
            .alignEdge(.centerY, withView: userImage)
            .height(constant: 25)
            .width(constant: 25)

        typeImage
            .alignEdge(.centerY, withView: userImage)
            .toLeftOf(flag, constant: 12)
            .height(constant: 26)
            .width(constant: 26)
            .toRightOf(nameStack, constant: 12)
    }

    func render() {
        userImage.roundView()
    }
}

// MARK: Binding

private extension SendMoneyHomeBeneficiaryCell {
    func bindViews() {
        viewModel.outputs.image.bind(to: userImage.rx.loadImage()).disposed(by: disposeBag)
        viewModel.outputs.name.bind(to: nickName.rx.text).disposed(by: disposeBag)
        viewModel.outputs.fullName.bind(to: fullName.rx.text).disposed(by: disposeBag)
        viewModel.outputs.typeIcon.bind(to: typeImage.rx.image).disposed(by: disposeBag)
        viewModel.outputs.flag.bind(to: flag.rx.image).disposed(by: disposeBag)
        viewModel.outputs.typeColor.subscribe(onNext: { [weak self] in self?.typeImage.tintColor = $0 }).disposed(by: disposeBag)
        viewModel.outputs.shimmering.bind(to: nickName.rx.isShimmerOn).disposed(by: disposeBag)
        viewModel.outputs.shimmering.bind(to: fullName.rx.isShimmerOn).disposed(by: disposeBag)
        viewModel.outputs.shimmering.bind(to: userImage.rx.isShimmerOn).disposed(by: disposeBag)
    }
}
