//
//  AddressViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 19/10/2021.
//

import YAPComponents
import RxTheme
import RxSwift

class AddressViewController: UIViewController {

    private let titleLabel = UIFactory.makeLabel(font: .title2, alignment: .center, numberOfLines: 0)
    private let subTitleLabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0)

    private let mapImageView = UIFactory.makeImageView(contentMode: .scaleAspectFill)
    private let tapContainer = UIFactory.makeCircularView()
    private let tapImageView = UIFactory.makeImageView()
    private let tapLabel = UIFactory.makeLabel(font: .micro)

    private let addressTextField = UIFactory.makeFloatingTextField(font: .regular,
                                                                   fontPlaceholder: .small,
                                                                   clearButtonMode: .always,
                                                                   returnKeyType: .done,
                                                                   capitalization: .words)
    private let flatTextField = UIFactory.makeFloatingTextField(font: .regular,
                                                                fontPlaceholder: .small,
                                                                clearButtonMode: .always,
                                                                returnKeyType: .done,
                                                                capitalization: .words)
    private lazy var cityTextField = UIFactory.makeFloatingTextField(font: .regular,
                                                                     fontPlaceholder: .small,
                                                                     capitalization: .words,
                                                                     keyboardType: nil)

    private let nextButton = UIFactory.makeAppRoundedButton(with: .regular)

    private var backButton: UIButton!
    private var nextButtonBottomAncher: NSLayoutConstraint!

    private var themeService: ThemeService<AppTheme>!
    var viewModel: AddressViewModelType!

    convenience init(themeService: ThemeService<AppTheme>, viewModel: AddressViewModelType) {
        self.init(nibName: nil, bundle: nil)

        self.themeService = themeService
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTheme()
        setupResources()
        setupLanguageStrings()
        setupBindings()
        setupConstraints()
    }

    func setupViews() {
        view
            .addSub(view: titleLabel)
            .addSub(view: subTitleLabel)
            .addSub(view: mapImageView)
            .addSub(view: addressTextField)
            .addSub(view: flatTextField)
            .addSub(view: cityTextField)
            .addSub(view: nextButton)

        mapImageView
            .addSub(view: tapContainer)

        tapContainer
            .addSub(view: tapImageView)
            .addSub(view: tapLabel)

        backButton = addBackButton(of: .backEmpty)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: subTitleLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: nextButton.rx.backgroundColor)
            .bind({ UIColor($0.greyDark) }, to: addressTextField.placeholderLabel.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: addressTextField.rx.textColor)
            .bind({ UIColor($0.greyLight) }, to: addressTextField.rx.bottomLineColorNormal)
            .bind({ UIColor($0.primary) }, to: addressTextField.rx.bottomLineColorWhileEditing)
            .bind({ UIColor($0.greyDark) }, to: flatTextField.placeholderLabel.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: flatTextField.rx.textColor)
            .bind({ UIColor($0.greyLight) }, to: flatTextField.rx.bottomLineColorNormal)
            .bind({ UIColor($0.primary) }, to: flatTextField.rx.bottomLineColorWhileEditing)
            .bind({ UIColor($0.greyDark) }, to: cityTextField.placeholderLabel.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: cityTextField.rx.textColor)
            .bind({ UIColor($0.greyLight) }, to: cityTextField.rx.bottomLineColorNormal)
            .bind({ UIColor($0.greyLight) }, to: cityTextField.rx.bottomLineColorWhileEditing)
            .bind({ UIColor($0.primary) }, to: tapContainer.rx.backgroundColor)
            .bind({ UIColor($0.backgroundColor) }, to: tapLabel.rx.textColor)
            .bind({ UIColor($0.backgroundColor) }, to: tapImageView.rx.tintColor)
            .bind({ UIColor($0.greyDark) }, to: addressTextField.rx.clearImageTint)
            .bind({ UIColor($0.greyDark) }, to: flatTextField.rx.clearImageTint)
            .bind({ UIColor($0.primary) }, to: backButton.rx.tintColor)
            .disposed(by: rx.disposeBag)
    }

    func setupResources() {
        mapImageView.image = UIImage(named: "map_image", in: .yapPakistan)
        tapImageView.image = UIImage(named: "location_icon", in: .yapPakistan)?.template
        let image = UIImage(named: "icon_close", in: .yapPakistan)?.asTemplate
        addressTextField.setClearImage(image, for: .normal)
        flatTextField.setClearImage(image, for: .normal)
    }

    func setupLanguageStrings() {
        viewModel.outputs.languageStrings.withUnretained(self)
            .subscribe(onNext: { `self`, strings in
                self.titleLabel.text = strings.title
                self.subTitleLabel.text = strings.subTitle
                self.tapLabel.text = strings.location
                self.addressTextField.placeholder = strings.address
                self.flatTextField.placeholder = strings.flatnumber
                self.cityTextField.placeholder = strings.city
                self.nextButton.setTitle(strings.next, for: .normal)
            })
            .disposed(by: rx.disposeBag)
    }

    func setupBindings() {
        viewModel.outputs.citySelected.bind(to: cityTextField.rx.text).disposed(by: rx.disposeBag)

        let editingDidBegin = cityTextField.rx.controlEvent(.editingDidBegin).share()
        editingDidBegin.bind(to: viewModel.inputs.cityObserver).disposed(by: rx.disposeBag)
        editingDidBegin.map({ _ in false }).bind(to: cityTextField.rx.isFirstResponder ).disposed(by: rx.disposeBag)
        backButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)

        addressTextField.rx.controlEvent(.editingDidBegin).withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                UIView.animate(withDuration: 0.3) {
                    self.nextButtonBottomAncher.constant = 90
                    self.view.layoutSubviews()
                }
            }).disposed(by: rx.disposeBag)

        flatTextField.rx.controlEvent(.editingDidBegin).withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                UIView.animate(withDuration: 0.3) {
                    self.nextButtonBottomAncher.constant = 165
                    self.view.layoutSubviews()
                }
            }).disposed(by: rx.disposeBag)

        addressTextField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] _ in guard let self = self else { return }
                UIView.animate(withDuration: 0.3) {
                    self.nextButtonBottomAncher.constant = 25
                    self.view.layoutSubviews()
                }
            }).disposed(by: rx.disposeBag)

        flatTextField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] _ in guard let self = self else { return }
                UIView.animate(withDuration: 0.3) {
                    self.nextButtonBottomAncher.constant = 25
                    self.view.layoutSubviews()
                }
            }).disposed(by: rx.disposeBag)

        view.rx.tapGesture().withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.view.endEditing(true) })
            .disposed(by: rx.disposeBag)
    }

    func setupConstraints() {
        titleLabel
            .alignEdgesWithSuperview([.left, .right, .safeAreaTop], constants: [20, 20, 10])

        subTitleLabel
            .toBottomOf(titleLabel, constant: 10)
            .alignEdgesWithSuperview([.left, .right], constant: 20)

        mapImageView
            .toBottomOf(subTitleLabel, constant: 10)
            .alignEdgesWithSuperview([.left, .right])
        tapContainer
            .alignEdgesWithSuperview([.left, .bottom], constants: [13, 10])
            .height(constant: 35)
        tapImageView
            .alignEdgesWithSuperview([.left, .top, .bottom], constants: [12, 8, 8])
            .aspectRatio()
        tapLabel
            .alignEdgesWithSuperview([.right], constant: 8)
            .toRightOf(tapImageView, constant: 5)
            .centerVerticallyWith(tapImageView)

        addressTextField
            .toBottomOf(mapImageView, constant: 20)
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
            .height(constant: 55)

        flatTextField
            .toBottomOf(addressTextField, constant: 20)
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
            .height(constant: 55)

        cityTextField
            .toBottomOf(flatTextField, constant: 20)
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
            .height(constant: 55)

        nextButton
            .toBottomOf(cityTextField, constant: 25)
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.safeAreaBottom, constant: 25, assignTo: &nextButtonBottomAncher)
            .width(constant: 250)
            .height(constant: 52)
    }
}
