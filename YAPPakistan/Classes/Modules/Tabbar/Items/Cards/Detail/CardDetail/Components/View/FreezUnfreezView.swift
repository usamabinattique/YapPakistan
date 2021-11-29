//
//  FreezUnfreezView.swift
//  ios-b2c-pk-components
//
//  Created by Sarmad on 26/11/2021.
//

import YAPComponents
import RxTheme

class FreezUnfreezView: UIView {
    let icon = UIFactory.makeImageView()
    let label = UIFactory.makeLabel(font: .small)
    let button = UIFactory.makeButton(with: .small)

    //Properties
    private var themeService: ThemeService<AppTheme>!

    convenience init(themeService: ThemeService<AppTheme>) {
        self.init(frame: .zero)
        self.themeService = themeService

        self.initialSetup()
        self.makeUI()
        self.setupLaoutContraints()
        self.themeSetup()
        self.setupResources()
    }

    private func initialSetup() {
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func makeUI() {
        addSub(views: [icon, label, button])
    }

    private func setupLaoutContraints() {

    }

    private func themeSetup() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ label.rx.textColor ])
            .bind({ UIColor($0.backgroundColor) }, to: [ button.rx.titleColor(for: .normal) ])
            .disposed(by: rx.disposeBag)
    }

    private func setupResources() {
        
    }
}
