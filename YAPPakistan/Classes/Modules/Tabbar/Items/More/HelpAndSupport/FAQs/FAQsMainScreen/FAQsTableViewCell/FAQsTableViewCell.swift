//
//  FAQsTableViewCell.swift
//  YAPPakistan
//
//  Created by Awais on 18/05/2022.
//

import Foundation
import YAPComponents
import RxSwift
import RxTheme

class FAQsTableViewCell: RxUITableViewCell {
    
    // MARK: Views
    
    private lazy var question = UIFactory.makeLabel(font: .small, numberOfLines: 0)
    private lazy var nextImage = UIFactory.makeImageView()
    
    
    // MARK: Properties
    
    var viewModel: FAQsTableViewCellViewModelType!
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
        guard let viewModel = viewModel as? FAQsTableViewCellViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = themeService
        bindViews()
        setupTheme()
        setupResources()
    }
    
}

// MARK: View setup

private extension FAQsTableViewCell {
    func setupViews() {
        //contentView.addSubview(userImage)
        contentView.addSubview(question)
        contentView.addSubview(nextImage)
    }
    
    func setupConstraints() {
        question
            .centerHorizontallyInSuperview()
            .alignEdgesWithSuperview([.left, .right, .safeAreaTop, .safeAreaBottom], constants: [10, 40, 10, 10])

        nextImage
            //.centerHorizontallyInSuperview()
            .alignEdgesWithSuperview([.safeAreaRight])
            .centerVerticallyWith(question)
            .toRightOf(question)
            .height(constant: 12)
            .width(constant: 12)
        
    }
    
    func render() {
        //userImage.roundView()
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [question.rx.textColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupResources() {
        nextImage.image = UIImage(named: "icon_next", in: .yapPakistan)
    }
}

// MARK: Binding

private extension FAQsTableViewCell {
    func bindViews() {
        
        viewModel.outputs.question.bind(to: question.rx.text).disposed(by: disposeBag)
        
//        viewModel.outputs.bankImage.bind(to: userImage.rx.loadImage()).disposed(by: disposeBag)
//
//        //userImage.rx.loadImage()
//
//        viewModel.outputs.name.bind(to: name.rx.text).disposed(by: disposeBag)
//
//        viewModel.outputs.shimmering.bind(to: name.rx.isShimmerOn).disposed(by: disposeBag)
//        viewModel.outputs.shimmering.bind(to: userImage.rx.isShimmerOn).disposed(by: disposeBag)
//        viewModel.outputs.shimmering.subscribe(onNext: { [weak self] (value) in
//            if value {
//
//            }
//        }).disposed(by: disposeBag)
    }
}
