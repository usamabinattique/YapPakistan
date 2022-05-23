//
//  AddTransactionNoteViewController.swift
//  YAPPakistan
//
//  Created by Awais on 23/05/2022.
//

import UIKit
import RxSwift
import RxTheme
import YAPComponents
import RxDataSources

class AddTransactionNoteViewController: UIViewController {
    
    // MARK: - Init
    init(viewModel: AddTransactionDetailViewModelType, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Views
    let noteTextView : UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.font = UIFont.systemFont(ofSize: 16)
        view.backgroundColor = .white
        return view
    }()
    
    let seperatorView = UIFactory.makeView()
    let saveBarButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: nil) // action:#selector(Class.MethodName)
    
    // MARK: - Properties
    let viewModel: AddTransactionDetailViewModelType
    let disposeBag: DisposeBag
    private var themeService: ThemeService<AppTheme>
    
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "icon_close",in: .yapPakistan), style: .plain, target: self, action: #selector(backAction))
        navigationItem.rightBarButtonItem = saveBarButton
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
    
    deinit {
        print("+=+++++++de init")
    }
}

// MARK: - Setup
fileprivate extension AddTransactionNoteViewController {
    func setup() {
        
        self.noteTextView.delegate = self
        
        setupViews()
        setupConstraints()
        setupTheme()
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.greyLight) }, to: [seperatorView.rx.backgroundColor])
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [(navigationItem.leftBarButtonItem?.rx.tintColor)!])
        navigationItem.rightBarButtonItem?.tintColor = UIColor(themeService.attrs.primaryDark)
    }
    
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(seperatorView)
        view.addSubview(noteTextView)
        setupNoteTextView()
    }
    
    func setupConstraints() {
        seperatorView
            .alignEdgesWithSuperview([.safeAreaTop, .safeAreaLeft, .safeAreaRight], constants: [10,0,0])
            .height(constant: 1)
        noteTextView
            .alignEdgesWithSuperview([.left, .right, .safeAreaBottom], constants: [20,15,10])
            .alignEdge(.top, withView: seperatorView, constant: 15)
        
    }
    
    private func setupNoteTextView() {
        title = "Add a note"
        noteTextView.text = "Type Something..."
        noteTextView.textColor = UIColor(themeService.attrs.greyDark)
    }
    
    private func enableSaveBarButton() {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(self.themeService.attrs.primaryDark)
    }
    
    private func disableSaveBarButton() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(self.themeService.attrs.greyDark)
    }
    
}


// MARK: - Bind
fileprivate extension AddTransactionNoteViewController {
    func bind() {
        saveBarButton.rx.tap.bind(to: viewModel.inputs.saveNoteTappedObserver).disposed(by: disposeBag)
        noteTextView.rx.text.unwrap().bind(to: viewModel.inputs.noteTextViewObserver).disposed(by: disposeBag)
        viewModel.outputs.error.bind(to: view.rx.showAlert(ofType: .error)).disposed(by: disposeBag)
        
        viewModel.outputs.note.subscribe(onNext: { [weak self] note in
            guard let self = self else { return }
            self.noteTextView.text = note
            self.enableSaveBarButton()
            self.noteTextView.textColor = UIColor(self.themeService.attrs.primary)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.isActiveSaveBtn.subscribe(onNext: { [weak self] isActive in
            guard let self = self else { return }
            if isActive {
                self.enableSaveBarButton()
            }
            else {
                self.disableSaveBarButton()
            }
        }).disposed(by: disposeBag)
    }
}

extension AddTransactionNoteViewController : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(themeService.attrs.greyDark) {
            textView.text = nil
            textView.textColor = UIColor(themeService.attrs.primary)
        }
    }
}
