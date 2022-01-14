//
//  YapItTileCell.swift
//  YAPPakistan
//
//  Created by Umair  on 05/01/2022.
//

import Foundation
import YAPComponents
import RxTheme

class YapItTileCell: RxUICollectionViewCell {
    
    // MARK: - Views
    
    private lazy var iconImage = UIFactory.makeImageView(contentMode: .center)
    
    private lazy var title = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0, lineBreakMode: .byTruncatingTail)
    
    private lazy var borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var flag = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    
    private lazy var flagView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    
    private var viewModel: YapItTileCellViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    // MARK: - Initialization
    
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
    
    // MARK: - View cycle
    
    override func draw(_ rect: CGRect) {
        render()
    }
    
    // MARK: - Configuration
    
    override func configure(with viewModel: Any, theme: ThemeService<AppTheme>) {
        guard let model = viewModel as? YapItTileCellViewModelType else { return }
        self.viewModel = model
        self.themeService = theme
        bindViews(model)
        setupTheme()
    }
    
}

// MARK: - View Setup

private extension YapItTileCell {
    func setupViews() {
        contentView.addSubview(borderView)
        contentView.addSubview(iconImage)
        contentView.addSubview(title)
        contentView.addSubview(flagView)
        flagView.addSubview(flag)
    }
    
    func setupConstraints() {
        borderView
            .alignAllEdgesWithSuperview()
        
        iconImage
            .alignEdgeWithSuperview(.top, constant: 18)
            .centerHorizontallyInSuperview()
            .height(constant: 42)
            .width(constant: 42)
        
        title
            .alignEdgesWithSuperview([.left, .right], constant: 10)
            .toBottomOf(iconImage, constant: 11)
            .alignEdgeWithSuperview(.bottom, .greaterThanOrEqualTo, constant: 10)
        
        flagView
            .alignEdge(.left, withView: iconImage, constant: -5)
            .alignEdge(.top, withView: iconImage, constant: -4)
            .width(constant: 19)
            .height(constant: 19)
        
        flag
            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constant: 2)
    }
    
    func render() {
        flagView.roundView()
        flag.roundView()
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [title.rx.textColor])
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - Binding

private extension YapItTileCell {
    func bindViews(_ viweModel: YapItTileCellViewModelType) {
        viewModel.outputs.iconName.map { UIImage.init(named: $0, in: .yapPakistan, compatibleWith: nil) }.bind(to: iconImage.rx.image).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: title.rx.text).disposed(by: disposeBag)
        
        let flagImage = viewModel.outputs.flag.map{ $0 == nil ? nil : UIImage.sharedImage(named: $0!) }
        flagImage.bind(to: flag.rx.image).disposed(by: disposeBag)
        flagImage.map{ $0 == nil }.bind(to: flagView.rx.isHidden).disposed(by: disposeBag)
    }
}


enum YapItTileCellIconType {
    case imageIcon
    case roundedWithTintedIcon
    case roundedWithoutTintedIcon
}
