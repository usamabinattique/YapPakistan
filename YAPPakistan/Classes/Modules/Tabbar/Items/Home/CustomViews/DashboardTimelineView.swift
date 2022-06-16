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
    
    // MARK: Views
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var title = UIFactory.makeLabel(font: .regular,alignment: .left)
    private lazy var icon = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    private lazy var leftSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var descriptionLabel = UIFactory.makeLabel(font: .small,alignment: .left, numberOfLines: 2)
    private lazy var button = UIFactory.makeButton(with: .micro, backgroundColor: .clear, title: "")
    
    private lazy var statusVeiw: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 78, height: 20))
        view.clipsToBounds = true
        view.layer.cornerRadius = view.frame.size.height / 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var status = UIFactory.makeLabel(font: .micro,alignment: .center)
    
    // MARK: Properties
    
    var viewModel: DashboardTimelineViewModelType!
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
    
//    init(theme:ThemeService<AppTheme>) {
//        super.init(frame: .zero)
//        self.themeService = theme
//        commonInit()
//        bindViews()
//        setupTheme()
//        setupResources()
//    }
//
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
        addSubview(containerView)
        containerView.addSubview(icon)
        containerView.addSubview(leftSeparator)
        containerView.addSubview(title)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(button)
        containerView.addSubview(statusVeiw)
        statusVeiw.addSubview(status)
    }
    
    func setupConstraints() {
        containerView
            .alignEdgesWithSuperview([.top, .left, .right ,.bottom], constants: [16, 32, 32, 16])
            .height(constant: 150)
        icon
            .alignEdgesWithSuperview([.top, .left])
            .width(constant: 32)
            .height(constant: 32)
       // icon.backgroundColor = .blue
//        icon.translatesAutoresizingMaskIntoConstraints = false
//
//        title.translatesAutoresizingMaskIntoConstraints = false
        title
            .toRightOf(icon,constant: 20)
            //.alignEdgeWithSuperview(.top)
           // .alignEdge(.top, withView: icon)
            .centerVerticallyWith(icon)
            .toLeftOf(statusVeiw)
            .height(constant: 16)
        
     //   title.backgroundColor = .purple
        
        statusVeiw
            .alignEdgesWithSuperview([.top,.right])
            .width(constant: 78)
            .height(constant: 20)
        
//        status.translatesAutoresizingMaskIntoConstraints = false
        status
            .centerVerticallyInSuperview()
            .centerHorizontallyInSuperview()
        
//        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel
            .toBottomOf(title,constant: 4)
            .toRightOf(icon,constant: 20)
            .alignEdgeWithSuperview(.right)
        
        button
            .toBottomOf(descriptionLabel,constant: 8)
            .toRightOf(icon,constant: 20)
            .alignEdgeWithSuperview(.bottom,.greaterThanOrEqualTo, constant: 0)
            .height(constant: 34)
        
        leftSeparator
            .toBottomOf(icon,constant: 12)
            .width(constant: 1)
            .centerHorizontallyWith(icon)
            .alignEdge(.bottom, withView: button)
        
//        title.text = "Account verification"
//        descriptionLabel.text = "We noticed a mistake in your application. Please re-take a new a selfie."
//        status.text = "in process"
//        button.setTitle("Re-upload now", for: .normal)
        
        statusVeiw.backgroundColor = UIColor(Color(hex: "#FEEDDF"))
    }
    
    func render() {
       
    }
    
    func setupTheme() {
        themeService.rx
        
            .bind({ UIColor($0.greyDark) }, to: [descriptionLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [leftSeparator.rx.backgroundColor,title.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [button.rx.titleColor(for: .normal),status.rx.textColor])
            
        
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
