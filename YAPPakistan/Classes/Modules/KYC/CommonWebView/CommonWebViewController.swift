//
//  CommonWebViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 14/02/2022.
//

import Foundation

import UIKit
import RxSwift
import RxCocoa
import RxTheme
import WebKit

class CommonWebViewController: UIViewController {
    
    // MARK: - Views
    lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.dataDetectorTypes = [.all]
        config.setURLSchemeHandler(self, forURLScheme: "yap-app")
        let webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        return webView
    }()
    private var backButton: UIButton!
    
    // MARK: - Properties
    private let viewModel: CommonWebViewModel
    private let disposeBag: DisposeBag
    private let themeService: ThemeService<AppTheme>
    
    // MARK: - Init
    init(themeService: ThemeService<AppTheme>, viewModel: CommonWebViewModel) {
        self.viewModel = viewModel
        self.themeService = themeService
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton = makeAndAddBackButton(of:.closeEmpty)
        setupViews()
        setupConstraints()
        setupTheme()
        setupBindings()
    }
    
    override public func onTapBackButton() {
        viewModel.inputs.closeObserver.onNext(())
    }
}

// MARK: - Setup
fileprivate extension CommonWebViewController {
    
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(webView)
    }
    
    func setupConstraints() {
        webView
            .alignAllEdgesWithSuperview()
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark)}, to: [backButton.rx.tintColor])
            .disposed(by: rx.disposeBag)
    }
    
    func setupBindings(){
        viewModel.outputs.html.subscribe(onNext: { [weak self] html in
            guard let `self` = self else { return }
            self.title = "".localized
            self.webView.loadHTMLString(html, baseURL: nil)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.webUrl.subscribe(onNext: { [weak self] html in
            guard let `self` = self else { return }
            self.title = "screen_kyc_card_details_screen_title".localized
            guard let url = URL(string: html) else { return }
            self.webView.load(URLRequest(url: url))
        }).disposed(by: disposeBag)
        
        viewModel.outputs.error.bind(to: rx.showErrorMessage).disposed(by: disposeBag)
        viewModel.outputs.cardAddedAlert.withUnretained(self)
            .subscribe(onNext: { `self`, paymentCardObj in
                self.showCardAddedAlert(externalCard: paymentCardObj)
            }).disposed(by: disposeBag)
    }
}

extension CommonWebViewController: WKURLSchemeHandler, WKNavigationDelegate {
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        viewModel.inputs.navigationActionObserver.onNext(navigationAction)
        viewModel.outputs.error.bind(to: rx.showErrorMessage).disposed(by: disposeBag)
        decisionHandler(.allow)
    }
    
}

extension CommonWebViewController {
    func showCardAddedAlert(externalCard: ExternalPaymentCard) {
        let title = "screen_topup_card_selection_display_topup_success_title".localized
        let details = "screen_topup_card_selection_display_topup_success_description".localized
        let text = title + "\n\n\n" + details + "\n"
        
        let attributted = NSMutableAttributedString(string: text)
        
        attributted.addAttributes([.foregroundColor: UIColor(self.themeService.attrs.primaryDark), .font: UIFont.title3], range: NSRange(location: 0, length: title.count))
        attributted.addAttributes([.foregroundColor: UIColor(self.themeService.attrs.greyDark), .font: UIFont.small], range: NSRange(location: text.count - details.count - 1, length: details.count))
        
        let alert = YAPAlertView(theme: self.themeService, icon: UIImage(named: "icon_check_fill_purple", in: .yapPakistan), text: attributted, primaryButtonTitle: "screen_topup_card_selection_display_topup_success_yes".localized, cancelButtonTitle: "screen_topup_card_selection_display_topup_success_no".localized)
        
        alert.show()
        
        alert.rx.cancelTap.withUnretained(self).subscribe(onNext: { `self`, _ in
            self.viewModel.inputs.alertTopupDashboardObserver.onNext(())
        }).disposed(by: disposeBag)
        
        alert.rx.primaryTap.withUnretained(self).subscribe(onNext: { `self`,_ in
            self.viewModel.inputs.alertTopupObserver.onNext(externalCard)
        }).disposed(by: disposeBag)
        
    }
}

