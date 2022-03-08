//
//  SendMoneyQRCodeViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 07/03/2022.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents

protocol SendMoneyQRCodeViewModelInput {
    var myQrCodeObserver: AnyObserver<Void> { get }
    var imageLibraryObserver: AnyObserver<Void> { get }
    var closeObserver: AnyObserver<Void> { get }
    var qrCodeObserver: AnyObserver<String> { get }
    var pickedImageObserver: AnyObserver<UIImage> { get }
}

protocol SendMoneyQRCodeViewModelOutput {
    var openMyQrCode: Observable<Void> { get }
    var openImageLibrary: Observable<Void> { get }
    var close: Observable<Void> { get }
    var pauseScanning: Observable<Bool> { get }
    var error: Observable<String> { get }
    var result: Observable<QRContact> { get }
    var invalidQRDetection: Observable<Bool> { get }
}

protocol SendMoneyQRCodeViewModelType {
    var inputs: SendMoneyQRCodeViewModelInput { get }
    var outputs: SendMoneyQRCodeViewModelOutput { get }
}

class SendMoneyQRCodeViewModel: SendMoneyQRCodeViewModelInput, SendMoneyQRCodeViewModelOutput, SendMoneyQRCodeViewModelType {
    
    // MARK: - Properties
    
    var inputs: SendMoneyQRCodeViewModelInput { self }
    var outputs: SendMoneyQRCodeViewModelOutput { self }
    
    private let disposeBag = DisposeBag()
    private let repository: YapItRepository!
    
    private let myQRCodeSubject = PublishSubject<Void>()
    private let imageLibrarySubject = PublishSubject<Void>()
    private let closeSubject = PublishSubject<Void>()
    private let qrCodeSubject = PublishSubject<String>()
    private let pauseScanningSubject = PublishSubject<Bool>()
    private let errorSubject = PublishSubject<String>()
    private let resultSubject = PublishSubject<QRContact>()
    private let pickedImageSubject = PublishSubject<UIImage>()
    
    // MARK: - Inputs
    
    var myQrCodeObserver: AnyObserver<Void> { myQRCodeSubject.asObserver() }
    var imageLibraryObserver: AnyObserver<Void> { imageLibrarySubject.asObserver() }
    var closeObserver: AnyObserver<Void> { closeSubject.asObserver() }
    var qrCodeObserver: AnyObserver<String> { qrCodeSubject.asObserver() }
    var pickedImageObserver: AnyObserver<UIImage> { pickedImageSubject.asObserver() }
    
    // MARK: - Outputs
    
    var openMyQrCode: Observable<Void> { myQRCodeSubject.asObservable() }
    var openImageLibrary: Observable<Void> { imageLibrarySubject.asObservable() }
    var close: Observable<Void> { closeSubject.asObservable() }
    var pauseScanning: Observable<Bool> { pauseScanningSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var result: Observable<QRContact> { resultSubject.asObservable() }
    var invalidQRDetection: Observable<Bool> { qrCodeSubject.map{ [unowned self] in !$0.hasPrefix(self.qrCodePrefix) && $0.count > 0 }.asObservable() }
    
    private let qrCodePrefix = "yap-app:"
    
    init(_ repository: YapItRepository) {
        self.repository = repository
//
//        validateQrCode(repository)
//        validatePickedImage()
    }
    
}

// MARK: - QR code validation
/*
private extension SendMoneyQRCodeViewModel {
    func validateQrCode(_ repository: YapItRepository) {
        let validQrCode = qrCodeSubject
            .filter{ [unowned self] in $0.hasPrefix(self.qrCodePrefix) }.share()
        
        validQrCode.map{ _ in true }.bind(to: pauseScanningSubject).disposed(by: disposeBag)
        
        let infoRequst = validQrCode
            .do(onNext: { _ in
                YAPProgressHud.showProgressHud()
            })
            .flatMap{ [unowned self] in repository.getCustomerInfo(for: $0.replacingOccurrences(of: self.qrCodePrefix, with: "")) }
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .share()
        
        infoRequst.errors().map{ $0.localizedDescription }.bind(to: errorSubject).disposed(by: disposeBag)
        infoRequst.errors().map{ _ in false }.bind(to: pauseScanningSubject).disposed(by: disposeBag)
        
        let account = infoRequst.elements().withLatestFrom(Observable.combineLatest(infoRequst.elements(), SessionManager.current.currentAccount.unwrap())).share()
        
        account
            .filter{ $0.0.accountUUID != $0.1.uuid }
            .map{ $0.0 }
            .bind(to: resultSubject)
            .disposed(by: disposeBag)
        
        account
            .filter{ $0.0.accountUUID == $0.1.uuid }
            .map{ _ in "Scanned QR code belongs to your own YAP account. Please scan another QR code." }
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
    }
    
    func validatePickedImage() {
        let qrCodeText = pickedImageSubject.map{ $0.parseQrCode.first }
        qrCodeText.unwrap().bind(to: qrCodeSubject).disposed(by: disposeBag)
        
        qrCodeText.filter{ [unowned self] in !($0?.hasPrefix(self.qrCodePrefix) ?? false) }
            .map{ _ in "Picked image does not contain a valid QR code." }
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
    }
}
*/
