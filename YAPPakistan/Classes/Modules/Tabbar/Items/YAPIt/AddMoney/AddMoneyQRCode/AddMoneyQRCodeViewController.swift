//
//  AddMoneyQRCodeViewController.swift
//  YAPPakistan
//
//  Created by Yasir on 08/03/2022.
//

import Foundation
import UIKit
import YAPCore
import YAPComponents
import RxSwift
import RxTheme
//import AppAnalytics

class AddMoneyQRCodeViewController: UIViewController {
    
    // MARK: - Views
    
    private lazy var blurEffectView: UIImageView = {
        let imageView = UIImageView()
        imageView.alpha = 0
        imageView.image = UIImage.init(named: "image_qr_code_background", in: .yapPakistan, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12.8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var userImage = UIFactory.makeImageView(contentMode: .scaleAspectFill)
    
    private lazy var nameLabel = UIFactory.makeLabel(font: .large, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping)
    
    private lazy var qrImage =  UIFactory.makeImageView(contentMode: .scaleAspectFit)
    
    private lazy var yapLogoImage = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    
    private lazy var qrView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    

    private lazy var shareQRButton = UIFactory.makeButton(with: .regular, backgroundColor: .clear, title: "Share my code")
    
    private lazy var shareQRIcon = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    
    private lazy var saveQRButton = UIFactory.makeButton(with: .regular, backgroundColor: .clear, title: "Save to gallery")
    
    private lazy var saveQRIcon = UIFactory.makeImageView(contentMode: .scaleAspectFit)
    
    private lazy var bottomLableView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var bottomLabel = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0, lineBreakMode: .byWordWrapping, text: "Share your unique YAP QR payments code to proceed")
    // MARK: - Properties
    
    private var viewModel: AddMoneyQRCodeViewModelType!
    private let disposeBag = DisposeBag()
    private var popUpTop: NSLayoutConstraint!
    private var labelBottom: NSLayoutConstraint!
    private var themeService: ThemeService<AppTheme>
    
    // MARK: Initialization
    
    init(themeService: ThemeService<AppTheme>,viewModel: AddMoneyQRCodeViewModelType) {
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
        
        setupViews()
        setupResources()
        setupTheme()
        setupContraints()
        bindViews(viewModel)
        
        addCloseButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        render()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        show()
    }
    
    // MARK: - Action
    
    func addCloseButton(_ type: BackButtonType = .backCircled) {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        button.setImage(UIImage.init(named: "icon_close_white_bg", in: .yapPakistan), for: .normal)
     //   button.tintColor =  .primary
     //   button.backgroundColor = .white
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.addTarget(self, action: #selector(onTapBackButton), for: .touchUpInside)
        
       // let backButton = UIBarButtonItem()
       // backButton.customView = button
       // navigationItem.leftBarButtonItem  = backButton
        
        self.view.addSubview(button)
        
        button.alignEdgeWithSuperview(.top, constant: 50)
        button.alignEdgeWithSuperview(.left, constant: 24)
    }
    
    func addQRScannerButton(_ type: BackButtonType = .backCircled) {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        button.setImage(UIImage.init(named: "qr_scanner", in: .yapPakistan), for: .normal)
       // button.tintColor =  .primary
       // button.backgroundColor = .white
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        
      /*  let backButton = UIBarButtonItem()
        backButton.customView = button
        navigationItem.rightBarButtonItem  = backButton */
        self.view.addSubview(button)
        
        button.alignEdgeWithSuperview(.top, constant: 50)
        button.alignEdgeWithSuperview(.right, constant: 24)
    }

    @objc
    private func addAction() {
       // self.viewModel.inputs.goToQRScanner.onNext(())
        hide()
    }

    override func onTapBackButton() {
        hide()
    }
    
    @objc
    func saveImageToPhotoLibray(_ sender: UIButton) {
       // AppAnalytics.shared.logEvent(QRCodeEvent.saveQrCode())
        UIImageWriteToSavedPhotosAlbum(qrView.asImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlert(title: "Save error", message: error.localizedDescription, defaultButtonTitle: "Ok")
        } else {
            showAlert(title: "Saved!", message: "Your image has been saved to your photos.", defaultButtonTitle: "Ok")
        }
    }
    
}

// MARK: - View setup

private extension AddMoneyQRCodeViewController {
    func setupViews() {
        view.addSubview(blurEffectView)
        view.addSubview(popupView)
        popupView.addSubview(userImage)
        popupView.addSubview(nameLabel)
        
        popupView.addSubview(qrView)
        qrView.addSubview(userImage)
        qrView.addSubview(nameLabel)
        qrView.addSubview(qrImage)
        qrView.addSubview(yapLogoImage)
        popupView.addSubview(shareQRIcon)
        popupView.addSubview(shareQRButton)
        popupView.addSubview(saveQRIcon)
        popupView.addSubview(saveQRButton)
        view.addSubview(bottomLableView)
        bottomLableView.addSubview(bottomLabel)
        
        userImage.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        userImage.layer.borderWidth = 1.5
        
        view.backgroundColor = .clear
        
        saveQRButton.addTarget(self, action: #selector(saveImageToPhotoLibray(_:)), for: .touchUpInside)
    }
    
    func setupResources() {
        shareQRIcon.image = UIImage(named: "icon_qr_share", in: .yapPakistan)
        saveQRIcon.image = UIImage(named: "icon_qr_save", in: .yapPakistan)
        yapLogoImage.image = UIImage(named: "icon_qr_yap_logo", in: .yapPakistan)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [bottomLabel.rx.textColor])
            .bind({ UIColor($0.primaryDark    ) }, to: [nameLabel.rx.textColor])
            .bind({ UIColor($0.primary        ) }, to: [shareQRButton.rx.titleColor(for: .normal),saveQRButton.rx.titleColor(for: .normal)])
            .disposed(by: rx.disposeBag)
    }
    
    func setupContraints() {
        
        blurEffectView.alignAllEdgesWithSuperview()
        
        popupView
            .alignEdgesWithSuperview([.left, .right], constant: 25)
        
        qrView
            .alignEdgeWithSuperview(.top, constant: 5)
            .centerHorizontallyInSuperview()
        
        userImage
            .alignEdgeWithSuperview(.top, constant: 15)
            .centerHorizontallyInSuperview()
            .width(constant: 42)
            .height(constant: 42)
        
        nameLabel
            .toBottomOf(userImage, constant: 5)
            .alignEdgesWithSuperview([.left, .right], constant: 15)
        
        qrImage
            .toBottomOf(nameLabel, .lessThanOrEqualTo, constant: 25)
            .toBottomOf(nameLabel, .greaterThanOrEqualTo, constant: 10)
            .alignEdgeWithSuperview(.left, constant: 10)
            .centerHorizontallyInSuperview()
            .height(constant: 170)
            .width(constant: 170)
        
        yapLogoImage
            .toBottomOf(qrImage, constant: 10)
            .width(constant: 137)
            .height(constant: 51)
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.bottom, constant: 10)
        
        shareQRButton
            .toBottomOf(qrView, .lessThanOrEqualTo, constant: 39)
            .toBottomOf(qrView, .greaterThanOrEqualTo, constant: 10)
            .centerHorizontallyInSuperview()
        
        shareQRIcon
            .toLeftOf(shareQRButton, constant: 15)
            .alignEdge(.centerY, withView: shareQRButton)
        
        saveQRButton
            .toBottomOf(shareQRButton, .lessThanOrEqualTo, constant: 30)
            .toBottomOf(shareQRButton, .greaterThanOrEqualTo, constant: 15)
            .centerHorizontallyInSuperview()
            .alignEdgeWithSuperview(.bottom, constant: 30)
        
        saveQRIcon
            .toLeftOf(saveQRButton, constant: 15)
            .alignEdge(.centerY, withView: saveQRButton)
        
        bottomLableView
            .toBottomOf(popupView, .lessThanOrEqualTo, constant: 34)
            .toBottomOf(popupView, .greaterThanOrEqualTo, constant: 15)
            .alignEdgesWithSuperview([.left, .right], constant: 25)
        
        bottomLabel
            .alignEdgesWithSuperview([.left, .top, .right, .bottom], constant: 8)
        
        popUpTop = popupView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIScreen.main.bounds.height)
        popUpTop.isActive = true
    }
    
