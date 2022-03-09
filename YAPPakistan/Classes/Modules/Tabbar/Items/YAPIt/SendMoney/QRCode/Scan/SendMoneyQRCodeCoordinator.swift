//
//  SendMoneyQRCodeCoordinator.swift
//  YAPPakistan
//
//  Created by Yasir on 07/03/2022.
//

import Foundation
import RxSwift
import YAPComponents
import YAPCore
import AVFoundation
import Photos
import RxCocoa


class SendMoneyQRCodeCoordinator: Coordinator<ResultType<QRContact>> {
    
    private let result = PublishSubject<ResultType<QRContact>>()
    private let root: UINavigationController
    private var localRoot: UINavigationController!
    private let pickedImageSubject = PublishSubject<UIImage>()
    private let disposeBag = DisposeBag()
    private var container: UserSessionContainer
   // override var feature: CoordinatorFeature { .y2yTransfer }
    
    init(root: UINavigationController, container: UserSessionContainer) {
        self.root = root
        self.container = container
    }
    
    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<QRContact>> {
        
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch authorizationStatus {
        case .authorized:
            qrCodeScanner()
        case .denied, .restricted:
            settings()
        case .notDetermined:
            requestPermissions()
        default:
            return result.startWith(.cancel)
        }
        
        
        return result
            .do(onNext: { [weak self] _ in self?.localRoot.dismiss(animated: true, completion: nil) })
            .asObservable()
    }
}

// MARK: - Navigation

private extension SendMoneyQRCodeCoordinator {
    
    func settings() {
        let alert = UIAlertController(title: "Camera access", message: "Camera access is required to scan QR Code. Grant access in device settings.", preferredStyle: .alert)

        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { [weak self] action in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
        }))
        
        root.present(alert, animated: true)
    }
    
    func settingsPhotos() {
        let alert = UIAlertController(title: "Photos access", message: "Photos access is required to scan QR Code. Grant access in device settings.", preferredStyle: .alert)

        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { action in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        root.present(alert, animated: true)
    }
    
    func requestPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            if granted {
                DispatchQueue.main.async { [weak self] in
                    self?.qrCodeScanner()
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.result.onNext(.cancel)
                    self?.result.onCompleted()
                }
            }
        }
    }
    
    func qrCodeScanner() {
        let viewModel = SendMoneyQRCodeViewModel(container.makeYapItRepository(),accountProvider: container.accountProvider)
        let viewController = SendMoneyQRCodeViewController(themeService: container.themeService, viewModel: viewModel)
        
        localRoot = UINavigationControllerFactory.createTransparentNavigationBarNavigationController(rootViewController: viewController)
        localRoot.setNavigationBarHidden(true, animated: false)
        root.present(localRoot, animated: true) { [weak self] in
          //  self?.localRoot.setNavigationBarHidden(true, animated: false)
        }
        viewModel.outputs.close.subscribe(onNext: { [weak self] _ in
            //self?.localRoot.setNavigationBarHidden(false, animated: false)
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
        }).disposed(by: disposeBag)
        
        viewModel.outputs.openMyQrCode.subscribe(onNext: { [weak self] in
            self?.myQrCode()
        }).disposed(by: disposeBag)
        
        viewModel.outputs.openImageLibrary.subscribe(onNext: { [weak self] in
            self?.photoLibrary()
        }).disposed(by: disposeBag)
        
        pickedImageSubject.bind(to: viewModel.inputs.pickedImageObserver).disposed(by: disposeBag)
        
        viewModel.outputs.result.subscribe(onNext: { [weak self] in
            self?.result.onNext(.success($0))
            self?.result.onCompleted()
        }).disposed(by: disposeBag)
    }
    
    func myQrCode() {
        coordinate(to: AddMoneyQRCodeCoordinator(root: localRoot, scanAllowed: false, container: container)).subscribe().disposed(by: disposeBag)
    }
    
    func photoLibrary() {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            openPhotoLibrary()
        case .denied, .restricted:
            settingsPhotos()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    DispatchQueue.main.async { self.openPhotoLibrary() }
                }
            }
        default:
            break;
        }
    }
    
    func openPhotoLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .fullScreen
        localRoot.present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - Image picker controller delegate

extension SendMoneyQRCodeCoordinator: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            pickedImageSubject.onNext(image)
        }
    }
}
