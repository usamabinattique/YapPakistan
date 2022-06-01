//
//  TransactionDetailsViewController.swift
//  YAPPakistan
//
//  Created by Umair  on 23/05/2022.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxTheme
import YAPComponents
import RxDataSources

class TransactionDetailsViewController: UIViewController {
    
    // MARK: - Views
    
    private lazy var headerView = UIFactory.makeView()
    private lazy var headerBackgroundImage = UIFactory.makeImageView()
//    private lazy var headerLogoImage = UIFactory.makeImageView()
    
    
    private lazy var headerShareBtn = UIFactory.makeButton(with: .micro)
    private lazy var headerCloseBtn = UIFactory.makeButton(with: .micro)
    private lazy var btnHelp = UIFactory.makeButton(with: .large,title: "Something wrong? Get help")
    
    
    private lazy var headerLogoImage: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.roundView()
        return imageView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 437
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var stackView = UIFactory.makeStackView(axis: .vertical, alignment: .center, distribution: .fill, spacing: 30, arrangedSubviews: [headerView, tableView])
    
    private var backButton: UIButton!
    
    // MARK: - Properties
    var viewModel: TransactionDetailsViewModel!
    private lazy var imagePicker = UIImagePickerController()
    private var themeService: ThemeService<AppTheme>!
    private var disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    
    // MARK: - Init
    init(themeService: ThemeService<AppTheme>, viewModel: TransactionDetailsViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.themeService = themeService
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton = addBackButton(of: .closeEmpty)
        
        setupSubViews()
        setupConstraints()
        setupBindings()
        setupTheme()
        setupResources()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // viewModel.inputs.fetchDataObserver.onNext(())
    }
    
}

extension TransactionDetailsViewController: ViewDesignable {
    func setupSubViews() {
        headerView.addSubview(headerBackgroundImage)
        headerView.addSubview(headerLogoImage)
        headerView.addSubview(headerShareBtn)
        headerView.addSubview(headerCloseBtn)
        
        view.addSubview(stackView)
        view.addSubview(btnHelp)
        
        headerShareBtn.setImage(UIImage(named: "icon_share", in: .yapPakistan), for: .normal)
        headerCloseBtn.setImage(UIImage(named: "icon_close", in: .yapPakistan), for: .normal)
        
       
        tableView.register(TransactionDetailsMapCell.self, forCellReuseIdentifier: TransactionDetailsMapCell.defaultIdentifier)
        tableView.register(TDTransactionDetailTableViewCell.self, forCellReuseIdentifier: TDTransactionDetailTableViewCell.defaultIdentifier)
        tableView.register(TransactionDetailCategoryCell.self, forCellReuseIdentifier: TransactionDetailCategoryCell.defaultIdentifier)
        tableView.register(TDTitleTableViewCell.self, forCellReuseIdentifier: TDTitleTableViewCell.defaultIdentifier)
        tableView.register(TDTransactionOptionsTableViewCell.self, forCellReuseIdentifier: TDTransactionOptionsTableViewCell.defaultIdentifier)
        tableView.register(TransactionDetailsAmountInfoCell.self, forCellReuseIdentifier: TransactionDetailsAmountInfoCell.defaultIdentifier)
        tableView.register(TDTransactionTotalPurchaseTableViewCell.self, forCellReuseIdentifier: TDTransactionTotalPurchaseTableViewCell.defaultIdentifier)
        tableView.register(TDReceiptsTableViewCell.self, forCellReuseIdentifier: TDReceiptsTableViewCell.defaultIdentifier)
        tableView.register(TransactionDetailImproveAttributesCell.self, forCellReuseIdentifier: TransactionDetailImproveAttributesCell.defaultIdentifier)
       // tableView.register(RateYourExperienceTableViewCell.self, forCellReuseIdentifier: RateYourExperienceTableViewCell.)
    }
    
