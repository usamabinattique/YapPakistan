//
//  HideWidgetPopup.swift
//  YAPPakistan
//
//  Created by Yasir on 21/04/2022.
//

import UIKit
import YAPCore
import RxCocoa
import RxSwift
import YAPComponents
import RxTheme

class HideWidgetPopup: UIView {

    private var headerLabel = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 1, lineBreakMode: .byClipping, text: "Widgets are Hidden", adjustFontSize: true) //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .regular, alignment: .center, numberOfLines: 1, lineBreakMode: .byClipping, text: "Widgets are Hidden", alpha: 1.0, adjustFontSize: true)
    
    private var descriptionLabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0, lineBreakMode: .byClipping, text: "screen_hide_widget_popup_description".localized) //UILabelFactory.createUILabel(with: .greyDark, textStyle: .small, alignment: .center, numberOfLines: 0, lineBreakMode: .byClipping, text: "screen_hide_widget_popup_description".localized, alpha: 1.0, adjustFontSize: true)
    
    private var hideWidgetButton = AppRoundedButtonFactory.createAppRoundedButton(title: "Hide Widgets")
    private var cancelButton = UIButtonFactory.createButton(title: "Cancel", backgroundColor: .clear)
    
    let viewModel = HideWidgetPopupContentViewModel()
    private var themeService: ThemeService<AppTheme>!
    private let disposeBag = DisposeBag()
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init(theme:ThemeService<AppTheme>) {
        super.init(frame: .zero)
      //  guard let viewModel = viewModel as? DashboardTimelineViewModelType else { return }
//        self.viewModel = viewModel
        self.themeService = theme
        commonInit()
        setupTheme()
//        setupResources()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        setupViews()
        setupConstraints()
        bind()
    }
}

extension HideWidgetPopup {
    func setupViews() {
        addSubview(headerLabel)
        addSubview(descriptionLabel)
        addSubview(hideWidgetButton)
        addSubview(cancelButton)
    }
    
    func setupConstraints() {
        headerLabel
            .alignEdgesWithSuperview([.top, .left, .right], constants: [35,15, 15])
            .height(constant: 24)
            .centerHorizontallyInSuperview()
        
        descriptionLabel
            .toBottomOf(headerLabel, constant: 10)
            .alignEdgesWithSuperview([.left, .right], constant: 10)
            .height(constant: 80)
            .centerHorizontallyInSuperview()
        
        hideWidgetButton
            .toBottomOf(descriptionLabel, constant: 28)
            .height(constant: 52)
            .width(constant: 192)
            .centerHorizontallyInSuperview()
        
        cancelButton
            .toBottomOf(hideWidgetButton, constant: 13)
            .width(constant: 192)
            .height(constant: 28)
            .centerHorizontallyInSuperview()
        
    }
    
    func setupTheme() {
        themeService.rx
        
            .bind({ UIColor($0.greyDark) }, to: [descriptionLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark) }, to: [headerLabel.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [cancelButton.rx.titleColor(for: .normal), hideWidgetButton.rx.backgroundColor])
            
        
            .disposed(by: rx.disposeBag)
    }
    
    func bind() {
        hideWidgetButton.rx.tap.bind(to: viewModel.hideWidgetObserver).disposed(by: disposeBag)
        cancelButton.rx.tap.bind(to: viewModel.cancelObserver).disposed(by: disposeBag)
    }
}

// MARK: Reactive
 extension Reactive where Base: HideWidgetPopup {

    var hideWidgets: Observable<Void> {
        return self.base.viewModel.hideWidget
    }
    
    var cancel: Observable<Void> {
        return self.base.viewModel.cancel
    }
}
