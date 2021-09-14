//
//  OnboardingWaitingListRankViewController.swift
//  OnBoarding
//
//  Created by Muhammad Awais on 25/02/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation
import RxCocoa
import RxDataSources
import RxSwift
import RxTheme
import UIKit
import YAPComponents

class WaitingListRankViewController: UIViewController {

    // MARK: Views

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private lazy var videoPlayerView: VideoPlayer = {
        let player = VideoPlayer()
        player.isLoopingEnabled = false
        player.translatesAutoresizingMaskIntoConstraints = false
        return player
    }()

    private lazy var placeLabel = UIFactory.makeLabel(font: .title2, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var rankView: RankView = RankView()

    private lazy var behindNumberLabel = UIFactory.makeLabel(font: .large, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var behindYouLabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var infoLabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private lazy var boostUpLabel: UILabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var seeInviteesButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .small
        return button
    }()

    private lazy var containerStackView = UIFactory.makeStackView(axis: .vertical, alignment: .center, distribution: .fillProportionally, spacing: 16, arrangedSubviews: [boostUpLabel, seeInviteesButton])

    private lazy var bumpMeUpButton: UIButton = {
        let button = AppRoundedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .large
        return button
    }()

    // MARK: Properties

    private var themeService: ThemeService<AppTheme>!

    private let disposeBag = DisposeBag()
    private var viewModel: WaitingListRankViewModelType!

    // MARK: Initialization

    init(themeService: ThemeService<AppTheme>, viewModel: WaitingListRankViewModelType) {
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
        bindViews(viewModel)

        viewModel.inputs.getRanking.onNext(true)
    }

    // MARK: View Setup

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(videoPlayerView)
        scrollView.addSubview(placeLabel)
        scrollView.addSubview(rankView)
        scrollView.addSubview(behindNumberLabel)
        scrollView.addSubview(behindYouLabel)
        scrollView.addSubview(infoLabel)
        scrollView.addSubview(contentView)
        contentView.addSubview(containerView)
        containerView.addSubview(containerStackView)
        scrollView.addSubview(bumpMeUpButton)
    }

    private func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: placeLabel.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: rankView.rx.digitColor)
            .bind({ UIColor($0.greyExtraLight) }, to: rankView.rx.digitBackgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: behindNumberLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: behindYouLabel.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: infoLabel.rx.textColor)
            .bind({ UIColor($0.primaryExtraLight) }, to: containerView.rx.backgroundColor)
            .bind({ UIColor($0.greyDark) }, to: boostUpLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: seeInviteesButton.rx.titleColor(for: .normal))
            .bind({ UIColor($0.primary) }, to: bumpMeUpButton.rx.backgroundColor)
            .disposed(by: disposeBag)
    }

    private func setupConstraints() {
        scrollView
            .alignEdgesWithSuperview([.top, .left, .right, .safeAreaBottom])

        videoPlayerView
            .alignEdgeWithSuperview(.top, constant: 26)
            .centerHorizontallyInSuperview()
            .height(constant: 192)
            .width(constant: 192)

        placeLabel
            .alignEdgesWithSuperview([.left, .right], constants: [24, 24])
            .toBottomOf(videoPlayerView, constant: -12)

        rankView
            .alignEdgesWithSuperview([.left, .right])
            .toBottomOf(placeLabel, constant: 32)
            .height(constant: 64)

        behindNumberLabel
            .alignEdgesWithSuperview([.left, .right], constants: [24, 24])
            .toBottomOf(rankView, constant: 16)
            .height(constant: 22)

        behindYouLabel
            .alignEdgesWithSuperview([.left, .right], constants: [24, 24])
            .toBottomOf(behindNumberLabel, constant: 8)

        infoLabel
            .alignEdgesWithSuperview([.left, .right], constants: [24, 24])
            .toBottomOf(behindYouLabel, constant: 20)

        contentView
            .alignEdgesWithSuperview([.left, .right])
            .width(constant: UIScreen.main.bounds.width)
            .height(constant: 194)
            .toBottomOf(infoLabel, constant: 16)

        containerView
            .alignEdgesWithSuperview([.left, .right], constants: [24, 24])
            .height(constant: 150)
            .centerVerticallyInSuperview()

        containerStackView
            .alignEdgesWithSuperview([.left, .right], constants: [16, 16])
            .centerVerticallyInSuperview()

        seeInviteesButton
            .height(constant: 30)

        bumpMeUpButton
            .centerHorizontallyInSuperview()
            .height(constant: 52)
            .width(constant: 260)
            .alignEdgeWithSuperview(.bottom, constant: 20)
            .toBottomOf(contentView, constant: 4)
    }

    // MARK: Binding

    private func bindViews(_ viewModel: WaitingListRankViewModelType) {
        viewModel.outputs.loading.subscribe(onNext: { flag in
            switch flag {
            case true:
                YAPProgressHud.showProgressHud()
            case false:
                YAPProgressHud.hideProgressHud()
            }
        }).disposed(by: disposeBag)

        viewModel.outputs.animationFile.subscribe(onNext: { [weak self] fileName in
            let nameOnly = fileName.deletingPathExtension
            let extensionOnly = fileName.pathExtension
            let bundle = Bundle(for: Self.self)

            self?.videoPlayerView.playVideoWithFileName(nameOnly, ofType: extensionOnly, in: bundle)
        }).disposed(by: disposeBag)

        videoPlayerView.videoPlayedToEnd
            .map { [weak self] in
                self?.videoPlayerView.isLoopingEnabled = true
            }
            .bind(to: viewModel.inputs.firstVideoEnded)
            .disposed(by: disposeBag)

        viewModel.outputs.placeText
            .bind(to: placeLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.rank.subscribe(onNext: { [weak self] in
            self?.rankView.animate(rank: $0 ?? "0")
        }).disposed(by: disposeBag)

        viewModel.outputs.behindNumber
            .bind(to: behindNumberLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.behindYouText
            .bind(to: behindYouLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.infoText
            .bind(to: infoLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.boostUpText
            .bind(to: boostUpLabel.rx.text)
            .disposed(by: disposeBag)

        seeInviteesButton.rx.tap.withLatestFrom(viewModel.outputs.waitingListRank).subscribe { (waitingListRank: WaitingListRank) in
            let viewModel = ReferredFriendsViewModel(waitingListRank: waitingListRank)
            let referredFriends = ReferredFriendsViewController(themeService: self.themeService, viewModel: viewModel)

            self.presentPanModal(referredFriends, completion: nil)
        }.disposed(by: disposeBag)

        viewModel.outputs.seeInviteeButtonTitle
            .bind(to: seeInviteesButton.rx.title(for: .normal))
            .disposed(by: disposeBag)

        viewModel.outputs.bumpMeUpButtonTitle
            .bind(to: bumpMeUpButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
    }
}
