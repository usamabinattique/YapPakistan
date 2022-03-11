//
//  SendMoneyQRCodeViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 07/03/2022.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import AVFoundation
import YAPCore
import YAPComponents
import CoreGraphics
import RxTheme

class SendMoneyQRCodeViewController: UIViewController {
    
    // MARK: - Session
        
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.beginConfiguration()
        
        let device: AVCaptureDevice?
        if let videoDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            device = videoDevice
        } else {
            device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        }
        
        if let videoDevice = device, let input = try? AVCaptureDeviceInput(device: videoDevice) {
            if session.canAddInput(input) {
                session.addInput(input)
            }
        }
        
        session.sessionPreset = .high

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video_ouput_queue"))
        
        session.commitConfiguration()
        
        return session
    }()
    
    
    // MARK: - Views
    
    private lazy var cameraPreviewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer()
        layer.session = captureSession
        layer.videoGravity = .resizeAspectFill
        layer.connection?.videoOrientation = .portrait
        return layer
    }()
    
    private lazy var myQrCodeButton = UIVerticalButtonFactory.createVerticalButton(title: "My QR code", image: UIImage.init(named: "icon_my_qr_code", in: .yapPakistan, compatibleWith: nil))
    
    private lazy var imageLibraryButton = UIVerticalButtonFactory.createVerticalButton(title: "Image library", image: UIImage.init(named: "icon_image_library", in: .yapPakistan, compatibleWith: nil))
    
    private lazy var headingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var headingLabel = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0, lineBreakMode: .byTruncatingTail, text: "Scan a YAP QR payments code to proceed") //UILabelFactory.createUILabel(with: .white, textStyle: .regular, alignment: .center, numberOfLines: 0, lineBreakMode: .byTruncatingTail, text: "Scan a YAP QR payments code to proceed")
    
    
    private lazy var blurEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var frameView: QRCodeScanFrameView = {
        let view = QRCodeScanFrameView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    
    private var isCapturing: Bool = false
    private let disposeBag = DisposeBag()
    private var viewModel: SendMoneyQRCodeViewModelType!
    private let context = CIContext()
    private var themeService: ThemeService<AppTheme>
        
    // MARK: Initialization
    init(themeService: ThemeService<AppTheme>, viewModel: SendMoneyQRCodeViewModelType) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: \(coder) has not been implemented")
    }
    
    // MARK: - View cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCloseButton()
        setupViews()
        setupConstraints()
        setupTheme()
        bindViews(viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    
    // MARK: - Action
    
    func addCloseButton(_ type: BackButtonType = .backCircled) {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        button.setImage(UIImage.init(named: "icon_close_white_bg", in: .yapPakistan), for: .normal)
        // TODO: add colour here
//        button.tintColor =  UIColor(themeService.attrs.primary)// .white //.primary
//        button.backgroundColor = .white
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.addTarget(self, action: #selector(onTapBackButton), for: .touchUpInside)
        
//        let backButton = UIBarButtonItem()
//        backButton.customView = button
//        navigationItem.leftBarButtonItem  = backButton
        self.frameView.addSubview(button)
        
        button.alignEdgeWithSuperview(.top, constant: 50)
        button.alignEdgeWithSuperview(.left, constant: 24)
    }
    
    override func onTapBackButton() {
        viewModel.inputs.closeObserver.onNext(())
    }
    
}

// MARK: - View setup

private extension SendMoneyQRCodeViewController {
    func setupViews() {
        view.layer.addSublayer(cameraPreviewLayer)
        view.addSubview(frameView)
        view.addSubview(myQrCodeButton)
        view.addSubview(imageLibraryButton)
        view.addSubview(headingView)
        headingView.addSubview(headingLabel)
    }
    
    func setupConstraints() {
        
        myQrCodeButton.backgroundColor = .clear
        myQrCodeButton.titleLable.textColor = .white
        
        imageLibraryButton.backgroundColor = .clear
        imageLibraryButton.titleLable.textColor = .white
        
        cameraPreviewLayer.frame = UIScreen.main.bounds
        
        frameView
            .alignAllEdgesWithSuperview()
        
        myQrCodeButton
            .alignEdgesWithSuperview([.left, .safeAreaBottom], constants: [45, 35])
        
        imageLibraryButton
            .alignEdgesWithSuperview([.right, .safeAreaBottom], constants: [45, 35])
        
        headingView
            .alignEdgesWithSuperview([.left, .right], constant: 25)
            .toTopOf(myQrCodeButton, .lessThanOrEqualTo, constant: 64)
            .toTopOf(myQrCodeButton, .greaterThanOrEqualTo, constant: 15)
        
        headingLabel.alignEdgesWithSuperview([.left, .top, .right, .bottom], constants: [3.5, 1.5, 3.5, 1.5])
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [headingLabel.rx.textColor])
            .disposed(by: rx.disposeBag)



    }
}

// MARK: - Image cropping

private extension SendMoneyQRCodeViewController {
    private func cropImage(_ metaRect: CGRect, _ orgImage: CIImage) -> UIImage? {
        guard metaRect != .zero else { return nil }
        
        let orgImageSize = orgImage.extent.size
        guard let orgCgImage = self.context.createCGImage(orgImage, from: orgImage.extent) else { return nil }
        
        let cropRect: CGRect = CGRect(x: metaRect.origin.x * orgImageSize.width, y: metaRect.origin.y * orgImageSize.height, width: metaRect.size.width * orgImageSize.width, height: metaRect.size.height * orgImageSize.height).integral
        
        guard let croppedCgImage = orgCgImage.cropping(to: cropRect) else { return nil }
        
        let orientedCiImage = CIImage(cgImage: croppedCgImage).oriented(forExifOrientation: Int32(UIDevice.current.orientation.exifOrientation()))
        
        guard let orientedCgImage = self.context.createCGImage(orientedCiImage, from: orientedCiImage.extent) else { return nil }
        
        return UIImage(cgImage: orientedCgImage)
    }
}

// MARK: - Binding

private extension SendMoneyQRCodeViewController {
    func bindViews(_ viewModel: SendMoneyQRCodeViewModelType) {
        myQrCodeButton.rx.tap.bind(to: viewModel.inputs.myQrCodeObserver).disposed(by: disposeBag)
        imageLibraryButton.rx.tap.bind(to: viewModel.inputs.imageLibraryObserver).disposed(by: disposeBag)
        viewModel.outputs.pauseScanning.subscribe(onNext: { [weak self] pause in
            if pause {
                self?.captureSession.stopRunning()
            } else {
                self?.captureSession.startRunning()
            }
        }).disposed(by: disposeBag)
        
        viewModel.outputs.error.subscribe(onNext: { [weak self] error in
            self?.showAlert(title: "", message: error, defaultButtonTitle: "OK", secondayButtonTitle: nil) { (action) in
                self?.captureSession.startRunning()
            }

        }).disposed(by: disposeBag)
        
        viewModel.outputs.invalidQRDetection.subscribe(onNext: { [weak self] in
            self?.frameView.setQrCodeValid(!$0)
        }).disposed(by: disposeBag)
    }
}

// MARK: - Sample view buffer delegate

extension SendMoneyQRCodeViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer), !isCapturing else { return }
        
        if let croppedImage = cropImage(cameraPreviewLayer.metadataOutputRectConverted(fromLayerRect: frameView.croppingRect), CIImage(cvPixelBuffer: pixelBuffer)) {
            DispatchQueue.main.async {
                self.viewModel.inputs.qrCodeObserver.onNext(croppedImage.parseQrCode.first ?? "")
            }
        }
    }
}
