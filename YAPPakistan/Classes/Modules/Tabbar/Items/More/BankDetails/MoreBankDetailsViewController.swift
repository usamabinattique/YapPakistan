//
//  MoreBankDetailsViewController.swift
//  YAPPakistan
//
//  Created by Awais on 28/03/2022.
//

import UIKit
import YAPComponents
import RxSwift
import RxCocoa
import RxTheme

class MoreBankDetailsViewController: UIViewController {
    
    // MARK: Views
    
    public lazy var sheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public lazy var holder: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public lazy var headerTitle: UILabel = UIFactory.makeLabel(font: .title3, text: "Account details") //.primaryDark
    //public lazy var headerTitle: UILabel = UILabelFactory.createUILabel(with: .primaryDark, textStyle: .title3,text: "Account details")
    
    public lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var name: MoreBankDetailsInfoView = {
        let view = MoreBankDetailsInfoView()
        view.titleText = "screen_more_bank_details_display_text_name".localized
        view.detailText = "Hello From World"
        view.canCopy = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var Account: MoreBankDetailsInfoView = {
        let view = MoreBankDetailsInfoView()
        view.titleText = "screen_more_bank_details_display_text_account".localized
        view.detailText = "Hello From World"
        view.canCopy = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var iban: MoreBankDetailsInfoView = {
        let view = MoreBankDetailsInfoView()
        view.titleText = "screen_more_bank_details_display_text_iban".localized
        view.detailText = "Hello From World"
        view.canCopy = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var shareButton: AppRoundedButton = {
        let button = AppRoundedButtonFactory
            .createAppRoundedButton(title: "screen_more_bank_details_button_share".localized)
        button.titleLabel?.font = UIFont.large
        button.tintColor = UIColor.white
        return button
    }()
    
    // MARK: Properties
    public var window: UIWindow?
    public var viewTop: NSLayoutConstraint!
    public var start: CGFloat = 0
    private var viewModel: MoreBankDetailsViewModelType!
    private let disposeBag = DisposeBag()
    private var themeService: ThemeService<AppTheme>
    
    // MARK: Initialization
    
    init(themeService: ThemeService<AppTheme>,viewModel: MoreBankDetailsViewModelType) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupTheme()
        setupConstraints()
        bindViews()
        addGestureRecognisers()
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.window?.resignKey()
        view.window?.removeFromSuperview()
        window = nil
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.layoutIfNeeded()
        
        viewTop.constant = -1 * sheetView.bounds.height
        
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
            self.view.layoutIfNeeded()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.closeAction(_:)))

        self.sheetView.addGestureRecognizer(tap)

        self.sheetView.isUserInteractionEnabled = true

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        render()
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        holder.roundView()
        sheetView.layer.cornerRadius = 18
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.clipsToBounds = true
    }
    
    public func addGestureRecognisers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeAction(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.cancelsTouchesInView = false
        sheetView.addGestureRecognizer(pan)
    }
    
    // MARK: Actions
//    @objc func openProfile() {
//        viewModel.inputs.settingsObserver.onNext(())
//    }
//
//    @objc
//    func closeAction() {
//        navigationController?.dismiss(animated: true, completion: nil)
//    }
}

// MARK: View setup

private extension MoreBankDetailsViewController {
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [name.rx.titleColor, Account.rx.titleColor, iban.rx.titleColor])
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [name.rx.detailsColor, Account.rx.detailsColor, shareButton.rx.backgroundColor])
        themeService.rx
            .bind({ UIColor( $0.greyDark ) }, to: self.holder.rx.backgroundColor)
    }
    
    func setupViews() {
        
        view.addSubview(sheetView)
        sheetView.addSubview(holder)
        sheetView.addSubview(headerTitle)
        stackView.addArrangedSubview(name)
        stackView.addArrangedSubview(iban)
        stackView.addArrangedSubview(Account)
        sheetView.addSubview(stackView)
        sheetView.addSubview(shareButton)
    }
    
    func setupConstraints() {
        
        sheetView
            .alignEdgesWithSuperview([.left, .right])
            .height(.lessThanOrEqualTo, constant: 517)//UIScreen.main.bounds.height*0.59)
        
        holder
            .alignEdgeWithSuperview(.top, constant: 15)
            .height(constant: 4)
            .width(constant: 60)
            .centerHorizontallyInSuperview()
        
        headerTitle
            .toBottomOf(holder,constant: 17)
            .centerHorizontallyInSuperview()
        
        stackView
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
            .toBottomOf(headerTitle,constant: 17)
            .centerHorizontallyInSuperview()
        
        shareButton
            .toBottomOf(stackView)
            .alignEdgeWithSuperview(.safeAreaBottom, constant: UIDevice.current.hasNotch ? 0 : 15)
            .height(constant: 52)
            .width(constant: 190)
            .centerHorizontallyInSuperview()
        
        viewTop = sheetView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        viewTop.isActive = true
    }
    
    func render() {
        shareButton.roundView()
    }
}

