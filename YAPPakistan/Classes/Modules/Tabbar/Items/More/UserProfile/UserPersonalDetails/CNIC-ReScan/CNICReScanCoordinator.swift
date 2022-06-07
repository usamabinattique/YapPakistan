//
//  CNICReScanCoordinator.swift
//  YAPPakistan
//
//  Created by Umair  on 26/04/2022.
//

import AVFoundation
import YAPCardScanner
import Foundation
import RxSwift
import YAPCore

class CNICReScanCoordinator: Coordinator<ResultType<IdentityScannerResult>> {
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

private extension CNICReScanCoordinator {
    func settings() {
        root.showAlert(
            title: "common_display_text_permission_denied".localized,
            message: "common_display_text_permission_camera".localized,
            defaultButtonTitle: "common_button_settings".localized,
            secondayButtonTitle: "common_button_cancel".localized,
            defaultButtonHandler: { [weak self] _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                self?.scannerResultSubject.onNext(.cancel)
                self?.scannerResultSubject.onCompleted()
            }, secondaryButtonHandler: { [weak self] _ in
                self?.scannerResultSubject.onNext(.cancel)
                self?.scannerResultSubject.onCompleted()
            })
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

        scanner = IdentityScanner(withParentController: root, documentType: .twoSided, region: .pakistan, reviewInfo: false)
        scanner.ui.primaryTextColor = UIColor(theme.primaryDark)
        scanner.ui.secondaryTextColor = UIColor(theme.greyDark)
        scanner.ui.tintColor = UIColor(theme.primary)
        scanner.expectedObservation = .cnic
        scanner.appRegion = .pakistan
        scanner.delegate = self
        scanner.scan { [weak self] in
            self?.presentationCompletion.onNext(())
            self?.presentationCompletion.onCompleted()
        }
    }
}

// MARK: - IdentitScannerNavigation

extension CNICReScanCoordinator: IdentityScannerDeletgate {
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

