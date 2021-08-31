//
//  VideoPlayer.swift
//  YAPKit
//
//  Created by Wajahat Hassan on 03/03/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import AVKit
import Foundation
import RxCocoa
import RxSwift

public class VideoPlayer: UIView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    private let videoPlayedToEndSubject = PublishSubject<Void>()

    public var isLoopingEnabled: Bool = true
    public var videoPlayedToEnd: Observable<Void> { videoPlayedToEndSubject.asObservable() }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addNotificationObservers()
        addPlayerToView()
    }

    deinit {
        removeNotificationObservers()
    }

    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(resetVideo), name: .applicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startVideo), name: .applicationDidBecomeActive, object: nil)
    }

    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: .applicationWillResignActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: .applicationDidBecomeActive, object: nil)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }

    private func addPlayerToView() {
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)

        guard let playerLayer = playerLayer else { return }

        playerLayer.videoGravity = .resize
        layer.addSublayer(playerLayer)

        NotificationCenter.default.addObserver(self, selector: #selector(playerEndPlay), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    public func playVideoWithFileName(_ fileName: String, ofType type: String, in bundle: Bundle) {
        guard let filePath = bundle.path(forResource: fileName, ofType: type) else {
            return assertionFailure("File does not exist")
        }

        let videoUrl = URL(fileURLWithPath: filePath)
        let playerItem = AVPlayerItem(url: videoUrl)
        player?.replaceCurrentItem(with: playerItem)
        player?.play()
    }

    @objc
    private func playerEndPlay() {
        videoPlayedToEndSubject.onNext(())

        if isLoopingEnabled {
            resetVideo()
            startVideo()
        }
    }

    @objc
    private func resetVideo() {
        player?.pause()
        player?.seek(to: .zero)
    }

    @objc
    private func startVideo() {
        player?.play()
    }

    public func playVideoExternally() {
        resetVideo()
        startVideo()
    }
}
