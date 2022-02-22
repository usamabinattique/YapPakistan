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
       // self.dismiss(animated: true, completion: nil)
        //navigationController?.popViewController(animated: true)
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
//            .alignEdgeWithSuperviewSafeArea(.top)
//            .alignEdgeWithSuperviewSafeArea(.bottom)
//            .alignEdgeWithSuperviewSafeArea(.left)
//            .alignEdgeWithSuperviewSafeArea(.right)
            
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
            self.title = "screen_kyc_card_details_screen_title".localized
            self.webView.loadHTMLString(html, baseURL: nil)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.webUrl.subscribe(onNext: { [weak self] html in
            guard let `self` = self else { return }
            self.title = ""
            guard let url = URL(string: html) else { return }
            self.webView.load(URLRequest(url: url))
        }).disposed(by: disposeBag)
        
        viewModel.outputs.error.bind(to: rx.showErrorMessage).disposed(by: disposeBag)
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

