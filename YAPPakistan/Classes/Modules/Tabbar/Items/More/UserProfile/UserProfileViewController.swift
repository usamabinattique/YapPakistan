//
//  UserProfileViewController.swift
//  YAPPakistan
//
//  Created by Awais on 29/03/2022.
//

import UIKit
import RxSwift
import RxTheme
import YAPComponents
import RxDataSources

class UserProfileViewController: UIViewController {
    
    // MARK: - Init
    init(viewModel: UserProfileViewModelType, themeService: ThemeService<AppTheme>) {
        self.viewModel = viewModel
        self.themeService = themeService
        disposeBag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Views
    
    private lazy var circledView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var profileImageView = UIFactory.makeImageView(contentMode: .scaleAspectFill)
    lazy var profileImageViewContainer = UIView()
    lazy var profilePhotoEditButton = UIButtonFactory.createButton(backgroundColor: .clear) //.createButton(backgroundColor: .clear)
    lazy var profilePhotoEditButtonContainer = UIView()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UserProfileTableViewCell.self, forCellReuseIdentifier: UserProfileTableViewCell.defaultIdentifier)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    lazy var contentStackView = UIStackViewFactory.createStackView(with: .vertical, alignment: .center, distribution: .fill, spacing: 0, arrangedSubviews: [profileImageViewContainer, tableView])
    
    // MARK: - Properties
    private lazy var imagePicker = UIImagePickerController()
    let viewModel: UserProfileViewModelType
    let disposeBag: DisposeBag
    var removeProfilePhotoFlag: Bool? = nil
    private var themeService: ThemeService<AppTheme>
    
    lazy var dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, UserProfileTableViewCellViewModelType>>(
        configureCell: { (_, tableView, _, cellViewModel) in
            let cell = tableView.dequeueReusableCell(withIdentifier: UserProfileTableViewCell.defaultIdentifier) as! UserProfileTableViewCell
            cell.configure(with: cellViewModel, themeService: self.themeService)
            return cell
    })
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "icon_back",in: .yapPakistan), style: .plain, target: self, action: #selector(backAction))
        
        //navigationItem.leftBarButtonItem?.tintColor = UIColor.red
        setup()
        bind()
    }
    
    // MARK: Actions
    @objc
    private func backAction() {
        //accountAlert.hide()
        //viewModel.inputs.backObserver.onNext(())
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        circledView.roundView()
        
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
fileprivate extension UserProfileViewController {
    func setup() {
        setupViews()
        setupConstraints()
        //addBackButton(.closeEmpty)
        setupTheme()
        title = "Settings"
        
    }
    
    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.primaryDark) }, to: [(navigationItem.leftBarButtonItem?.rx.tintColor)!])
    }
    
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(contentStackView)
        circledView.addSubview(profileImageView)
        profileImageViewContainer.addSubview(circledView)
        profileImageViewContainer.addSubview(profilePhotoEditButtonContainer)
        //profileImageView.backgroundColor = UIColor.red
        
        //profileImageViewContainer.backgroundColor = UIColor.red //SessionManager.current.currentAccountType == .b2cAccount ? .clear : .primary
        
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 32
        profileImageView.contentMode = .scaleAspectFill
        profilePhotoEditButtonContainer.backgroundColor = .white
        
        profilePhotoEditButtonContainer.clipsToBounds = true
        profilePhotoEditButtonContainer.layer.cornerRadius = 18
        profilePhotoEditButtonContainer.addSubview(profilePhotoEditButton)
    }
    
    func setupConstraints() {
        
        circledView
            .centerInSuperView()
        
        profileImageView
            .width(constant: 64)
            .height(constant: 64)
            .centerInSuperView()
            .alignEdgesWithSuperview([.left, .top], constant: 5)
        
        profileImageViewContainer.translatesAutoresizingMaskIntoConstraints = false
        profileImageViewContainer.height(constant: 110)
        profileImageViewContainer.alignEdgesWithSuperview([.left, .right])
        
        profilePhotoEditButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        profilePhotoEditButtonContainer.width(constant: 36).height(constant: 36)
        profilePhotoEditButtonContainer.pinEdge(.centerX, toEdge: .right, ofView: profileImageView, constant: -5)
        profilePhotoEditButtonContainer.pinEdge(.centerY, toEdge: .bottom, ofView: profileImageView, constant: -10)
        profilePhotoEditButton.alignEdgesWithSuperview([.left, .top, .right, .bottom], constant: 4)
        
        tableView.alignEdgesWithSuperview([.left, .right])
        contentStackView.alignEdgesWithSuperview([.left, .safeAreaTop, .right, .bottom])
    }
    
    func logoutPopup() {
        showAlert(title: "screen_profile_action_display_text_logout_popups_title".localized, message: "screen_profile_action_display_text_logout_popups_message".localized, defaultButtonTitle: "screen_profile_action_display_text_logout_popups_logout".localized, secondayButtonTitle: "screen_profile_action_display_text_logout_popups_cencel".localized, defaultButtonHandler: { [weak self] _ in
            
            self?.viewModel.inputs.logoutConfirmObserver.onNext(())
            }, secondaryButtonHandler: { [weak self] _ in
                self?.hideAlertView()
            }, completion: nil)
    }
}


