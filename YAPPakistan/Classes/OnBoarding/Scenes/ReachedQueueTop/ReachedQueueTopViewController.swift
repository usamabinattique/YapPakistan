//
//  ReachedQueueTopViewController.swift
//  YAPPakistan
//
//  Created by Tayyab on 06/09/2021.
//

import AVFoundation
import RxCocoa
import RxSwift
import RxTheme
import UIKit
import YAPComponents

class ReachedQueueTopViewController: UIViewController {

    // MARK: Views

    private lazy var heading = UIFactory.makeLabel(font: .title2, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var subHeading = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var player: AVPlayer = {
        let url = Bundle.yapPakistan.url(forResource: "yap_card_animation", withExtension: "mp4")
        let player = AVPlayer(url: url!)
        return player
    }()

    private lazy var playerView = UIFactory.makeView()

    private lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: nil)
        playerLayer.videoGravity = .resizeAspectFill
        return playerLayer
    }()

    private lazy var infoLabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var completeVerificationButton = UIFactory.makeAppRoundedButton(with: .large)

    // MARK: Properties

    private var themeService: ThemeService<AppTheme>!

    private let disposeBag = DisposeBag()
    private(set) var viewModel: ReachedQueueTopViewModelType!

    // MARK: Initialization

    init(themeService: ThemeService<AppTheme>, viewModel: ReachedQueueTopViewModelType) {
        super.init(nibName: nil, bundle: nil)

        self.themeService = themeService
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: View Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupTheme()
        setupConstraints()
        setupVideo()
        bindViewModel()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.setPlayerViewBounds()
            self?.startVideo()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: View Setup

    private func setupViews() {
        view.addSubview(heading)
        view.addSubview(subHeading)
        view.addSubview(infoLabel)
        view.addSubview(completeVerificationButton)
        playerView.layer.addSublayer(playerLayer)
        view.addSubview(playerView)
    }

    private func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: heading.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: subHeading.rx.textColor)
            .bind({ UIColor($0.backgroundColor) }, to: playerView.rx.backgroundColor)
            .bind({ UIColor($0.greyDark) }, to: infoLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: completeVerificationButton.rx.backgroundColor)
            .disposed(by: disposeBag)
    }

    private func setupConstraints() {
        heading
            .alignEdgesWithSuperview([.left, .safeAreaTop, .right], constants: [32, 20, 34])
            .height(constant: 64)

        subHeading
            .alignEdgesWithSuperview([.left, .right], constants: [32, 34])
            .toBottomOf(heading, constant: 17)
            .height(constant: 52)

        playerView
            .toBottomOf(subHeading)
            .alignEdgesWithSuperview([.left, .right])
            .toTopOf(infoLabel)

        infoLabel
            .alignEdgesWithSuperview([.left, .right], constants: [40, 40])
            .toTopOf(completeVerificationButton, .greaterThanOrEqualTo, constant: 10)
            .toTopOf(completeVerificationButton, .lessThanOrEqualTo, constant: 30)
            .height(constant: 40)

        completeVerificationButton
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperviewSafeArea(.bottom, constant: 15)
            .height(constant: 52)
            .width(constant: 290)
    }

    private func setPlayerViewBounds() {
        playerLayer.frame = playerView.bounds
    }

    // MARK: Setup Video

    private func setupVideo() {
        playerLayer.player = player
    }

    @objc
    private func resetVideo() {
        player.pause()
        player.seek(to: .zero)
    }

    @objc
    private func startVideo() {
        player.play()
    }

    // MARK: Binding

    private func bindViewModel() {
        viewModel.outputs.heading
            .bind(to: heading.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.subHeading
            .bind(to: subHeading.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.infoText
            .bind(to: infoLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.verificationButtonTitle
            .bind(to: completeVerificationButton.rx.title())
            .disposed(by: disposeBag)

        completeVerificationButton.rx.tap
            .bind(to: viewModel.inputs.completeVerificationObserver)
            .disposed(by: disposeBag)

        viewModel.outputs.error.subscribe(onNext: { [weak self] error in
            self?.showAlert(title: "", message: error,
                            defaultButtonTitle: "common_button_ok".localized,
                            secondayButtonTitle: nil,
                            defaultButtonHandler: { _ in },
                            secondaryButtonHandler: nil,
                            completion: nil)
        }).disposed(by: disposeBag)
    }
}
