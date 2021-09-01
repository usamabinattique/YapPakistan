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
import UIKit
import YAPComponents

private let primary = #colorLiteral(red: 0.368627451, green: 0.2078431373, blue: 0.6941176471, alpha: 1)
private let primaryDark = #colorLiteral(red: 0.1529999971, green: 0.1330000013, blue: 0.3840000033, alpha: 1)
private let greyDark = #colorLiteral(red: 0.5759999752, green: 0.5690000057, blue: 0.6940000057, alpha: 1)

public class OnboardingWaitingListRankViewController: UIViewController {

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

    private lazy var placeLabel = UIFactory.makeLabel(with: primaryDark, textStyle: .title2, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var rankView: RankView = RankView()

    private lazy var behindNumberLabel = UIFactory.makeLabel(with: primaryDark, textStyle: .large, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var behindYouLabel = UIFactory.makeLabel(with: greyDark, textStyle: .small, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var infoLabel = UIFactory.makeLabel(with: primaryDark, textStyle: .small, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 241/255.0, green: 237/255, blue: 1, alpha: 1.0)
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private lazy var boostUpLabel: UILabel = UIFactory.makeLabel(with: greyDark, textStyle: .small, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)

    private lazy var seeInviteesButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(primary, for: .normal)
        button.titleLabel?.font = .small
        return button
    }()

    private lazy var containerStackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fillProportionally, spacing: 16, arrangedSubviews: [boostUpLabel, seeInviteesButton])

    private lazy var bumpMeUpButton: UIButton = {
        let button = AppRoundedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = primary
        button.titleLabel?.font = .large
        return button
    }()

    // MARK: Properties

    private let disposeBag = DisposeBag()
    private var viewModel: OnboardingWaitingListRankViewModelType!

    // MARK: Initialization

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    public init(viewModel: OnboardingWaitingListRankViewModelType) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: View Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupConstraints()
        bindViews(viewModel)

        viewModel.inputs.getRanking.onNext(true)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollView.contentSize.height )
    }
}

// MARK: View Setup

private extension OnboardingWaitingListRankViewController {
    func setupViews() {
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

        view.backgroundColor = .white

        navigationController?.isNavigationBarHidden = true
    }

    func setupConstraints() {
        scrollView
            .alignEdgesWithSuperview([.top, .left, .right, .safeAreaBottom])

        videoPlayerView
            .alignEdgeWithSuperview(.top, constant: 36)
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
            .alignEdgeWithSuperview(.bottom, constant: 8)
            .toBottomOf(contentView, constant: 4)
    }
}

// MARK: Binding

private extension OnboardingWaitingListRankViewController {
    func bindViews(_ viewModel: OnboardingWaitingListRankViewModelType) {
        viewModel.outputs.loading.subscribe(onNext: { flag in
            switch flag {
            case true:
                YAPProgressHud.showProgressHud()
            case false:
                YAPProgressHud.hideProgressHud()
            }
        }).disposed(by: disposeBag)

//        viewModel.outputs.error.subscribe(onNext: { [weak self] (error) in
//            self?.showAlert(title: "", message: error, defaultButtonTitle:  "common_button_ok".localized, secondayButtonTitle: nil, defaultButtonHandler: { [weak self] _ in
//                self?.viewModel.inputs.getRankingObserver.onNext(true)
//            }, secondaryButtonHandler: nil, completion: nil)
//        }).disposed(by: disposeBag)

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

        viewModel.outputs.seeInviteeButtonTitle
            .bind(to: seeInviteesButton.rx.title(for: .normal))
            .disposed(by: disposeBag)

        viewModel.outputs.bumpMeUpButtonTitle
            .bind(to: bumpMeUpButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
    }
}