// MARK: Binding

private extension MoreBankDetailsViewController {
    func bindViews() {
        viewModel.outputs.name.bind(to: name.rx.details).disposed(by: disposeBag)
        viewModel.outputs.iban.bind(to: iban.rx.details).disposed(by: disposeBag)
        viewModel.outputs.account.bind(to: Account.rx.details).disposed(by: disposeBag)
//        viewModel.outputs.account.bind(to: account.rx.details).disposed(by: disposeBag)
//        viewModel.outputs.bank.bind(to: bank.rx.details).disposed(by: disposeBag)
//        viewModel.outputs.address.bind(to: address.rx.details).disposed(by: disposeBag)
        //viewModel.outputs.canShare.map{ !$0 }.bind(to: shareButton.rx.isHidden).disposed(by: disposeBag)
        
        shareButton.rx.tap.bind(to: viewModel.inputs.shareObserver).disposed(by: disposeBag)
        
        viewModel.outputs.shareInfo.subscribe(onNext: { [unowned self] text in
            //AppAnalytics.shared.logEvent(MoreEvent.shareBankDetails())
            let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        
    }
}

extension MoreBankDetailsViewController {
    @objc
    func closeAction(_ tap: UITapGestureRecognizer) {
        guard tap.location(in: view).y < sheetView.frame.origin.y + 50 else { return }
        
        completeHide(0)
    }
    
    @objc
    func handlePan(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            start = pan.location(in: sheetView).y
            
        case .changed:
            changePosition(pan.location(in: view).y - start)
            
        case .ended:
            let progress = ((sheetView.frame.origin.y - (view.bounds.height - sheetView.bounds.height)) / sheetView.bounds.height)
            let velocity = pan.velocity(in: view).y
            if progress < 0.25 {
                velocity < 900 ? completeShow(velocity) : completeHide(velocity)
            } else {
                velocity > -900 ? completeHide(velocity) : completeShow(velocity)
            }
            
        default:
            break
        }
    }
    
    func changePosition(_ y: CGFloat) {
        guard y >= (view.bounds.height - sheetView.bounds.height) else { return }
        var frame = sheetView.frame
        frame.origin.y = y
        sheetView.frame = frame
        let progress = ((sheetView.frame.origin.y - (view.bounds.height - sheetView.bounds.height)) / sheetView.bounds.height)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5 * (1 - progress))
    }
    
    func completeShow(_ velocity: CGFloat) {
        let distance = sheetView.frame.origin.y - (view.bounds.height - sheetView.bounds.height)
        
        var time: TimeInterval = abs(velocity) > 0 ? TimeInterval(abs(distance)/abs(velocity)) : 0.25
        time = time > 0.25 ? 0.25 : time
        
        UIView.animate(withDuration: time) {
            self.sheetView.frame.origin.y = self.view.bounds.height - self.sheetView.bounds.height
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    
    func completeHide(_ velocity: CGFloat) {
        let distance = view.bounds.height - sheetView.frame.origin.y
        
        var time: TimeInterval = abs(velocity) > 0 ? TimeInterval(abs(distance)/abs(velocity)) : 0.25
        time = time > 0.25 ? 0.25 : time
        
        UIView.animate(withDuration: time, animations: {
            self.sheetView.frame.origin.y = self.view.bounds.height
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        }) { (completed) in
            guard completed else { return }
            self.navigationController?.dismiss(animated: false, completion: nil)
        }
    }
}

//// MARK: Root View controller
//public class YAPActionSheetRootViewController: UIViewController {
//    public override var preferredStatusBarStyle: UIStatusBarStyle {
//        get {
//            return UIApplication.shared.statusBarStyle
//        }
//    }
//}
