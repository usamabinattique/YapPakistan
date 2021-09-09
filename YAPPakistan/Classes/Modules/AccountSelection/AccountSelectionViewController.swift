//
//  AccountSelectionViewController.swift
//  App
//
//  Created by Zain on 18/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

//
//  AccountSelectionViewController.swift
//  App
//
//  Created by Zain on 18/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import AVKit
import RxTheme
import YAPComponents

class AccountSelectionViewController: UIViewController {

    
    private lazy var signInLabelButtonContainer = UIFactory.makeView().setAlpha(0).setHidden(true)
    
    fileprivate lazy var signInLabel = UIFactory.makeLabel(
        font: .regular
    )
    
    fileprivate lazy var signInButton: UIButton = {
        let label = UIButton()
        label.titleLabel?.font = .regular
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate lazy var getStartedButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.alpha = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(ofSize: 16, weigth: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: nil)
        playerLayer.videoGravity = .resizeAspectFill
        return playerLayer
    }()
    
    private lazy var player: AVPlayer? = {
        let url = Bundle.yapPakistan.url(forResource: "get_started", withExtension: "mp4")
        return AVPlayer(url: url!)
    }()
    
    fileprivate lazy var captions:[String] = { Array(repeating: "", count: captionDelays.count) }()
    fileprivate var captionDelays = [2.0, 1.5, 1.0, 1.5, 0.5, 1.8, 0.5, 2.0, 0.5, 2.0, 1.0, 2.5, 1.5, 2.0, 1.0, 3.0]
    
    private var currentCaption = 0
    
    private var stopped = true
    
    private var viewModel: AccountSelectionViewModelType!
    private var themeService: ThemeService<AppTheme>!
    
    convenience init(themeService: ThemeService<AppTheme>, viewModel:AccountSelectionViewModelType) {
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
        setupVideo()
        
        NotificationCenter.default.addObserver(Self.self, selector: #selector(setupLocalizedStrings), name: NSLocale.currentLocaleDidChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)

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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotificationObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        resetVideo()
    }
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(resetVideo), name: .applicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startVideo), name: .applicationDidBecomeActive, object: nil)
    }
    
    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: .applicationWillResignActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: .applicationDidBecomeActive, object: nil)
    }
    
    @objc
    private func playerDidFinishPlaying() {
        resetVideo()
        startVideo()
    }
}

// MARK: Setup video

private extension AccountSelectionViewController {
    func setupVideo() {
        playerLayer.player = player
    }
    
    @objc
    func resetVideo() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(animationCaption), object: nil)
        stopped = true
        player?.pause()
        player?.seek(to: .zero)
        currentCaption = 0
        captionLabel.text = ""
        getStartedButton.isHidden = true
        getStartedButton.alpha = 0
        getStartedButton.isEnabled = false
        signInLabelButtonContainer.isHidden = true
        signInLabelButtonContainer.alpha = 0
        signInLabelButtonContainer.isUserInteractionEnabled = false
    }
    
    @objc
    func startVideo() {
        player?.play()
        stopped = false
        self.perform(#selector(animationCaption), with: nil, afterDelay: captionDelays[self.currentCaption])
        getStartedButton.isHidden = false
        signInLabelButtonContainer.isHidden = false
        UIView.animate(withDuration: 0.5, delay: captionDelays[0], animations: {
            self.getStartedButton.alpha = 1
            self.signInLabelButtonContainer.alpha = 1
        }, completion: { completed in
            self.getStartedButton.isEnabled = true
            self.signInLabelButtonContainer.isUserInteractionEnabled = true
        })
    }
}

// MARK: View setup

private extension AccountSelectionViewController {
    
    func setupSubViews() {
        view.layer
            .addSublayer(playerLayer)
        view
            .addSub(view: getStartedButton)
            .addSub(view: signInLabelButtonContainer)
            .addSub(view: signInLabel)
            .addSub(view: captionLabel)
        signInLabelButtonContainer
            .addSub(view: signInLabel)
            .addSub(view: signInButton)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({$0.primaryLight}, to: [view.rx.backgroundColor])
            .bind({$0.greyLight}, to: [signInLabel.rx.textColor])
            .bind({$0.primaryExtraLight}, to: [signInButton.rx.titleColor(for: .normal)])
            .bind({$0.primary}, to: [getStartedButton.rx.backgroundColor])
            .bind({$0.primaryExtraLight}, to: [captionLabel.rx.textColor])
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
        
        signInLabelButtonContainer
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
        signInLabel.layer.shadowColor = UIColor.black.cgColor
        signInLabel.layer.shadowRadius = 3
        signInLabel.layer.shadowOpacity = 0.7
        signInLabel.layer.shadowOffset = .zero
        signInLabel.layer.masksToBounds = false
        
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
//      getStartedButton.layer.masksToBounds = true
    }
}

// MARK: Binding

private extension AccountSelectionViewController {
    
    func bindViews() {
        getStartedButton.rx.tap.bind(to: viewModel.inputs.personalObserver).disposed(by: rx.disposeBag)
        signInButton.rx.tap.bind(to: viewModel.inputs.signInObserver).disposed(by: rx.disposeBag)
    }
}

// MARK: Captions animation

private extension AccountSelectionViewController {
    
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
