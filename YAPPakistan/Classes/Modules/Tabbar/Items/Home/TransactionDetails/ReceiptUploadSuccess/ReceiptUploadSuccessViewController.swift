//
//  ReceiptUploadSuccessViewController.swift
//  YAPPakistan
//
//  Created by Awais on 30/05/2022.
//

import UIKit
import RxSwift
import RxTheme
import YAPComponents
import RxDataSources

class ReceiptUploadSuccessViewController: UIViewController {
    
    // MARK: - Init
    init(viewModel: ReceiptUploadSuccessViewModelType, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Views
    
    let innerView = UIFactory.makeView()
    let titleLabel = UIFactory.makeLabel(font: .title2, alignment: .center, numberOfLines: 0, text: "Receipt")
    let subTitleLabel = UIFactory.makeLabel(font: .regular, alignment: .center, numberOfLines: 0, text: "Your receipt has been added")
    
    let addAnotherReceiptButton = UIFactory.makeButton(with: .large, backgroundColor: .clear, title: "Add another receipt")
    let receiptImage = UIFactory.makeImageView()
    
    let doneBtn = UIFactory.makeAppRoundedButton(with: .large, title: "Done")//.makeButton(with: .large, title: "Done")
    
//    let noteTextView : UITextView = {
//        let view = UITextView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = 15
//        view.layer.masksToBounds = true
//        view.font = UIFont.systemFont(ofSize: 16)
//        view.backgroundColor = .white
//        return view
//    }()
    
//    let seperatorView = UIFactory.makeView()
//    let saveBarButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: nil) // action:#selector(Class.MethodName)
    
    // MARK: - Properties
    let viewModel: ReceiptUploadSuccessViewModelType
    let disposeBag: DisposeBag
    private var themeService: ThemeService<AppTheme>
    
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "icon_close",in: .yapPakistan), style: .plain, target: self, action: #selector(backAction))
        //navigationItem.rightBarButtonItem = saveBarButton
        setup()
        bind()
    }
    
    // MARK: Actions
    @objc
    private func backAction() {
        //self.navigationController?.dismiss(animated: true, completion: nil)
        
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
    
    deinit {
        print("+=+++++++de init")
    }
}

// MARK: - Setup
fileprivate extension ReceiptUploadSuccessViewController {
    func setup() {
        setupViews()
        setupConstraints()
        setupTheme()
    }
    
    func setupTheme() {
//        themeService.rx
//            .bind({ UIColor($0.greyLight) }, to: [seperatorView.rx.backgroundColor])
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [(navigationItem.leftBarButtonItem?.rx.tintColor)!])
            .bind({ UIColor($0.primaryDark) }, to: [titleLabel.rx.textColor])
            .bind({ UIColor($0.greyDark) }, to: [subTitleLabel.rx.textColor])
            .bind({ UIColor($0.primary) }, to: [addAnotherReceiptButton.rx.titleColor(for: .normal)])
            .bind({ UIColor($0.primary) }, to: [doneBtn.rx.backgroundColor])
            
            
        navigationItem.rightBarButtonItem?.tintColor = UIColor(themeService.attrs.primaryDark)
    }
    
    func setupViews() {
        view.backgroundColor = .clear
        innerView.backgroundColor = .white
        //addAnotherReceiptButton.backgroundColor = UIColor.red
        view.addSubview(innerView)
        innerView.addSubview(titleLabel)
        innerView.addSubview(subTitleLabel)
        innerView.addSubview(addAnotherReceiptButton)
        innerView.addSubview(receiptImage)
        innerView.addSubview(doneBtn)
        
        receiptImage.image = UIImage(named: "icon_receipt", in: .yapPakistan)
        innerView.layer.cornerRadius = 20
        innerView.clipsToBounds = true
    }
    
    func setupConstraints() {
        innerView
            .alignEdgesWithSuperview([.top, .bottom, .left, .right], constants: [100,100,24,24])
        titleLabel
            .alignEdgesWithSuperview([.top, .left, .right], constants: [24, 0, 0])
        subTitleLabel
            .alignEdgesWithSuperview([.left, .right], constants: [0,0])
            .toBottomOf(titleLabel, constant: 8)
        
        receiptImage
            .alignEdgesWithSuperview([.left, .right], constants: [0, 0])
            .toBottomOf(subTitleLabel, constant: 34)
            .toTopOf(doneBtn, constant: 50)
            
        
        doneBtn
            .centerHorizontallyInSuperview()
            .toTopOf(addAnotherReceiptButton, constant: 24)
            .height(constant: 53)
            .width(constant: 158)
        
        addAnotherReceiptButton
            .alignEdgesWithSuperview([.left, .right, .bottom], constants: [10,10,24])
        
//        sepasaseratorView
//            .alignEdgesWithSuperview([.safeAreaTop, .safeAreaLeft, .safeAreaRight], constants: [10,0,0])
//            .height(constant: 1)
//        noteTextView
//            .alignEdgesWithSuperview([.left, .right, .safeAreaBottom], constants: [20,15,10])
//            .alignEdge(.top, withView: seperatorView, constant: 15)
        
    }
}


// MARK: - Bind
fileprivate extension ReceiptUploadSuccessViewController {
    func bind() {
        
        doneBtn.rx.tap.bind(to: self.viewModel.inputs.doneObserver).disposed(by: disposeBag)
        addAnotherReceiptButton.rx.tap.bind(to: self.viewModel.inputs.addAnotherReceiptObserver).disposed(by: disposeBag)
        
//        saveBarButton.rx.tap.bind(to: viewModel.inputs.saveNoteTappedObserver).disposed(by: disposeBag)
//        noteTextView.rx.text.unwrap().bind(to: viewModel.inputs.noteTextViewObserver).disposed(by: disposeBag)
//        viewModel.outputs.error.bind(to: view.rx.showAlert(ofType: .error)).disposed(by: disposeBag)
//
//        viewModel.outputs.note.subscribe(onNext: { [weak self] note in
//            guard let self = self else { return }
//            if note == "Type Something..." {
//                self.noteTextView.textColor = UIColor(self.themeService.attrs.greyDark)
//            }
//            else {
//                self.noteTextView.textColor = UIColor(self.themeService.attrs.primary)
//            }
//            self.noteTextView.text = note
//            self.enableSaveBarButton()
//            self.noteTextView.textColor = UIColor(self.themeService.attrs.primary)
//        }).disposed(by: disposeBag)
//
//        viewModel.outputs.isActiveSaveBtn.subscribe(onNext: { [weak self] isActive in
//            guard let self = self else { return }
//            if isActive {
//                self.enableSaveBarButton()
//            }
//            else {
//                self.disableSaveBarButton()
//            }
//        }).disposed(by: disposeBag)
    }
}

