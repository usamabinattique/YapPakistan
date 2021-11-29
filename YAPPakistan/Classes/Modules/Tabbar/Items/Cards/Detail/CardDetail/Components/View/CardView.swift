//
//  CardView.swift
//  ios-b2c-pk-components
//
//  Created by Sarmad on 26/11/2021.
//

import YAPComponents
import RxTheme
import RxSwift

class CardView: UIView {

    private let container = UIFactory.makeView()
    private let righView = UIFactory.makeView()
    public let leftImage = UIFactory.makeImageView()
    public let title = UIFactory.makeLabel(font: .small)
    public let subTitle = UIFactory.makeLabel(font: .micro)
    public let subsubTitleContainer = UIFactory.makeView()
    public let subsubTitle = UIFactory.makeLabel(font: .micro)
    public let subsubTitleIcon = UIFactory.makeImageView()
    public let detailsButton = UIFactory.makeAppRoundedButton(with: .small)

    //Properties
    var viewModel: CardViewModel!
    private var themeService: ThemeService<AppTheme>!

    convenience init(viewModel: CardViewModel, themeService: ThemeService<AppTheme>) {
        self.init(frame: .zero)
        self.viewModel = viewModel
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
        addSub(view: container)
        container.addSub(views: [ righView, leftImage ])
        righView.addSub(views: [ title, subTitle, subsubTitleContainer, detailsButton ])
        subsubTitleContainer.addSub(views: [subsubTitleIcon, subsubTitle])
    }

    private func setupLaoutContraints() {
        container
            .alignEdgesWithSuperview([.top, .bottom])
            .centerHorizontallyInSuperview()
        leftImage
            .alignEdgesWithSuperview([.top, .bottom, .left])
            .aspectRatio(134 / 84)
        righView
            //.widthEqualTo(view: leftImage)
            .toRightOf(leftImage, constant: 20)
            .alignEdgesWithSuperview([.right])
            .centerVerticallyInSuperview()

        title
            .alignEdgesWithSuperview([.top, .left, .right])

        subTitle
            .toBottomOf(title, constant: 8)
            .alignEdgesWithSuperview([.left, .right])

        subsubTitleContainer
            .toBottomOf(subTitle, constant: 8)
            .alignEdgesWithSuperview([.left, .right])
        subsubTitleIcon
            .alignEdgesWithSuperview([.left])
            .centerVerticallyInSuperview()
            .aspectRatio().height(constant: 16)
        subsubTitle
            .toRightOf(subsubTitleIcon, constant: 6)
            .alignEdgesWithSuperview([.right, .top, .bottom])

        detailsButton
            .toBottomOf(subsubTitleContainer, constant: 10)
            .alignEdgesWithSuperview([.left, .bottom])
            .width(constant: 110)
            .height(constant: 26)

    }

    private func themeSetup() {
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [ title.rx.textColor ])
            .bind({ UIColor($0.greyDark) }, to: [ subTitle.rx.textColor ])
            .bind({ UIColor($0.greyDark) }, to: [ subsubTitle.rx.textColor ])
            .bind({ UIColor($0.primary) }, to: [ detailsButton.rx.enabledBackgroundColor ])
            .bind({ UIColor($0.grey) }, to: [ detailsButton.rx.disabledBackgroundColor ])
            .bind({ UIColor($0.backgroundColor) }, to: [ detailsButton.rx.titleColor(for: .normal) ])
            .disposed(by: rx.disposeBag)
    }

    private func setupResources() {
        viewModel.outputs.resources.withUnretained(self)
            .subscribe(onNext: { `self`, resources in
                self.title.text = resources.title
                self.subTitle.text = resources.subtitle
                self.subsubTitle.text  = resources.subsubTitle
                self.detailsButton.setTitle(resources.buttonTitle, for: .normal)
                self.leftImage.image = UIImage(named: resources.leftImageName, in: .yapPakistan)
                self.subsubTitleIcon.image = UIImage(named: resources.subsubTitleIconName, in: .yapPakistan)
            })
            .disposed(by: rx.disposeBag)
    }
}
