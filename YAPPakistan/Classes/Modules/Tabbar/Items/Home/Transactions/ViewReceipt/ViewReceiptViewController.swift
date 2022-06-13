//
//  ViewReceiptViewController.swift
//  YAPPakistan
//
//  Created by Awais on 30/05/2022.
//

import UIKit
import RxSwift
import RxTheme
import YAPComponents
import RxDataSources

class ViewReceiptViewController: UIViewController {
    
    // MARK: - Init
    init(viewModel: ViewReceiptViewModelType, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Views
    private lazy var receiptImage = UIFactory.makeImageView()
    
    private lazy var shareBtn = UIFactory.makeButton(with: .regular, backgroundColor: .clear, title: nil)
    private lazy var deleteBtn = UIFactory.makeButton(with: .regular, backgroundColor: .clear, title: nil)
    
    private lazy var stack: UIStackView = UIStackViewFactory.createStackView(with: .horizontal, alignment: .center, distribution: .fillEqually, spacing: 15)
    
    // MARK: - Properties
    let viewModel: ViewReceiptViewModelType
    let disposeBag: DisposeBag
    private var themeService: ThemeService<AppTheme>
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Receipt"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "icon_close",in: .yapPakistan), style: .plain, target: self, action: #selector(backAction))
        
        setup()
        bind()
    }
    
    // MARK: Actions
    @objc
    private func backAction() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //viewModel.inputs.viewWillAppearObserver.onNext(())
    }
    
    override internal func onTapBackButton() {
        //viewModel.inputs.backObserver.onNext(())
    }
    
    private func getScreenshot(view: UIView) -> UIImage? {
        //creates new image context with same size as view
        // UIGraphicsBeginImageContextWithOptions (scale=0.0) for high res capture
        UIGraphicsBeginImageContextWithOptions(view.frame.size, true, 0.0)
        
        // renders the view's layer into the current graphics context
        if let context = UIGraphicsGetCurrentContext() { view.layer.render(in: context) }
        
        // creates UIImage from what was drawn into graphics context
        let screenshot: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        
        // clean up newly created context and return screenshot
        UIGraphicsEndImageContext()
        return screenshot
    }
    
    deinit {
        print("+=+++++++de init")
    }
}

// MARK: - Setup
fileprivate extension ViewReceiptViewController {
    func setup() {
        setupViews()
        setupConstraints()
        setupTheme()
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [(navigationItem.leftBarButtonItem?.rx.tintColor)!])
            //.bind({ UIColor($0.primary) }, to: [shareBtn.rx.backgroundColor])
    }
    
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(receiptImage)
        view.addSubview(stack)
        receiptImage.image = UIImage(named: "icon_receipt", in: .yapPakistan)
        receiptImage.contentMode = .scaleAspectFit
        shareBtn.setImage(UIImage(named: "icon_share", in: .yapPakistan), for: .normal)
        deleteBtn.setImage(UIImage(named: "icon_delete", in: .yapPakistan), for: .normal)
        shareBtn.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        stack.addArrangedSubviews([shareBtn, deleteBtn])
    }
    
    @objc private func shareAction() {
        let imageShare = [ self.receiptImage.image ]
        let activityViewController = UIActivityViewController(activityItems: imageShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func setupConstraints() {

        receiptImage
            .alignEdgesWithSuperview([.top, .left, .right], constants: [0,0,0])
            .toTopOf(stack, constant: 24)
        
        stack
            .alignEdgesWithSuperview([.left, .right, .bottom], constants: [24,24,24])
            .height(constant: 70)
    }
}


// MARK: - Bind
fileprivate extension ViewReceiptViewController {
    func bind() {
        self.deleteBtn.rx.tap.bind(to: self.viewModel.inputs.deleteObserver).disposed(by: disposeBag)
        
        self.viewModel.outputs.loadImage.subscribe(onNext: { [weak self] imageURL in
            self?.receiptImage.sd_setImage(with: URL(string: imageURL), completed: nil)
        }).disposed(by: disposeBag)
    }
}


