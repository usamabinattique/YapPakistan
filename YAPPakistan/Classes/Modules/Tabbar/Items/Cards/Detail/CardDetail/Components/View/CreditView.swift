//
//  CreditView.swift
//  ios-b2c-pk-components
//
//  Created by Sarmad on 26/11/2021.
//

import YAPComponents
import RxTheme

class CreditView: UIView {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public let title = UIFactory.makeLabel(font: .small)
    public let balanceLabel = UIFactory.makeLabel(font: .title3)

    //Properties
    private var themeService: ThemeService<AppTheme>
    private var viewModel: CreditViewModel

    init(viewModel: CreditViewModel, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(frame: .zero)

        self.initialSetup()
        self.makeUI()
        self.bindViewModel()
        self.setupLaoutContraints()
        self.themeSetup()
    }

    private func initialSetup() {
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func makeUI() {
        addSub(views: [title, balanceLabel])
    }

    private func bindViewModel() {
        viewModel.outputs.title.bind(to: title.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.balance.bind(to: balanceLabel.rx.text).disposed(by: rx.disposeBag)
    }

    private func setupLaoutContraints() {
        title
            .alignEdgeWithSuperview(.top)
            .centerHorizontallyInSuperview()
        balanceLabel
            .toBottomOf(title, constant: 5)
            .alignEdgeWithSuperview(.bottom)
            .centerHorizontallyInSuperview()
    }

    private func themeSetup() {
        themeService.rx
            .bind({ UIColor($0.greyDark) }, to: [ title.rx.textColor ])
            .bind({ UIColor($0.primaryDark) }, to: [ balanceLabel.rx.textColor ])
            .disposed(by: rx.disposeBag)
    }
}
