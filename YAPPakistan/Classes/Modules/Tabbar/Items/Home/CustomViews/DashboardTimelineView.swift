//
//  DashboardTimelineView.swift
//  YAPPakistan
//
//  Created by Yasir on 11/04/2022.
//

import Foundation
import YAPComponents
import RxSwift
import RxTheme
import UIKit

class DashboardTimelineView: UIView {
    
   
    
    private lazy var title = UIFactory.makeLabel(font: .micro,alignment: .left)
    private lazy var icon = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private lazy var button = UIFactory.makeButton(with: .micro, backgroundColor: .clear, title: "")
    
    // MARK: Properties
    
    var viewModel: DashboardTimelineViewModelType! {
        didSet {
            self.bindViews()
        }
    }
//    var viewModel = DashboardTimelineViewModel()
    private var themeService: ThemeService<AppTheme>!
    private let disposeBag = DisposeBag()
    
    // MARK: Initialization
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init(theme:ThemeService<AppTheme>, viewModel: Any) {
        super.init(frame: .zero)
        guard let viewModel = viewModel as? DashboardTimelineViewModelType else { return }
        self.viewModel = viewModel
        self.themeService = theme
        commonInit()
        bindViews()
        setupTheme()
        setupResources()
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
    
}

// MARK: View setup

private extension DashboardTimelineView {
    func setupViews() {
        addSubview(title)
        addSubview(icon)
        addSubview(button)
    }
    
    func setupConstraints() {
        icon
            .alignEdgeWithSuperview(.left,constant: 28)
            .width(constant: 22)
            .height(constant: 22)
            .centerVerticallyInSuperview()
        title
            .toRightOf(icon,constant: 8)
            .centerVerticallyWith(icon)
            .toLeftOf(button)
        
        button
            .alignEdgesWithSuperview([.right], constants: [20])
            .centerVerticallyWith(icon)
            
    }
    
    func render() {
       
    }
    
    func setupTheme() {
        themeService.rx
        
            .bind({ UIColor($0.primaryDiffuse) }, to: [self.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark) }, to: [title.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [icon.rx.tintColor,button.rx.titleColor(for: .normal)])
            
        
            .disposed(by: rx.disposeBag)
    }
    
    func setupResources() {
        icon.image = UIImage.init(named: "timeline_account_verification", in: .yapPakistan)
    }
}

// MARK: Binding

private extension DashboardTimelineView {
    func bindViews() {
        viewModel.outputs.model.withUnretained(self).subscribe(onNext: { `self`, model in
            self.title.text = model.title
            self.icon.image = model.leftIcon
            self.button.setTitle(model.btnTitle, for: .normal)
            self.button.isEnabled = model.isBtnEnabled
        }).disposed(by: disposeBag)
        
        button.rx.tap.bind(to: viewModel.inputs.btnObserver).disposed(by: disposeBag)
    }
}
