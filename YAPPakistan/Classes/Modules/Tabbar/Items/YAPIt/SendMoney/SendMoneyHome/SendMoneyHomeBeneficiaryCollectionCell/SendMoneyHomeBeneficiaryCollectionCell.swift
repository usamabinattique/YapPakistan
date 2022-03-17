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

//    private lazy var userImage: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()

    
    private lazy var nickName = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0)
    private lazy var fullName = UIFactory.makeLabel(font: .micro, alignment: .center, numberOfLines: 0)
    
    //private lazy var nickname = UIFactory.makeLabel(with: .primaryDark, textStyle: .small)
    //private lazy var fullName = UILabelFactory.createUILabel(with: .greyDark, textStyle:  .micro)

//    private lazy var nameStack: UIStackView = UIFactory.makeStackView(axis: .vertical, alignment: .leading, spacing: 2, arrangedSubviews: [nickName, fullName])
    
//    private lazy var nameStack: UIStackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .leading, spacing: 2, arrangedSubviews: [nickname, fullName])

    private lazy var typeImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    
//    private lazy var typeImage: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .center
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()

    private lazy var flag = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    
//    private lazy var flag: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()

    // MARK: Properties

    var viewModel: SendMoneyHomeBeneficiaryCollectionCellViewModel!
    private var themeService: ThemeService<AppTheme>!

    // MARK: Initialization
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    
//    override init(style: UICollectionViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        commonInit()
//    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        //selectionStyle = .none

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
        
        guard let vm = viewModel as? SendMoneyHomeBeneficiaryCollectionCellViewModel else { return }
        self.themeService = theme
        self.viewModel = vm
        
//        setupBindings()
//        setupTheme()
//        setupResources()
        setupViews()
        setupConstraints()
        bindViews()
        setupTheme()
        
    }
    
//    override func configure(with themeService: ThemeService<AppTheme>, viewModel: Any) {
//
//
//        guard let vm = viewModel as? SendMoneyHomeBeneficiaryCollectionCellViewModel else { return }
//        self.themeService = themeService
//        self.viewModel = vm
//
////        setupBindings()
////        setupTheme()
////        setupResources()
//        setupViews()
//        setupConstraints()
//        bindViews()
//        setupTheme()
//    }

//    override func configure(with viewModel: Any) {
//        guard let viewModel = viewModel as? SendMoneyHomeBeneficiaryCellViewModelType else { return }
//        self.viewModel = viewModel
//        bindViews()
//    }
}

// MARK: View setup

private extension SendMoneyHomeBeneficiaryCoolectionCell {
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark)}, to: [nickName.rx.textColor])
            .bind({ UIColor($0.greyDark)}, to: [fullName.rx.textColor])//[searchBarButtonItem.barItem.rx.tintColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupViews() {
        contentView.addSubview(userImage)
        contentView.addSubview(nickName)
//        contentView.addSubview(typeImage)
//        contentView.addSubview(flag)
    }

    func setupConstraints() {
        userImage
            .alignEdgesWithSuperview([.left, .top, .right], constants: [10, 10, 10])
            .height(constant: 42)
            .width(constant: 42)
        
        nickName
            .toBottomOf(userImage, constant: 5)
            .centerHorizontallyWith(userImage)

//        nameStack
//            .toRightOf(userImage, constant: 15)
//            .verticallyCenterWith(userImage)

//        flag
//            .alignEdgeWithSuperview(.right, constant: 25)
//            .alignEdge(.centerY, withView: userImage)
//            .height(constant: 25)
//            .width(constant: 25)
//
//        typeImage
//            .alignEdge(.centerY, withView: userImage)
//            .toLeftOf(flag, constant: 12)
//            .height(constant: 26)
//            .width(constant: 26)
//            .toRightOf(nameStack, constant: 12)
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
        viewModel.outputs.fullName.bind(to: fullName.rx.text).disposed(by: disposeBag)
        viewModel.outputs.typeIcon.bind(to: typeImage.rx.image).disposed(by: disposeBag)
        viewModel.outputs.flag.bind(to: flag.rx.image).disposed(by: disposeBag)
        viewModel.outputs.typeColor.subscribe(onNext: { [weak self] in self?.typeImage.tintColor = $0 }).disposed(by: disposeBag)
        viewModel.outputs.shimmering.bind(to: nickName.rx.isShimmerOn).disposed(by: disposeBag)
        viewModel.outputs.shimmering.bind(to: fullName.rx.isShimmerOn).disposed(by: disposeBag)
        viewModel.outputs.shimmering.bind(to: userImage.rx.isShimmerOn).disposed(by: disposeBag)
    }
}
