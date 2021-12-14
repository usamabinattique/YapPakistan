//
//  KeypadTextView.swift
//  YAPPakistan
//
//  Created by Sarmad on 09/12/2021.
//
/*
import Foundation
import YAPComponents
import RxTheme

protocol KeypadTextViewType {

}

class KeypadTextView: UIView {
    private lazy var labelErrorContainer = UIFactory.makeView()
    private lazy var codeLabel = UIFactory.makeLabel(font: .title2, alignment: .center, charSpace: 10)
    private lazy var errorLabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0)
    private lazy var pinKeyboard = UIFactory.makePasscodeKeyboard(font: .title2)

    // Properties
    private var viewModel: KeypadTextViewType
    private var themeService: ThemeService<AppTheme>

    required init(viewModel: KeypadTextViewType, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(frame: .zero)
        commonInitializer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInitializer() {
        setupSubViews()
        setupResources()
        setupTheme()
        setupLocalizedStrings()
        setupBindings()
        setupConstraints()
    }
}

extension KeypadTextView {
    func setupSubViews() {
        addSub(views: [labelErrorContainer, pinKeyboard])
        labelErrorContainer.addSub(views: [codeLabel, errorLabel])
    }

    func setupResources() {
        //        let biomImgName: String = (.faceID == biometricsManager.deviceBiometryType) ?
        //            "icon_face_id": "icon_touch_id"
        //        let bioMImg = UIImage(named: biomImgName, in: .yapPakistan)
        //        let backImg = UIImage(named: "icon_delete_purple", in: .yapPakistan)
        //
        //        pinKeyboard.biomatryButton.setImage(bioMImg?.asTemplate, for: .normal)
        //        pinKeyboard.backButton.setImage(backImg?.asTemplate, for: .normal)
    }

    func setupTheme() {
        themeService.rx
            .bind({ _ in UIColor.clear }, to: [rx.backgroundColor])
            .bind({ UIColor($0.error          ) }, to: [errorLabel.rx.textColor])
            .bind({ UIColor($0.primary        ) }, to: [pinKeyboard.rx.themeColor])
            .bind({ UIColor($0.primary        ) }, to: [codeLabel.rx.textColor])
            .disposed(by: rx.disposeBag)
    }

    func setupLocalizedStrings() {

    }

    func setupBindings() {

    }

    func setupConstraints() {

    }
}
*/
