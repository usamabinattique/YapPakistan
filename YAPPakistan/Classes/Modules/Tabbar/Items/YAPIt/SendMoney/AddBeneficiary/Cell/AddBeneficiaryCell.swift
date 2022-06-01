//
//  AddBeneficiaryCell.swift
//  YAPPakistan
//
//  Created by Yasir on 15/03/2022.
//

import Foundation
import YAPComponents
import RxSwift
import RxTheme

class AddBeneficiaryCell: RxUITableViewCell {
    
    // MARK: Views
    private lazy var userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var name = UIFactory.makeLabel(font: .small)
    
    private lazy var nameStack = UIFactory.makeStackView(axis: .vertical, alignment: .leading, distribution: .fill, spacing: 4, arrangedSubviews: [name])
    
    // MARK: Properties
    
    var viewModel: AddBeneficiaryCellViewModelType!
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
        guard let viewModel = viewModel as? AddBeneficiaryCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
        setupTheme()
        setupResources()
    }
    
}

// MARK: View setup

private extension AddBeneficiaryCell {
    func setupViews() {
        contentView.addSubview(userImage)
        contentView.addSubview(name)
    }
    
    func setupConstraints() {
        userImage
            .alignEdgesWithSuperview([.top, .left, .bottom], constants: [10, 25, 10])
            .height(constant: 42)
            .width(constant: 42)
        
        name
            .toRightOf(userImage, constant: 15)
            .alignEdge(.centerY, withView: userImage)
    }
    
    func render() {
        userImage.roundView()
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [name.rx.textColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupResources() {
       
    }
}

// MARK: Binding

private extension AddBeneficiaryCell {
    func bindViews() {
        
        viewModel.outputs.bankImage.bind(to: userImage.rx.loadImage(isStringPath: true)).disposed(by: disposeBag)
        
        //userImage.rx.loadImage()
        
        viewModel.outputs.name.bind(to: name.rx.text).disposed(by: disposeBag)
        
        viewModel.outputs.shimmering.bind(to: name.rx.isShimmerOn).disposed(by: disposeBag)
        viewModel.outputs.shimmering.bind(to: userImage.rx.isShimmerOn).disposed(by: disposeBag)
        viewModel.outputs.shimmering.subscribe(onNext: { [weak self] (value) in
            if value {
               
            }
        }).disposed(by: disposeBag)
    }
}
