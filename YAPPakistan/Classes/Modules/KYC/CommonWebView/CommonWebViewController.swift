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
        
        self.webView.load(URLRequest(url: URL(string: "https://pk-qa-hci.yap.co/YAP_PK_BANK_ALFALAH/HostedSessionIntegration.html")!))
        
        setupViews()
        setupConstraints()
    }
    
    override public func onTapBackButton() {
        navigationController?.popViewController(animated: true)
//        viewModel.inputs.backObserver.onNext(())
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
}

extension CommonWebViewController: WKURLSchemeHandler, WKNavigationDelegate {
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let host = navigationAction.request.url?.host {
            if let model: CommonWebViewM = getParams(url: navigationAction.request.url!) {
                print(model.nickName!)
                print(model.dictionary)
            }
            print(host)
            if host.contains("yap.co") {
//                viewModel.inputs.completeObserver.onNext(())
//                viewModel.inputs.completeObserver.onCompleted()
            }
        }
        decisionHandler(.allow)
    }
    
}

// MARK: -
fileprivate extension CommonWebViewController {
    func getParams(url: URL) -> CommonWebViewM? {
        do {
            if let componenets = url.toQueryItems()?.toDictionary() {
                return try CommonWebViewM(from: componenets)
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}
