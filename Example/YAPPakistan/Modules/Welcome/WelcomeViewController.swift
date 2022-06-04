//
//  WelcomeViewController.swift
//  YAPPakistan_Example
//
//  Created by Umer on 13/10/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import AVKit
import RxTheme
import YAPComponents

class WelcomeViewController: UIViewController {

    // MARK: UI Components
    fileprivate lazy var signInContainer = UIFactory.makeView(alpha: 0).setHidden(true)
    fileprivate lazy var signInLabel = UIFactory.makeLabel(font: .regular)
    fileprivate lazy var signInButton = UIFactory.makeButton(with: .regular)
    fileprivate lazy var getStartedButton = UIFactory.makeButton(with: .regular).setHidden(true).setAlpha(0)
    fileprivate lazy var captionLabel = UIFactory.makeLabel(font: .regular, alignment: .center)
    fileprivate lazy var player = AVFactory.makePlayer(with: Resource(named: "get_started.mp4", in: Bundle.init(for: Self.self)))
    fileprivate lazy var playerLayer = AVFactory.makeAVPlayerLayer(with: player)

    // MARK: Properties
    fileprivate var captionDelays = [2.0, 1.5, 1.0, 1.5, 0.5, 1.8, 0.5, 2.0, 0.5, 2.0, 1.0, 2.5, 1.5, 2.0, 1.0, 3.0]
    fileprivate lazy var captions = { Array(repeating: "", count: captionDelays.count) }()
    fileprivate var currentCaption = 0
    fileprivate var stopped = true


    fileprivate var themeService: ThemeService<AppTheme>!
    var viewModel: WelcomeViewModelType!

    convenience init(themeService: ThemeService<AppTheme>, viewModel: WelcomeViewModelType) {
        self.init(nibName: nil, bundle: nil)
        self.themeService = themeService
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubViews()
        setupTheme()
        setupLocalizedStrings()
        setupConstraints()
        bindViews()

    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        render()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetVideo()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addNotificationObservers()
        startVideo()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        resetVideo()
    }

    private func addNotificationObservers() {
        NotificationCenter.default.rx
            .notification(.AVPlayerItemDidPlayToEndTime)
            .withUnretained(self)
            .subscribe{ $0.0.playerDidFinishPlaying() }
            .disposed(by: rx.disposeBag)

        NotificationCenter.default.rx
            .notification(.applicationWillResignActive)
            .withUnretained(self)
            .subscribe { $0.0.resetVideo() }
            .disposed(by: rx.disposeBag)

        NotificationCenter.default.rx
            .notification(.applicationDidBecomeActive)
            .withUnretained(self)
            .subscribe { $0.0.startVideo() }
            .disposed(by: rx.disposeBag)
    }

    @objc
    private func playerDidFinishPlaying() {
        resetVideo()
        startVideo()
    }
}

// MARK: Setup video

private extension WelcomeViewController {

    @objc
    func resetVideo() {
      /*  NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(animationCaption), object: nil) */
        stopped = true
        player.pause()
        player.seek(to: .zero)
        currentCaption = 0
        captionLabel.text = ""
      //  getStartedButton.isHidden = true
    //    getStartedButton.alpha = 0
     //   getStartedButton.isEnabled = false
     //   signInContainer.isHidden = true
     //   signInContainer.alpha = 0
      //  signInContainer.isUserInteractionEnabled = false
    }

    @objc
    func startVideo() {
        player.play()
        stopped = false
      /*  self.perform(#selector(animationCaption), with: nil, afterDelay: captionDelays[self.currentCaption]) */
        getStartedButton.isHidden = false
        signInContainer.isHidden = false
        self.getStartedButton.alpha = 1
        self.signInContainer.alpha = 1
    /*    UIView.animate(withDuration: 0.5, delay: captionDelays[0], animations: {
            self.getStartedButton.alpha = 1
            self.signInContainer.alpha = 1
        }, completion: { _ in
            self.getStartedButton.isEnabled = true
            self.signInContainer.isUserInteractionEnabled = true
        }) */
    }
}

// MARK: View setup

private extension WelcomeViewController {