    func setupConstraints() {
        
        stackView
            .alignEdgesWithSuperview([.top,.left,.right])
            //.alignAllEdgesWithSuperview()
        
        btnHelp
            .toBottomOf(stackView,constant: 12)
            .alignEdgeWithSuperviewSafeArea(.bottom,constant: 8)
            .centerHorizontallyInSuperview()
        
        headerView
            .alignEdgesWithSuperview([.top, .left, .right], constants: [0, 0, 0])
            .height(constant: 212)
        
        headerBackgroundImage
            .alignAllEdgesWithSuperview()
        
        headerLogoImage
            .alignEdgesWithSuperview([.bottom, .left], constants: [24, 24])
            .height(constant: 64)
            .width(constant: 64)
        
        headerShareBtn
            .alignEdgesWithSuperview([.safeAreaTop, .right], constants: [0, 25])
            .height(constant: 32)
            .width(constant: 32)
        
        headerCloseBtn
            .alignEdgesWithSuperview([.safeAreaTop, .left], constants: [0, 25])
            .height(constant: 32)
            .width(constant: 32)
        
        tableView
            .toBottomOf(headerView, constant: 0)
            .alignEdgesWithSuperview([.left, .right, .safeAreaBottom], constants: [0, 0, 0])
            .widthEqualToSuperView()
        
    }
    
    func setupBindings() {
//        self.title = "Account limits"
        self.view.backgroundColor = .white
        self.stackView.backgroundColor = .white
        
        backButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: disposeBag)
        headerShareBtn.rx.tap.bind(to: viewModel.inputs.shareObserver).disposed(by: disposeBag)
        viewModel.outputs.error.subscribe(onNext: { [weak self] errorMessage in
            self?.showAlert(title: "", message: errorMessage, defaultButtonTitle: "common_button_ok".localized)
        }).disposed(by: disposeBag)
        
//        viewModel.outputs.loading.subscribe(onNext: { flage in
//            switch flage { case true: YAPProgressHud.showProgressHud()
//            case false: YAPProgressHud.hideProgressHud() }
//        }).disposed(by: disposeBag)
        
        bindTableView()
        