    func render() {
        userImage.roundView()
    }
}

// MARK: - Binding

private extension AddMoneyQRCodeViewController {
    
    func bindViews(_ viewModel: AddMoneyQRCodeViewModelType) {
        viewModel.outputs.userImage.bind(to: userImage.rx.loadImage()).disposed(by: disposeBag)
        viewModel.outputs.name.bind(to: nameLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.qrCodeId.map{ [weak self] in self?.generateQRCode($0) }.bind(to: qrImage.rx.image).disposed(by: disposeBag)
        
        shareQRButton.rx.tap.map{ [weak self] in self?.qrView.asImage }.unwrap().bind(to: viewModel.inputs.shareQrObserver).disposed(by: disposeBag)
        
        viewModel.outputs.isScanAllowed.subscribe(onNext: { [unowned self] isScanAllowed in
            if isScanAllowed {
                self.addQRScannerButton()
            }
        }).disposed(by: disposeBag)
    }
}

// MARK: - QR Code generation

private extension AddMoneyQRCodeViewController {
    func generateQRCode(_ string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        
        qrFilter.setValue(data, forKey: "inputMessage")
        
        guard let qrImage = qrFilter.outputImage else { return nil }
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)
        
        guard let colorInvertFilter = CIFilter(name: "CIColorInvert") else { return nil }
        colorInvertFilter.setValue(scaledQrImage, forKey: "inputImage")
        guard let outputInvertedImage = colorInvertFilter.outputImage else { return nil }
        guard let maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
        maskToAlphaFilter.setValue(outputInvertedImage, forKey: "inputImage")
        guard let outputCIImage = maskToAlphaFilter.outputImage else { return nil }
        
        return UIImage(ciImage: outputCIImage).asTemplate
    }
}

// MARK: - Animation

private extension AddMoneyQRCodeViewController {
    func show() {
        popUpTop.constant = 100 //15
        labelBottom = view.safeAreaLayoutGuide.bottomAnchor.constraint(greaterThanOrEqualTo: bottomLableView.bottomAnchor, constant: 15)
        labelBottom.isActive = true
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
            self.view.layoutSubviews()
            self.blurEffectView.alpha = 1
        }) { _ in
            
        }
    }
    
    func hide() {
        labelBottom.isActive = false
        popUpTop.constant = UIScreen.main.bounds.height
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutSubviews()
            self.blurEffectView.alpha = 0
        }) { (completed) in
            guard completed else { return }
            self.viewModel.inputs.closeObserver.onNext(())
        }
    }
}

// MARK: - Shareable image

fileprivate extension UIView {
    var asImage: UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

