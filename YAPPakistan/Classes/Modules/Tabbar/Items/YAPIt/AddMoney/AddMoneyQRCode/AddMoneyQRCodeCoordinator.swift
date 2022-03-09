//
//  AddMoneyQRCodeCoordinator.swift
//  YAPPakistan
//
//  Created by Yasir on 08/03/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift
//import AppAnalytics
//import YapToYap

class AddMoneyQRCodeCoordinator: Coordinator<ResultType<Void>> {
    
    private let root: UINavigationController!
    private var localRoot: UINavigationController!
    private let result = PublishSubject<ResultType<Void>>()
    private var scanAllowed = false
    private let container: UserSessionContainer
    private let disposeBag = DisposeBag()
//    override var feature: CoordinatorFeature { .addFunds }
    
    init(root: UINavigationController, scanAllowed: Bool, container: UserSessionContainer) {
        self.root = root
        self.scanAllowed = scanAllowed
        self.container = container
    }
    
    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<Void>> {
        
        let viewModel = AddMoneyQRCodeViewModel(scanAllowed: scanAllowed, accountProvider: container.accountProvider, themeService: container.themeService)
        let viewController = AddMoneyQRCodeViewController(themeService: container.themeService,viewModel: viewModel)
        viewController.modalPresentationStyle = .overCurrentContext
        localRoot = UINavigationControllerFactory.createTransparentNavigationBarNavigationController(rootViewController: viewController)
        localRoot.setNavigationBarHidden(true, animated: false)
        localRoot.modalPresentationStyle = .overCurrentContext
        localRoot.view.backgroundColor = .clear
        root.present(localRoot, animated: false, completion: nil)
        
        viewModel.outputs.close.subscribe(onNext: { [weak self] in
            self?.localRoot.dismiss(animated: false, completion: nil)
            self?.result.onNext(.cancel)
            self?.result.onCompleted()
        }).disposed(by: disposeBag)
        
        viewModel.outputs.scanQR.subscribe(onNext: {
            [unowned self] in
            self.localRoot.dismiss(animated: true) { [unowned self] in
                self.sendMoneyQRCode(self.root)
            }
        }).disposed(by: self.disposeBag)
        
        viewModel.outputs.shareQr.subscribe(onNext: { [weak self] in
           // AppAnalytics.shared.logEvent(QRCodeEvent.shareQrCode())
            self?.shareQRImage($0)
        }).disposed(by: disposeBag)
        
        return result.asObservable()
    }
}

// MARK: - Navigation

private extension AddMoneyQRCodeCoordinator {
    func shareQRImage(_ image: UIImage) {
        let activityItem: [AnyObject] = [image]
        let avc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
        localRoot.present(avc, animated: true, completion: nil)
    }

    private func sendMoneyQRCode(_ root: UINavigationController) {
        coordinate(to: SendMoneyQRCodeCoordinator.init(root: root, container: container)).subscribe(onNext: { [weak self] in
         if case let ResultType.success(result) = $0 {
             self?.qrFundsTransfer(localRoot: root, contact: result)
         }
     }).disposed(by: disposeBag)
    }
    
    func qrFundsTransfer(localRoot: UINavigationController, contact: QRContact) {
        coordinate(to: Y2YFundsTransferCoordinator(root: localRoot, container: container, contact: contact.yapContact, repository: container.makeY2YRepository(), transferType: .qrCode, shouldPresent: true)).subscribe(onNext: { [weak self] in
                
         if case let ResultType.success(result) = $0 {
             self?.result.onNext(.success(result))
             self?.result.onCompleted()
            localRoot.dismiss(animated: true)
         }
     }).disposed(by: disposeBag)
    }
}

