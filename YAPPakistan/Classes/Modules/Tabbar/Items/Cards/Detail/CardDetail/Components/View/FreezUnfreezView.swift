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
        icon
            .alignEdgesWithSuperview([.top, .bottom, .left], constants: [6, 6, 16])
            .width(constant: 21)
            .height(constant: 21)
        label
            .toRightOf(icon, constant: 5)
            .alignEdgesWithSuperview([.top, .bottom])
        button
            .toRightOf(label)
            .alignEdgesWithSuperview([.top, .bottom, .right], constants: [0, 0, 16])
    }

    private func themeSetup() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ icon.rx.tintColor ])
            .bind({ UIColor($0.backgroundColor) }, to: [ label.rx.textColor ])
            .bind({ UIColor($0.backgroundColor) }, to: [ button.rx.titleColor(for: .normal) ])
            .bind({ UIColor($0.primary) }, to: [ rx.backgroundColor ])
            .disposed(by: rx.disposeBag)
    }

    private func setupResources() {
        icon.image = UIImage(named: "iconsLock", in: .yapPakistan)
        label.text = "This card is frozen"
        button.setTitle("Unfreeze now", for: .normal)
        button.underline()
    }
}
