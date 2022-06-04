//
//  AnalyticsStatsView.swift
//  YAPPakistan
//
//  Created by Yasir on 20/05/2022.
//

import UIKit
import YAPCore
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme

public class AnalyticsStatsView: UIView {
    
    public lazy var valueLabel: UILabel = UIFactory.makeLabel(font: .regular, alignment: .center, text: "88%") //UILabelFactory.createUILabel(with: .primaryDark, textStyle: .regular, alignment: .center, text: "88%")
    
    public lazy var nameLabel: UILabel = UIFactory.makeLabel(font: .micro, alignment: .center, text: "monthly spend") //UILabelFactory.createUILabel(with: .greyDark, textStyle: .micro, alignment: .center, text: "monthly spend")
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var themeService: ThemeService<AppTheme>!
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init(theme:ThemeService<AppTheme>) {
        super.init(frame: .zero)
        self.themeService = theme
        commonInit()
        //bindViews()
        setupTheme()
      //  setupResources()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    internal func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        setupViews()
        setupConstraints()
    }
    
    fileprivate func setupViews() {
        addSubview(containerView)
        containerView.addSubview(valueLabel)
        containerView.addSubview(nameLabel)
    }
    
    fileprivate func setupConstraints() {
        valueLabel
            .alignEdgesWithSuperview([.top, .left, .right], constants: [0, 0, 0])
        
        nameLabel
            .alignEdgesWithSuperview([.bottom, .left, .right], constants: [0, 0, 0])
            .toBottomOf(valueLabel, constant: 2)
        
        containerView
            .centerVerticallyInSuperview()
            .centerHorizontallyInSuperview()
            .alignEdgesWithSuperview([.left, .right], constants: [3, 3])
    }
    
    fileprivate  func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.greyDark       ) }, to: [nameLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark    ) }, to: [valueLabel.rx.textColor])
            .disposed(by: disposeBag)
    }
    
}

extension Reactive where Base: AnalyticsStatsView {
    var value: Binder<String?> {
        return self.base.valueLabel.rx.text
    }
    
    var name: Binder<String?> {
        return self.base.nameLabel.rx.text
    }
}

