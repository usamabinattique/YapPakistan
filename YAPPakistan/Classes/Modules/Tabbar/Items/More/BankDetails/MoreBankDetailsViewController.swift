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
    
    private lazy var background: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public lazy var headerTitle: UILabel = UIFactory.makeLabel(font: .title3, text: "Account details") //.primaryDark
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 5
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
    
    private lazy var swift: MoreBankDetailsInfoView = {
        let view = MoreBankDetailsInfoView()
        view.titleText = "screen_more_bank_details_display_text_swift".localized
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
    
    private lazy var account: MoreBankDetailsInfoView = {
        let view = MoreBankDetailsInfoView()
        view.titleText = "screen_more_bank_details_display_text_account".localized
        view.detailText = "screen_more_bank_details_display_text_account".localized
        view.translatesAutoresizingMaskIntoConstraints = false
        view.canCopy = true
        return view
    }()
    
    private lazy var bank: MoreBankDetailsInfoView = {
        let view = MoreBankDetailsInfoView()
        view.titleText = "screen_more_bank_details_display_text_bank".localized
        view.detailText = "Hello From World"
        view.translatesAutoresizingMaskIntoConstraints = false
        view.canCopy = true
        return view
    }()
    
    private lazy var address: MoreBankDetailsInfoView = {
        let view = MoreBankDetailsInfoView()
        view.titleText = "screen_more_bank_details_display_text_address".localized
        view.detailText = "Hello From World"
        view.translatesAutoresizingMaskIntoConstraints = false
        view.canCopy = true
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
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back", in: .yapPakistan, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(closeAction))
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back", in: .yapPakistan, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(openProfile))
        
//        navigationItem.title = "screen_more_bank_details_display_text_title".localized
        
        setupViews()
        setupTheme()
        setupConstraints()
        bindViews()
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
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        render()
    }
    
    // MARK: Actions
//    @objc func openProfile() {
//        viewModel.inputs.settingsObserver.onNext(())
//    }
//
    @objc
    func closeAction() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: View setup

private extension MoreBankDetailsViewController {
    func setupTheme() {
        
        themeService.rx
            .bind({ UIColor($0.primary) }, to: [name.rx.titleColor, swift.rx.titleColor, iban.rx.titleColor, account.rx.titleColor, address.rx.titleColor, bank.rx.titleColor])
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [name.rx.detailsColor, swift.rx.detailsColor, iban.rx.detailsColor, account.rx.detailsColor, address.rx.detailsColor, bank.rx.detailsColor, shareButton.rx.backgroundColor])
        
//        themeService.rx
//            .bind({ UIColor($0.primaryDark)}, to: [heading.rx.textColor, allBeneficiaryLabel.rx.textColor])
//            .bind({ UIColor($0.greyDark)}, to: [subHeading.rx.textColor])//[searchBarButtonItem.barItem.rx.tintColor])
//            .bind({ UIColor($0.primary)}, to: [addNowButton.rx.backgroundColor, navigationItem.rightBarButtonItem!.rx.tintColor, navigationItem.leftBarButtonItem!.rx.tintColor])
//            .bind({ UIColor($0.greyDark)}, to: [searchButton.rx.titleColor(for: .normal)])
//            .bind({ UIColor($0.greyDark)}, to: [searchButton.rx.tintColor])
//            .disposed(by: rx.disposeBag)
    }
    
    func setupViews() {
        
        view.addSubview(sheetView)
        sheetView.addSubview(holder)
        sheetView.addSubview(headerTitle)
        stackView.addArrangedSubview(name)
        stackView.addArrangedSubview(iban)
        stackView.addArrangedSubview(account)
        stackView.addArrangedSubview(bank)
        stackView.addArrangedSubview(swift)
        stackView.addArrangedSubview(address)
        sheetView.addSubview(stackView)
        sheetView.addSubview(shareButton)
//        setupSensitiveViews()
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
//        profileImage.roundView(withBorderColor: .white, withBorderWidth: 3)
//        profileImage.layer.cornerRadius = 34
    }
}

// MARK: Binding

private extension MoreBankDetailsViewController {
    func bindViews() {
        //viewModel.outputs.profileImage.bind(to: profileImage.rx.loadImage()).disposed(by: disposeBag)
        viewModel.outputs.name.bind(to: name.rx.details).disposed(by: disposeBag)
        viewModel.outputs.iban.bind(to: iban.rx.details).disposed(by: disposeBag)
        viewModel.outputs.swift.bind(to: swift.rx.details).disposed(by: disposeBag)
        viewModel.outputs.account.bind(to: account.rx.details).disposed(by: disposeBag)
        viewModel.outputs.bank.bind(to: bank.rx.details).disposed(by: disposeBag)
        viewModel.outputs.address.bind(to: address.rx.details).disposed(by: disposeBag)
        viewModel.outputs.canShare.map{ !$0 }.bind(to: shareButton.rx.isHidden).disposed(by: disposeBag)
        
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
        guard tap.location(in: view).y < sheetView.frame.origin.y else { return }
        
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
public class YAPActionSheetRootViewController: UIViewController {
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return UIApplication.shared.statusBarStyle
        }
    }
}
