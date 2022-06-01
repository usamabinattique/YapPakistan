//
//  AddMoneyQRCodeViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 09/03/2022.
//

import YAPCore
import YAPComponents
import Foundation
import RxSwift
import RxTheme
import UIKit

protocol AddMoneyQRCodeViewModelInput {
    var closeObserver: AnyObserver<Void> { get }
    var shareQrObserver: AnyObserver<(UIImage)> { get }
    var goToQRScanner: AnyObserver<Void> {get}
    
}

protocol AddMoneyQRCodeViewModelOutput {
    var userImage: Observable<(_: URL?, _: UIImage?)> { get }
    var name: Observable<String?> { get }
    var qrCodeId: Observable<String> { get }
    var close: Observable<Void> { get }
    var shareQr: Observable<(UIImage?, String?)> { get }
    var scanQR: Observable<Void> {get}
    var isScanAllowed: BehaviorSubject<Bool> {get}
}

protocol AddMoneyQRCodeViewModelType {
    var inputs: AddMoneyQRCodeViewModelInput { get }
    var outputs: AddMoneyQRCodeViewModelOutput { get }
}

class AddMoneyQRCodeViewModel: AddMoneyQRCodeViewModelInput, AddMoneyQRCodeViewModelOutput, AddMoneyQRCodeViewModelType {
    
    var inputs: AddMoneyQRCodeViewModelInput { self }
    var outputs: AddMoneyQRCodeViewModelOutput { self }
    
    private let disposeBag = DisposeBag()
    
    private let qrCodeIdSubject = BehaviorSubject<String>(value: "")
    private let closeSubject = PublishSubject<Void>()
    private let shareQrSubject = PublishSubject<(UIImage?, String?)>()
    private let shareQrInputSubject = PublishSubject<(UIImage)>()
    
    private let goToQRScannerSubject = PublishSubject<Void>()
    var isScanAllowedSubject = BehaviorSubject<Bool>(value: false)
    
    // MARK: - Inputs
    var closeObserver: AnyObserver<Void> { closeSubject.asObserver() }
    var shareQrObserver: AnyObserver<(UIImage)> { shareQrInputSubject.asObserver() }
    var goToQRScanner: AnyObserver<Void> {goToQRScannerSubject.asObserver()}
    
    
    // MARK: - Outputs
    
    var userImage: Observable<(URL?, UIImage?)> { accountProvider.currentAccount.map{ [unowned self]  in ($0?.customer.imageURL, $0?.customer.fullName?.initialsImage(color: UIColor(self.themeService.attrs.primary), size: CGSize(width: 100, height: 100))) } }
    var name: Observable<String?> { accountProvider.currentAccount.map{ $0?.customer.fullName } }
    var qrCodeId: Observable<String> { qrCodeIdSubject.asObservable() }
    var close: Observable<Void> { closeSubject.asObservable() }
    var shareQr: Observable<(UIImage?, String?)> { shareQrSubject.asObservable() }
    var scanQR: Observable<Void> {goToQRScannerSubject.asObservable()}
    var isScanAllowed: BehaviorSubject<Bool> { isScanAllowedSubject.asObservable() as! BehaviorSubject<Bool>}
    
    private var accountProvider: AccountProvider
    private var themeService: ThemeService<AppTheme>
    
    init(scanAllowed: Bool, accountProvider: AccountProvider, themeService: ThemeService<AppTheme>) {
        self.themeService = themeService
        self.accountProvider = accountProvider
        accountProvider.currentAccount.map{ $0?.qrCodeId }.unwrap()
            .map{ "yap-app:\($0)" }
            .bind(to: qrCodeIdSubject).disposed(by: disposeBag)
        self.isScanAllowedSubject.onNext(scanAllowed)
        
        self.shareQrInputSubject.subscribe(onNext: { [unowned self] img in
            
            self.accountProvider.currentAccount.subscribe(onNext: { [unowned self] customer in
                let descriptionText = "Hi! its \(customer?.customer.fullName ?? "")\n Here is my YAP QR Code, please scan it for money transactions."
                self.shareQrSubject.onNext((img, descriptionText))
            }).disposed(by: disposeBag)
        }).disposed(by: disposeBag)
    }
}