    func setupSubViews() {
        view.layer
            .addSublayer(playerLayer)
        view
            .addSub(view: getStartedButton)
            .addSub(view: signInContainer)
            .addSub(view: signInLabel)
            .addSub(view: captionLabel)
        signInContainer
            .addSub(view: signInLabel)
            .addSub(view: signInButton)
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor   ) }, to: [view.rx.backgroundColor])
           /* .bind({ UIColor($0.greyLight         ) }, to: [signInLabel.rx.textColor])
            .bind({ UIColor($0.primaryExtraLight ) }, to: [signInButton.rx.titleColor(for: .normal)]) */
            .bind({ UIColor($0.primaryDark         ) }, to: [signInLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark ) }, to: [signInButton.rx.titleColor(for: .normal)])
        
            .bind({ UIColor($0.primary           ) }, to: [getStartedButton.rx.backgroundColor])
            .bind({ UIColor($0.primaryExtraLight ) }, to: [captionLabel.rx.textColor])
            .disposed(by: rx.disposeBag)
    }

    @objc func setupLocalizedStrings() {
        signInLabel.text = "screen_home_display_text_already_have".localized
        signInButton.setTitle("screen_home_button_sign_in".localized, for: .normal)
        getStartedButton.setTitle("screen_welcome_button_get_started".localized, for: .normal)
        self.captions = [
            "screen_waiting_list_caption_backyourway", .empty,
            "screen_waiting_list_caption_getanaccount", .empty,
            "screen_waiting_list_caption_moneytransfers", .empty,
            "screen_waiting_list_caption_trackyourspending", .empty,
            "screen_waiting_list_caption_splitbills", .empty,
            "screen_waiting_list_caption_spendlocally", .empty,
            "screen_waiting_list_caption_instantspending", .empty,
            "screen_waiting_list_caption_anappfor", .empty
        ].map{ $0.localized }
    }

    func setupConstraints() {

        signInContainer
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 20)
            .height(constant: 24)
            .centerHorizontallyInSuperview()

        signInLabel
            .alignEdgesWithSuperview([.top, .bottom, .left])

        signInButton
            .alignEdgesWithSuperview([.top, .bottom, .right])
            .toRightOf(signInLabel, constant: 5)

        getStartedButton
            .toTopOf(signInLabel, constant: 20)
            .width(constant: 210)
            .height(constant: 52)
            .centerHorizontallyInSuperview()

        captionLabel
            .toTopOf(getStartedButton, constant: 25)
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.left, constant: 25)

        playerLayer.frame = UIScreen.main.bounds
    }

    func render() {
      /*  signInLabel.layer.shadowColor = UIColor.black.cgColor
        signInLabel.layer.shadowRadius = 3
        signInLabel.layer.shadowOpacity = 0.7
        signInLabel.layer.shadowOffset = .zero
        signInLabel.layer.masksToBounds = false */

        captionLabel.layer.shadowColor = UIColor.black.cgColor
        captionLabel.layer.shadowRadius = 3
        captionLabel.layer.shadowOpacity = 0.7
        captionLabel.layer.shadowOffset = .zero
        captionLabel.layer.masksToBounds = false

        getStartedButton.layer.shadowColor = UIColor.black.cgColor
        getStartedButton.layer.shadowRadius = 3
        getStartedButton.layer.shadowOpacity = 0.5
        getStartedButton.layer.shadowOffset = .zero
        getStartedButton.layer.cornerRadius = 26
    }
}

// MARK: Binding

private extension WelcomeViewController {

    func bindViews() {
        getStartedButton.rx.tap.bind(to: viewModel.inputs.personalObserver).disposed(by: rx.disposeBag)
        signInButton.rx.tap.bind(to: viewModel.inputs.signInObserver).disposed(by: rx.disposeBag)
    }
}

// MARK: Captions animation

private extension WelcomeViewController {

    @objc
    func animationCaption() {
        guard !stopped, currentCaption < self.captionDelays.count else { return }

        UIView.transition(with: captionLabel, duration: 1.0, options: .transitionCrossDissolve, animations: { [weak self] in
            guard let `self` = self else { return }
            self.captionLabel.text = self.captions[self.currentCaption]
            self.currentCaption += 1
        }, completion: nil)

        guard currentCaption < self.captionDelays.count else { return }

        self.perform(#selector(animationCaption), with: nil, afterDelay: captionDelays[self.currentCaption])
    }
}