// MARK: - Bind
fileprivate extension UserProfileViewController {
    func bind() {
        bindTableView()
        bindProfileImageView()
        bindImageSourceType()
        bindLogoutPopup()
    }
    
    func bindTableView() {
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        viewModel.outputs.userProfileItems.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        profilePhotoEditButton.imageView?.image = UIImage(named: "icon_edit_profile_photo", in: .yapPakistan)
        viewModel.outputs.profilePhotoEditButtonImage.bind(to: profilePhotoEditButton.rx.image(for: .normal)).disposed(by: disposeBag)
    }
    
    func bindProfileImageView() {
        Observable.combineLatest(viewModel.outputs.fullName,
                                 viewModel.outputs.profilePhotoURL, viewModel.outputs.accentColor)
            .subscribe(onNext: { [weak self] (fullName, photoUrl, accentColor) in
                let initialsImage = fullName?.initialsImage(color: accentColor)
                self?.profileImageView.loadImage(with: photoUrl, placeholder: initialsImage, showsIndicator: true, refreshCachedImage: true, completion: { (image, error, url) in
                    if error == nil {
                        self?.profileImageView.image = image
                    }
                })
            }).disposed(by: disposeBag)
    }
    
    
    func openActionSheet() {
        
        print("bindImagesource action sheet")
        let actionSheet = YAPActionSheet(title: "Update profile photo", subTitle: nil, themeService: self.themeService)
        let cameraAction = YAPActionSheetAction(title: "screen_user_profile_display_text_open_camera".localized, image: UIImage(named: "icon_camera", in: .yapPakistan)) { [weak self] _ in
            self?.pickImageFromCamera()
        }
        let photosAction = YAPActionSheetAction(title: "Choose photo".localized, image: UIImage(named: "icon_photoLibrary", in: .yapPakistan)) { [weak self] _ in
            self?.pickImageFromGallery()
        }
        let deleteAction = YAPActionSheetAction(title: "Remove photo".localized, image: UIImage(named: "icon_delete_purple", in: .yapPakistan)) { [weak self] _ in
            self?.removePhoto()
        }
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photosAction)
        actionSheet.addAction(deleteAction)
        actionSheet.show()
        
        
//        let cameraAction = UIAlertAction(title: "Open camera", style: .default) { [unowned self] _ in
//            self.pickImageFromCamera()
//        }
//
//        let gelleryAction = UIAlertAction(title: "Choose photo", style: .default) { [unowned self] _ in
//            self.pickImageFromGallery()
//        }
//
//        let removeAction = UIAlertAction(title: "Remove photo", style: .default) { [unowned self] _ in
//            self.removePhoto()
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
//
//        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//        alertController.popoverPresentationController?.sourceView = self.view
//        alertController.popoverPresentationController?.sourceRect = self.view.frame
//
//        alertController.addAction(gelleryAction)
//        alertController.addAction(cameraAction)
//        alertController.addAction(removeAction)
//        alertController.addAction(cancelAction)
//        present(alertController, animated: true, completion: nil)
        
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
    
    func removePhoto() {
        print("Remove Photo Selected")
        viewModel.inputs.removePhotoTapObserver.onNext(())
    }
    
    
    func bindImageSourceType() {
        profilePhotoEditButton.rx.tap.bind(to: viewModel.inputs.profilePhotoEditObserver).disposed(by: disposeBag)
        
        viewModel.outputs.profilePhotoEditTap.subscribe(onNext: { [weak self] _ in
            
            guard let self = self else { return }
            print("Edid Photo Tapped")
            self.openActionSheet()
            
        }).disposed(by: disposeBag)
        
        
        
//        viewModel.outputs.profilePhotoEditTap.subscribe(onNext: { [unowned self] _ in
//            AppAnalytics.shared.logEvent(ProfileEvent.tapAddPhoto())
//            let actionSheet = YAPActionSheet(title:  "screen_user_profile_display_text_update_profile_photo".localized)
//
//            let cameraAction = YAPActionSheetAction(title:  "screen_user_profile_display_text_open_camera".localized, image: UIImage.sharedImage(named: "icon_camera")?.asTemplate) { [weak self] _ in
//                self?.viewModel.inputs.openCameraTapObserver.onNext(())
//                AppAnalytics.shared.logEvent(ProfileEvent.tapOpenCamera())
//            }
//
//            let photosAction = YAPActionSheetAction(title:  "screen_user_profile_display_text_choose_photo".localized, image: UIImage.sharedImage(named: "icon_photos")?.asTemplate) { [weak self] _ in
//                self?.viewModel.inputs.chooosePhotoTapObserver.onNext(())
//                AppAnalytics.shared.logEvent(ProfileEvent.tapChoosePhoto())
//            }
//
//            if self.removeProfilePhotoFlag != nil && self.removeProfilePhotoFlag == true {
//                let removePhotosAction = YAPActionSheetAction(title:  "screen_user_profile_display_text_remove_photo".localized, image: UIImage.sharedImage(named: "icon_delete")?.asTemplate) { [weak self] _ in
//                    self?.viewModel.inputs.removePhotoTapObserver.onNext(())
//                    AppAnalytics.shared.logEvent(ProfileEvent.tapRemovePhoto())
//                }
//                actionSheet.addAction(cameraAction)
//                actionSheet.addAction(photosAction)
//                actionSheet.addAction(removePhotosAction)
//                actionSheet.show()
//                return
//            }
//            actionSheet.addAction(cameraAction)
//            actionSheet.addAction(photosAction)
//
//            actionSheet.show()
//        }).disposed(by: disposeBag)
    }
    
//    func bindError() {
//        viewModel.outputs.error.subscribe(onNext: { [weak self] error in
//            self?.showAlert(message: error.localizedDescription)
//        }).disposed(by: disposeBag)
//    }
//
//    func bindActivityIndicator() {
//        viewModel.outputs.isRunning.subscribe(onNext: { isRunning in
//            _ = isRunning ? YAPProgressHud.showProgressHud() : YAPProgressHud.hideProgressHud()
//        }).disposed(by: disposeBag)
//    }
//
    func bindLogoutPopup() {
        viewModel.outputs.logoutTap.subscribe(onNext: {[weak self] _ in self?.logoutPopup() }).disposed(by: disposeBag)
    }
}

//MARK: // UIImagePickerDelegate
extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        imagePicker.dismiss(animated: true) { [weak self] in
            self?.viewModel.inputs.changedProfilePhotoObserver.onNext(image)
        }
    }
}

// MARK: - UITableViewDelegate
extension UserProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 && indexPath.row == 4 { return 70 }
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = PaddedLabel()
        label.backgroundColor = .white
        label.font = .small //UIFont.appFont(forTextStyle: .small)
        label.textColor = UIColor.darkGray //.greyDark
        label.text = dataSource[section].model
        label.leftInset = 25
        return label
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 2 {
            return UIView()
        }
        let footer = UIView()
        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.height(constant: 1)
        lineView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.11)
        footer.addSubview(lineView)
        lineView.centerVerticallyInSuperview().alignEdgesWithSuperview([.left, .right], constants: [25, 25])
        return footer
    }
}
