//
//  WelcomeView.swift
//  YAPPakistan
//
//  Created by Yasir on 05/04/2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxTheme
import YAPComponents

public class WelcomeView: UIView {
    
    private lazy var icon = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private lazy var title = UIFactory.makeLabel(font: .micro, alignment: .left, numberOfLines: 0, lineBreakMode: .byWordWrapping)
    private lazy var breifDesc = UIFactory.makeLabel(font: .micro, alignment: .left, numberOfLines: 0, lineBreakMode: .byWordWrapping)
    private lazy var stack = UIFactory.makeStackView(axis: .vertical, alignment: .leading, distribution: .equalSpacing, spacing: 2)
    
    
    private lazy var separator: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 1
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var infoContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public let viewModel = WelcomeViewModel()
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!
    private let disposeBag = DisposeBag()
    private var themeService: ThemeService<AppTheme>!
    
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init(theme:ThemeService<AppTheme>) {
        super.init(frame: .zero)
        self.themeService = theme
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        setupViews()
        setupConstraints()
        setupTheme()
    }
}

//MARK:- View Setup

extension WelcomeView {

    func setupViews() {
        addSubview(icon)
        addSubview(infoContainer)
        infoContainer.addSubviews([title,breifDesc])
        addSubview(separator)
        bind()
    }
    
    func setupConstraints() {
        
        icon
            .alignEdgesWithSuperview([.left,.top,.bottom], constants: [16,16,16])
            .height(constant: 59)
            .width(constant: 59)
        
        infoContainer
            .toRightOf(icon,constant: 12)
            .centerVerticallyInSuperview()
            .alignEdgeWithSuperview(.right, constant: 16)
        
        title
            .alignEdgesWithSuperview([.left,.top,.right], constants: [0,0,0])
        
        breifDesc
            .toBottomOf(title,constant: 2)
            .alignEdgesWithSuperview([.left,.bottom,.right], constants: [0,0,0])
        
        separator
            .alignEdgesWithSuperview([.left,.right,.bottom], constants: [24,24,0])
            .height(constant: 0.7)
    }
}

//MARK:- Binding

extension WelcomeView {
    func bind() {
        viewModel.outputs.icon.bind(to: icon.rx.image).disposed(by: disposeBag)
        viewModel.outputs.title.bind(to: title.rx.text).disposed(by: disposeBag)
        viewModel.outputs.desc.bind(to: breifDesc.rx.text).disposed(by: disposeBag)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [title.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [breifDesc.rx.textColor])
            .bind({ UIColor($0.separatorColor).withAlphaComponent(0.76) }, to: [separator.rx.backgroundColor])
            .disposed(by: rx.disposeBag)
    }
}


