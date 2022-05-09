//
//  CardStatementWebViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 07/05/2022.
//

import Foundation

import UIKit
import RxSwift
import RxCocoa
import RxTheme
import WebKit
import YAPComponents

class CardStatementWebViewController: UIViewController {
    
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
    
    private lazy var emailView = UIFactory.makeView()
    private lazy var emailButton = UIFactory.makeAppRoundedButton(with: .large, title: "Email it to me")
    
    private var backButton: UIButton!
    
    // MARK: - Properties
    let viewModel: CardStatementWebViewModel
    private let themeService: ThemeService<AppTheme>
    private let disposeBag: DisposeBag
    
    // MARK: - Init
    init(themeService: ThemeService<AppTheme>, viewModel: CardStatementWebViewModel) {
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
        backButton = addBackButton(of: .backEmpty)
        setupSubViews()
        setupConstraints()
        setupTheme()
        setupBindings()
    }
}

// MARK: - Setup
extension CardStatementWebViewController: ViewDesignable {
    
    func setupSubViews() {
        view.backgroundColor = .white
        view.addSubview(webView)
        emailView.addSubview(emailButton)
        view.addSubview(emailView)
    }
    
    func setupConstraints() {
        webView
            .alignEdgesWithSuperview([.top, .left, .right])
        
        emailView
            .toBottomOf(webView)
            .alignEdgesWithSuperview([.left, .right, .safeAreaBottom])
            .height(constant: 80)
        
        emailButton
            .alignEdgesWithSuperview([.top], constants: [10])
            .centerHorizontallyInSuperview()
            .height(constant: 52)
            .width(constant: 200)
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.primaryDark)}, to: [backButton.rx.tintColor])
            .bind({ UIColor($0.backgroundColor)}, to: [emailView.rx.backgroundColor])
            .bind({ UIColor($0.primary)}, to: [emailButton.rx.enabledBackgroundColor])
            .bind({ UIColor($0.backgroundColor)}, to: [emailButton.rx.titleColor(for: .normal)])
            .disposed(by: rx.disposeBag)
    }
    
    func setupBindings(){
        
        backButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: disposeBag)
        viewModel.outputs.webUrl.subscribe(onNext: { [weak self] html in
            guard let `self` = self else { return }
//            self.title = "Statement".localized
            guard let url = URL(string: html) else { return }
            if let data = try? Data(contentsOf: url) {
                self.webView.load(data, mimeType: "application/pdf", characterEncodingName: "", baseURL: url)
            }
            //self.webView.load(URLRequest(url: url))
        }).disposed(by: disposeBag)
        
        viewModel.outputs.error.bind(to: rx.showErrorMessage).disposed(by: disposeBag)
        emailButton.rx.tap.bind(to: viewModel.inputs.emailButtonObserver).disposed(by: disposeBag)
    }
}

extension CardStatementWebViewController: WKURLSchemeHandler, WKNavigationDelegate {
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
}

