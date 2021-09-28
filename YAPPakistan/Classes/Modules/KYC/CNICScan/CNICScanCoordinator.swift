//
//  CNICScanCoordinator.swift
//  YAP
//
//  Created by Zain on 17/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import AVFoundation
import CardScanner
import Foundation
import RxSwift
import YAPCore

enum CNICScanType: Equatable {
    case update
    case new
}

class CNICScanCoordinator: Coordinator<ResultType<IdentityScannerResult>> {
    private let container: UserSessionContainer
    private let root: UINavigationController!
    private let scannerResultSubject = PublishSubject<ResultType<IdentityScannerResult>>()
    private var scanner: IdentityScanner!

    let presentationCompletion = PublishSubject<Void>()
    let scanType: CNICScanType!

    init(container: UserSessionContainer, root: UINavigationController!, scanType: CNICScanType) {
        self.container = container
        self.root = root
        self.scanType = scanType
    }

    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<IdentityScannerResult>> {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch authorizationStatus {
        case .authorized:
            openScanner()
        case .denied, .restricted:
            settings()
        case .notDetermined:
            requestPermissions()
        default:
            return scannerResultSubject.startWith(.cancel)
        }

        return scannerResultSubject.do(onNext: { [weak self] _ in
            self?.presentationCompletion.onCompleted()
        })
    }
}

// MARK: - Navigation

private extension CNICScanCoordinator {
    func settings() {
        let alert = UIAlertController(title: "Camera access",
                                      message: "Camera access is required to scan documents",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { [weak self] _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            self?.scannerResultSubject.onNext(.cancel)
            self?.scannerResultSubject.onCompleted()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            self?.scannerResultSubject.onNext(.cancel)
            self?.scannerResultSubject.onCompleted()
        }))

        root.present(alert, animated: true)
    }

    func requestPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            if granted {
                DispatchQueue.main.async { [weak self] in
                    self?.openScanner()
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.scannerResultSubject.onNext(.cancel)
                    self?.scannerResultSubject.onCompleted()
                }
            }
        }
    }

    func openScanner() {
        let theme = LightTheme()

        scanner = IdentityScanner(withParentController: root, documentType: .twoSided, reviewInfo: false)
        scanner.ui.primaryTextColor = UIColor(theme.primaryDark)
        scanner.ui.secondaryTextColor = UIColor(theme.greyDark)
        scanner.ui.tintColor = UIColor(theme.primary)
        scanner.expectedObservation = .emiratesId
        scanner.delegate = self
        scanner.scan { [unowned self] in
            self.presentationCompletion.onNext(())
            self.presentationCompletion.onCompleted()
        }
    }
}

// MARK: - IdentitScannerNavigation

extension CNICScanCoordinator: IdentityScannerDeletgate {
    public func identityScanner(didCancel scanner: IdentityScanner) {
        scanner.dismiss(animted: true, completion: nil)
        scannerResultSubject.onNext(ResultType.cancel)
        scannerResultSubject.onCompleted()
    }

    public func identityScanner(_ scanner: IdentityScanner, didFinishScanningWithResults results: IdentityScannerResult?) {
        scanner.dismiss(animted: true, completion: nil)
        guard  let results = results else {
            scannerResultSubject.onNext(ResultType.cancel)
            return
        }

        scannerResultSubject.onNext(ResultType.success(results))
        scannerResultSubject.onCompleted()
    }

    public func identityScanner(_ scanner: IdentityScanner, failedWithError error: Error) {
        scanner.dismiss(animted: true, completion: nil)
        scannerResultSubject.onNext(ResultType.cancel)
        scannerResultSubject.onCompleted()
    }
}
