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
/*
import UIKit
import RxCocoa
import RxSwift

import AVKit

class AccountSelectionViewController: UIViewController {
    
    private lazy var signInLabel: UIButton = {
        let label = UIButton()
        label.titleLabel?.font = UIFont.appFont(forTextStyle: .regular)
        label.setTitleColor(UIColor.appColor(ofType: .greyDark), for: .normal)
        let text =  "screen_home_display_text_sign_in".localized
        let signIn = text.components(separatedBy: "?").last ?? ""
        let attributed = NSMutableAttributedString(string: text)
        attributed.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: text.count - signIn.count, length: signIn.count))
        attributed.addAttribute(.foregroundColor, value: UIColor.greyLight, range: NSRange(location: 0, length: text.count - signIn.count))
        label.setAttributedTitle(attributed, for: .normal)
        label.isHidden = true
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var getStartedButton: UIButton = {
        let button = UIButton()
        button.setTitle("screen_welcome_button_get_started".localized, for: .normal)
        button.backgroundColor = .primary
        button.isHidden = true
        button.alpha = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(ofSize: 16, weigth: .semibold)
        label.textColor = .white
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
    
    private lazy var player: AVPlayer = {
        let url = Bundle.main.url(forResource: "get_started", withExtension: "mp4")
        let player = AVPlayer(url: url!)
        return player
    }()
    
    var viewModel: AccountSelectionViewModelType!
    private var disposeBag = DisposeBag()
    
    private var captions = ["Bank your way", "", "Get an account in seconds", "", "Money transfers made simple", "", "Track your spending", "", "Split bills effortlessly", "", "Spend locally wherever you go", "", "Instant spending notifications", "", "An app for everyone", ""]
    private var captionDelays = [2.0, 1.5, 1.0, 1.5, 0.5, 1.8, 0.5, 2.0, 0.5, 2.0, 1.0, 2.5, 1.5, 2.0, 1.0, 3.0]
    
    private var currentCaption = 0
    
    private var stopped = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubViews()
        setupConstraints()
        bindViews()
        setupVideo()
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(resetVideo), name: .ApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startVideo), name: .ApplicationDidBecomeActive, object: nil)
    }
    
    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: .ApplicationWillResignActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: .ApplicationDidBecomeActive, object: nil)
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
        player.pause()
        player.seek(to: .zero)
        currentCaption = 0
        captionLabel.text = ""
        getStartedButton.isHidden = true
        getStartedButton.alpha = 0
        getStartedButton.isEnabled = false
        signInLabel.isHidden = true
        signInLabel.alpha = 0
        signInLabel.isEnabled = false
    }
    
    @objc
    func startVideo() {
        player.play()
        stopped = false
        self.perform(#selector(animationCaption), with: nil, afterDelay: captionDelays[self.currentCaption])
        getStartedButton.isHidden = false
        signInLabel.isHidden = false
        UIView.animate(withDuration: 0.5, delay: captionDelays[0], animations: {
            self.getStartedButton.alpha = 1
            self.signInLabel.alpha = 1
        }, completion: { completed in
            self.getStartedButton.isEnabled = true
            self.signInLabel.isEnabled = true
        })
    }
}

// MARK: View setup

private extension AccountSelectionViewController {
    
    func setupSubViews() {
        view.backgroundColor = .white
        
        view.layer.addSublayer(playerLayer)
        view.addSubview(getStartedButton)
        view.addSubview(signInLabel)
        view.addSubview(captionLabel)
    }
    
    func setupConstraints() {
        
        signInLabel
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 20)
            .width(constant: view.bounds.size.width)
            .height(constant: 24)
            .centerHorizontallyInSuperview()
        
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
//        getStartedButton.layer.masksToBounds = true
    }
}

// MARK: Binding

private extension AccountSelectionViewController {
    
    func bindViews() {
        getStartedButton.rx.tap.bind(to: viewModel.inputs.personalObserver).disposed(by: disposeBag)
        signInLabel.rx.tap.bind(to: viewModel.inputs.signInObserver).disposed(by: disposeBag)
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
*/
