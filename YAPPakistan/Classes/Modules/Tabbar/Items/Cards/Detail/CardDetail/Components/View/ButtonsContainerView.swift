//
//  ButtonsContainerView.swift
//  ios-b2c-pk-components
//
//  Created by Sarmad on 26/11/2021.
//
// swiftlint:disable identifier_name

import YAPComponents
import RxTheme

class ButtonsContainerView: UIView {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    let b1Container = UIFactory.makeView()
    let button1_0 = UIFactory.makeButton(with: .small)
    let button1_1 = UIFactory.makeButton(with: .small)

    let b2Container = UIFactory.makeView()
    let button2_0 = UIFactory.makeButton(with: .small)
    let button2_1 = UIFactory.makeButton(with: .small)

    let spacers = [UIFactory.makeView(), UIFactory.makeView(), UIFactory.makeView()]

    //Properties
    private var viewModel: ButtonsContainerViewModel!
    private var themeService: ThemeService<AppTheme>!

    init(viewModel: ButtonsContainerViewModel, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(frame: .zero)

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
        addSub(views: [b1Container, b2Container])
        b1Container.addSub(views: [ button1_0, button1_1])
        b2Container.addSub(views: [ button2_0, button2_1])
        addSub(views: spacers)
    }

    private func setupLaoutContraints() {
        spacers[0]
            .alignEdgesWithSuperview([.top, .bottom, .left])

        b1Container
            .toRightOf(spacers[0])
            .alignEdgesWithSuperview([.top, .bottom])

        spacers[1]
            .toRightOf(b1Container)
            .alignEdgesWithSuperview([.top, .bottom])

        b2Container
            .toRightOf(spacers[1])
            .alignEdgesWithSuperview([.top, .bottom])

        spacers[2]
            .toRightOf(b2Container)
            .alignEdgesWithSuperview([.top, .bottom, .right])

        spacers[0]
            .widthEqualTo(view: spacers[1])
            .widthEqualTo(view: spacers[2])

        button1_0
            .alignEdgesWithSuperview([.top, .left, .right])
        button1_1
            .toBottomOf(button1_0, constant: 4)
            .alignEdgesWithSuperview([.left, .right, .bottom])

        button2_0
            .alignEdgesWithSuperview([.top, .left, .right])
        button2_1
            .toBottomOf(button2_0, constant: 4)
            .alignEdgesWithSuperview([.left, .right, .bottom])
    }

    private func themeSetup() {
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [ button1_1.rx.titleColor(for: .normal) ])
            .bind({ UIColor($0.primary) }, to: [ button2_1.rx.titleColor(for: .normal) ])
            .disposed(by: rx.disposeBag)
    }

    private func setupResources() {
        viewModel.outputs.resources.withUnretained(self)
            .subscribe(onNext: { `self`, resources in
                self.button1_0.setImage(UIImage(named: resources.button1_0Image, in: .yapPakistan), for: .normal)
                self.button1_1.setTitle(resources.button1_1Title, for: .normal)
                self.button2_0.setImage(UIImage(named: resources.button2_0Image, in: .yapPakistan), for: .normal)
                self.button2_1.setTitle(resources.button2_1Title, for: .normal)
            })
            .disposed(by: rx.disposeBag)
    }
}