        self.viewModel.outputs.openReceiptImagePicker.subscribe(onNext: { [weak self] _ in
            self?.bindImageSourceType()
        }).disposed(by: disposeBag)
    }
    
    func setupTheme() {
        self.themeService.rx
            .bind({ UIColor($0.primaryDiffuse) }, to: headerView.rx.backgroundColor)
            .bind({ UIColor($0.backgroundColor) }, to: view.rx.backgroundColor)
            .bind({ UIColor($0.primary) }, to: backButton.rx.tintColor, btnHelp.rx.titleColor(for: .normal))
            .bind({ UIColor($0.backgroundColor) }, to: tableView.rx.backgroundColor)
            .disposed(by: disposeBag)
    }
    
    func bindTableView() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { [unowned self] (_, tableView, _, viewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier) as! RxUITableViewCell
            cell.configure(with: self.themeService, viewModel: viewModel)
            return cell
        })
        
        viewModel.outputs.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                let cell = self?.tableView.cellForRow(at: indexPath)
                if cell is TransactionDetailImproveAttributesCell {
                    self?.viewModel.inputs.improveCategoryAttributeObserver.onNext(())
                }
                if cell is TransactionDetailCategoryCell {
                    self?.viewModel.inputs.changeCategoryObserver.onNext(nil)
                }
                if (cell is TDTransactionTotalPurchaseTableViewCell) {
                    self?.viewModel.inputs.transactionTotalPurchaseObserver.onNext(())
                }
                if (cell as? TDReceiptsTableViewCell) != nil {
                    self?.bindImageSourceType()
                }
                guard let _ = cell as? TDTransactionOptionsTableViewCell else { return }
                self?.viewModel.inputs.addNoteActionObserver.onNext(())
            }).disposed(by: disposeBag)
        
        headerCloseBtn.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: disposeBag)
        
        viewModel.outputs.transactionUserUrl.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.headerLogoImage.loadImage(with: $0.0.0, placeholder: $0.0.1)
            self.headerLogoImage.contentMode = $0.1
        }).disposed(by: disposeBag)
        
        viewModel.outputs.transactionUserBackgroundImage.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            if let _ = $0.0.0 {
                self.headerBackgroundImage.blur()
            }
            self.headerBackgroundImage.loadImage(with: $0.0.0, placeholder: $0.0.1)
            self.headerBackgroundImage.contentMode = $0.1

        }).disposed(by: disposeBag)
        
        btnHelp.rx.tap.withUnretained(self).subscribe(onNext: { (`self`, _) in
//            self.showHelpAlert()
            self.callNumber(phoneNumber: "+92420000000")
        }).disposed(by: disposeBag)
        
        viewModel.outputs.showReceiptDeleteAlert.withUnretained(self).subscribe(onNext: { `self`,_ in
            self.showDeleteAlert()
        }).disposed(by: disposeBag)

    }
    
    func bindImageSourceType() {
        //TODO: add YapActionSheet
        print("bindImagesource action sheet")
        let actionSheet = YAPActionSheet(title: "Upload your receipt", subTitle: nil, themeService: self.themeService)
        let cameraAction = YAPActionSheetAction(title: "Open Camera", image: UIImage(named: "icon_camera", in: .yapPakistan)) { [weak self] _ in
            //self?.viewModel.inputs.addReceiptViaCameraObserver.onNext(())
            self?.pickImageFromCamera()
        }
        let photosAction = YAPActionSheetAction(title: "Choose photo", image: UIImage(named: "icon_photoLibrary", in: .yapPakistan)) { [weak self] _ in
            //self?.viewModel.inputs.photoTapObserver.onNext(())
            self?.pickImageFromGallery()
        }
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photosAction)
        actionSheet.show()
        
        //self.openActionSheet()
    }
    
    func openActionSheet() {
        let cameraAction = UIAlertAction(title: "Open Camera", style: .default) { [unowned self] _ in
            self.pickImageFromCamera()
        }
        
        let gelleryAction = UIAlertAction(title: "Choose photo", style: .default) { [unowned self] _ in
            self.pickImageFromGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        let alertController = UIAlertController(title: "Upload your receipt", message: nil, preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = self.view.frame
        alertController.addAction(cameraAction)
        alertController.addAction(gelleryAction)
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
    
    private func showHelpAlert() {
        let title = "Help"
        let details = "Need help? call us now at +92420000000"
        let text = title + "\n\n\n" + details + "\n"
        
        let attributted = NSMutableAttributedString(string: text)
        
        attributted.addAttributes([.foregroundColor: UIColor(self.themeService.attrs.primaryDark), .font: UIFont.title3], range: NSRange(location: 0, length: title.count))
        attributted.addAttributes([.foregroundColor: UIColor(self.themeService.attrs.greyDark), .font: UIFont.small], range: NSRange(location: text.count - details.count - 1, length: details.count))
        
        let alert = YAPAlertView(theme: self.themeService, icon: nil, text: attributted, primaryButtonTitle: "Call now", cancelButtonTitle: "Cancel")
        
        alert.show()
        alert.rx.primaryTap.withUnretained(self).subscribe(onNext: { `self`,_ in
           print("call now")
            self.callNumber(phoneNumber: "+92420000000")
        }).disposed(by: disposeBag)
    }
    
    private func callNumber(phoneNumber: String) {
        guard let url = URL(string: "telprompt://\(phoneNumber)"),
            UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func showDeleteAlert() {
        let title = "Alert"
        let details = "Are you sure you want to delete this receipt?"
        let text = title + "\n\n\n" + details + "\n"
        
        let attributted = NSMutableAttributedString(string: text)
        
        attributted.addAttributes([.foregroundColor: UIColor(self.themeService.attrs.primaryDark), .font: UIFont.title3], range: NSRange(location: 0, length: title.count))
        attributted.addAttributes([.foregroundColor: UIColor(self.themeService.attrs.greyDark), .font: UIFont.small], range: NSRange(location: text.count - details.count - 1, length: details.count))
        
        let alert = YAPAlertView(theme: self.themeService, icon: nil, text: attributted, primaryButtonTitle: "Delete", cancelButtonTitle: "Cancel")
        
        alert.show()
        alert.rx.primaryTap.withUnretained(self).subscribe(onNext: { `self`,_ in
            self.viewModel.inputs.confirmDeleteReceiptObserver.onNext(())
        }).disposed(by: disposeBag)

    }
}

//MARK: // UIImagePickerDelegate
extension TransactionDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        imagePicker.dismiss(animated: true) { [weak self] in
            self?.viewModel.inputs.receiptPhotoObserver.onNext(image)
        }
    }
}
