//
//  EditSendMoneyBeneficiaryViewController.swift
//  YAPPakistan
//
//  Created by Muhammad Sohaib on 15/03/2022.
//

import UIKit
import YAPCore
import YAPComponents
import RxSwift
import RxCocoa
import RxDataSources
import RxTheme

class EditSendMoneyBeneficiaryViewController: KeyboardAvoidingViewController {
    
    // MARK: Views
    private lazy var backBarButtonItem = barButtonItem(image: UIImage(named: "icon_back", in: .yapPakistan), insectBy:.zero)
    private lazy var saveBarButtonItem = barButtonItem(title: "screen_send_money_save_beneficiary_button_title".localized, insectBy: .zero)
    
    private lazy var formTableViewController: EditSendMoneyBeneficiaryFormTableViewController = {
        let form = EditSendMoneyBeneficiaryFormTableViewController(themeService: themeService, viewModel)
        form.view.translatesAutoresizingMaskIntoConstraints = false
        return form
    }()
    
    private lazy var sendMoneyButton = AppRoundedButtonFactory.createAppRoundedButton(title: "screen_send_money_display_text_title".localized)
    private lazy var deleteBeneficiaryButton = UIButtonFactory.createButton(title: "screen_send_money_delete_beneficiary_button_title".localized, backgroundColor: .clear)
    
    private lazy var imagePicker = UIImagePickerController()
    
    // MARK: Properties
    
    private let disposeBag = DisposeBag()
    private var themeService: ThemeService<AppTheme>!
    let viewModel: EditSendMoneyBeneficiaryViewModel!
    
    // MARK: Initialization

    init(themeService: ThemeService<AppTheme>,
         _ viewModel: EditSendMoneyBeneficiaryViewModel) {
        self.viewModel = viewModel
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        
        /// View
        setupView()
        setupTheme()
        setupConstraints()
        
        /// Bind
        bindViews()
    }
}

// MARK: View Setup

extension EditSendMoneyBeneficiaryViewController {
    
    func setupView() {
        
        title = "screen_send_money_edit_beneficiary_title".localized
        navigationItem.leftBarButtonItem = backBarButtonItem.barItem
        navigationItem.rightBarButtonItem = saveBarButtonItem.barItem
        
        addChild(formTableViewController)
        view.addSubview(formTableViewController.view)
        formTableViewController.didMove(toParent: self)
        
        view.addSubviews([sendMoneyButton, deleteBeneficiaryButton])
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [view.rx.backgroundColor])
            .bind({ UIColor($0.primary)}, to: [sendMoneyButton.rx.backgroundColor, deleteBeneficiaryButton.rx.titleColorForNormal, saveBarButtonItem.button.rx.titleColorForNormal])
            .disposed(by: rx.disposeBag)
    }
    
    func setupConstraints() {
        
        formTableViewController.view.alignEdgesWithSuperview([.left, .safeAreaTop, .right])
        
        sendMoneyButton
            .toBottomOf(formTableViewController.view)
            .height(constant: 52)
            .width(constant: 192)
            .alignEdgeWithSuperview(.centerX)
            .alignEdgeWithSuperview(.right, .greaterThanOrEqualTo, constant: 10)
            .alignEdgeWithSuperview(.left, .greaterThanOrEqualTo, constant: 10)
        
        deleteBeneficiaryButton
            .toBottomOf(sendMoneyButton, constant: 25)
            .height(constant: 28)
            .width(constant: 192)
            .alignEdgeWithSuperview(.centerX)
            .alignEdgeWithSuperview(.right, .greaterThanOrEqualTo, constant: 10)
            .alignEdgeWithSuperview(.left, .greaterThanOrEqualTo, constant: 10)
            .alignEdgeWithSuperview(.bottomAvoidingKeyboard, constant: 30)
    }
}

// MARK: Binding

extension EditSendMoneyBeneficiaryViewController {
    
    func bindViews() {
        
        /// Event flow: VC -> VM
        backBarButtonItem.button?.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: disposeBag)
        saveBarButtonItem.button.rx.tap.bind(to: viewModel.inputs.saveBeneficiaryObserver).disposed(by: disposeBag)
        sendMoneyButton.rx.tap.bind(to: viewModel.inputs.sendMoneyObserver).disposed(by: disposeBag)
        deleteBeneficiaryButton.rx.tap.bind(to: viewModel.inputs.showDeletePopupObserver).disposed(by: disposeBag)
        
        /// Event flow: VM -> VC
        viewModel.outputs.error.bind(to: rx.showErrorMessage).disposed(by: disposeBag)
            /// Delete Beneficiary
        viewModel.outputs.showDeletePopup.subscribe(onNext: { [weak self] in
            self?.showAlert(title: "", message: "screen_send_money_edit_beneficiary_delete_message_popup".localized, defaultButtonTitle: "screen_send_money_display_text_delete".localized, secondayButtonTitle: "common_button_cancel_lowercase".localized, defaultButtonHandler: { [weak self] _ in
                self?.viewModel.inputs.deleteBeneficiaryObserver.onNext(())
            }, secondaryButtonHandler: nil, completion: nil)
        }).disposed(by: disposeBag)
        /// Open Action sheet for picture
        viewModel.outputs.addProfilePicture.subscribe(onNext: { [weak self] _ in
            self?.openActionSheet()
        }).disposed(by: disposeBag)
    }
}

// MARK: Image picker

extension EditSendMoneyBeneficiaryViewController {
    
    func openActionSheet() {
        let cameraAction = UIAlertAction(title: "Take a Photo", style: .default) { [unowned self] _ in
            self.pickImageFromCamera()
        }
        
        let gelleryAction = UIAlertAction(title: "Choose from Library", style: .default) { [unowned self] _ in
            self.pickImageFromGallery()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = self.view.frame
        
        alertController.addAction(gelleryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    func pickImageFromCamera() {
        imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func pickImageFromGallery() {
        imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
}

extension EditSendMoneyBeneficiaryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        imagePicker.dismiss(animated: true) { [weak self] in
            self?.viewModel.inputs.imageObserver.onNext(image)
        }
    }
}
