//
//  AddressViewController.swift
//  YAPPakistan
//
//  Created by Sarmad on 19/10/2021.
//

import YAPComponents
import RxTheme
import GooglePlaces
import RxSwift

class AddressViewController: UIViewController {

    // MARK: Top Container
    private let topContainerView = UIFactory.makeView()
    private let titleLabel = UIFactory.makeLabel(font: .title2, alignment: .center, numberOfLines: 0)
    private let subTitleLabel = UIFactory.makeLabel(font: .small, alignment: .center, numberOfLines: 0)

    // MARK: MAP Container View
    private let mapContainerView = UIFactory.makeView()

    private let tapContainer = UIFactory.makeCircularView()
    private let tapImageView = UIFactory.makeImageView()
    private let tapLabel = UIFactory.makeLabel(font: .micro)

    lazy var marker = GMSFactory.makeMarker(icon: "location_marker")
    lazy var mapView = GMSFactory.makeMapView(markers: [marker]).setUserInteraction(false)
    lazy var markerImageView = UIFactory.makeImageView().setHidden(true)

    lazy var confirmContainer = UIFactory.makeView().setCornerRadius(10).shaddow()
    lazy var locationImage = UIFactory.makeImageView().setCornerRadius(4).shaddow()
    lazy var locationTitle = UIFactory.makeLabel(font: .small, numberOfLines: 2)
    lazy var locationSubTitle = UIFactory.makeLabel(font: .micro, numberOfLines: 2)
    lazy var confirmButton = UIFactory.makeAppRoundedButton(with: .small)

    // MARK: Bottom Container View
    private let bottomContainerView = UIFactory.makeView()
    private let addressTextField = UIFactory.makeFloatingTextField(font: .regular,
                                                                   fontPlaceholder: .small,
                                                                   clearButtonMode: .always,
                                                                   returnKeyType: .done,
                                                                   capitalization: .words)
    private let flatTextField = UIFactory.makeFloatingTextField(font: .regular,
                                                                fontPlaceholder: .small,
                                                                clearButtonMode: .always,
                                                                returnKeyType: .done,
                                                                capitalization: .words)
    private lazy var cityTextField = UIFactory.makeFloatingTextField(font: .regular,
                                                                     fontPlaceholder: .small,
                                                                     capitalization: .words,
                                                                     keyboardType: nil)
    private lazy var backBarButtonItem = barButtonItem(image: UIImage(named: "icon_back_witCircle", in: .yapPakistan), insectBy:.zero)
    

    private let nextButton = UIFactory.makeAppRoundedButton(with: .regular)

    // MARK: properties
    private var searchButton: UIButton!
    var searchTop: NSLayoutConstraint!
    var searchLeft: NSLayoutConstraint!

    private var backButton: UIButton!
    private lazy var currentLocationButton = UIFactory.makeButton(with: .regular).setCornerRadius(17.5)

    private var nextButtonBottomAncher: NSLayoutConstraint!
    private var topContainerHeight: NSLayoutConstraint!
    private var botContainerHeight: NSLayoutConstraint!

    private var themeService: ThemeService<AppTheme>!
    var viewModel: AddressViewModelType!

    convenience init(themeService: ThemeService<AppTheme>,
                     viewModel: AddressViewModelType) {

        self.init(nibName: nil, bundle: nil)

        self.themeService = themeService
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTheme()
        setupResources()
        setupLanguageStrings()
        setupBindings()
        setupConstraints()
        topContainerHeight = topContainerView.heightAnchor.constraint(equalToConstant: 0)
        botContainerHeight = bottomContainerView.heightAnchor.constraint(equalToConstant: 0)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let gFrame = searchButton.globalFrame!
        let constant = UIScreen.size.width - gFrame.origin.x - gFrame.size.width
        searchLeft?.constant = constant
        searchTop?.constant = constant

    }

    func setupViews() {
        view.addSub(views: [mapContainerView, currentLocationButton, topContainerView, bottomContainerView, tapContainer])

        topContainerView.addSub(views: [titleLabel, subTitleLabel])
        mapContainerView.addSub(views: [mapView, markerImageView, confirmContainer])
        bottomContainerView.addSub(views: [addressTextField, flatTextField, cityTextField, nextButton])

        tapContainer.addSub(views: [tapImageView, tapLabel])
        confirmContainer.addSub(views: [locationImage, locationTitle, locationSubTitle, confirmButton])

        backButton = addBackButton(of: .backEmpty)
        let barItem = barButtonItem(image: UIImage(named: "icon_search", in: .yapPakistan)?.asTemplate,
                                    insectBy: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 2))
        self.navigationItem.rightBarButtonItem = barItem.barItem
        self.title = "Address VC"
        self.navigationItem.leftBarButtonItem = backBarButtonItem.barItem
        searchButton = barItem.button
        searchButton.isEnabled = false
        searchButton.alpha = 0
    }

    func setupTheme() {
        themeService.rx
            .bind({ UIColor($0.backgroundColor) }, to: [ view.rx.backgroundColor ])
            .bind({ UIColor($0.backgroundColor) }, to: [ topContainerView.rx.backgroundColor ])
            .bind({ UIColor($0.backgroundColor) }, to: [ bottomContainerView.rx.backgroundColor ])
            .bind({ UIColor($0.primaryDark) }, to: titleLabel.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: subTitleLabel.rx.textColor)
            .bind({ UIColor($0.primary) }, to: nextButton.rx.backgroundColor)
            .bind({ UIColor($0.greyDark) }, to: addressTextField.placeholderLabel.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: addressTextField.rx.textColor)
            .bind({ UIColor($0.greyLight) }, to: addressTextField.rx.bottomLineColorNormal)
            .bind({ UIColor($0.primary) }, to: addressTextField.rx.bottomLineColorWhileEditing)
            .bind({ UIColor($0.greyDark) }, to: flatTextField.placeholderLabel.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: flatTextField.rx.textColor)
            .bind({ UIColor($0.greyLight) }, to: flatTextField.rx.bottomLineColorNormal)
            .bind({ UIColor($0.primary) }, to: flatTextField.rx.bottomLineColorWhileEditing)
            .bind({ UIColor($0.greyDark) }, to: cityTextField.placeholderLabel.rx.textColor)
            .bind({ UIColor($0.primaryDark) }, to: cityTextField.rx.textColor)
            .bind({ UIColor($0.greyLight) }, to: cityTextField.rx.bottomLineColorNormal)
            .bind({ UIColor($0.greyLight) }, to: cityTextField.rx.bottomLineColorWhileEditing)
            .bind({ UIColor($0.primary) }, to: tapContainer.rx.backgroundColor)
            .bind({ UIColor($0.backgroundColor) }, to: tapLabel.rx.textColor)
            .bind({ UIColor($0.backgroundColor) }, to: tapImageView.rx.tintColor)
            .bind({ UIColor($0.greyDark) }, to: addressTextField.rx.clearImageTint)
            .bind({ UIColor($0.greyDark) }, to: flatTextField.rx.clearImageTint)
            .bind({ UIColor($0.primary) }, to: backButton.rx.tintColor)
            .bind({ UIColor($0.primary) }, to: searchButton.rx.backgroundColor)
            .bind({ UIColor($0.backgroundColor) }, to: searchButton.rx.tintColor)
            .bind({ UIColor($0.primary) }, to: currentLocationButton.rx.backgroundColor)
            .bind({ UIColor($0.backgroundColor) }, to: currentLocationButton.rx.tintColor)
            .bind({ UIColor($0.primaryExtraLight) }, to: locationImage.rx.tintColor)
            .bind({ UIColor($0.backgroundColor) }, to: confirmContainer.rx.backgroundColor)
            .bind({ UIColor($0.primaryDark) }, to: locationTitle.rx.textColor)
            .bind({ UIColor($0.greyDark) }, to: locationSubTitle.rx.textColor)
            .bind({ UIColor($0.primary) }, to: confirmButton.rx.backgroundColor)
            .bind({ UIColor($0.backgroundColor) }, to: locationImage.rx.backgroundColor)
            .disposed(by: rx.disposeBag)

        UISearchBar.appearance().tintColor = UIColor(themeService.attrs.primary)
    }

    func setupResources() {
        // mapContainerView.image = UIImage(named: "map_image", in: .yapPakistan)
        tapImageView.image = UIImage(named: "location_icon", in: .yapPakistan)?.template
        markerImageView.image = UIImage(named: "location_marker_still", in: .yapPakistan)
        let image = UIImage(named: "icon_close", in: .yapPakistan)?.asTemplate
        addressTextField.setClearImage(image, for: .normal)
        flatTextField.setClearImage(image, for: .normal)
        cityTextField.setClearImage(UIImage(named: "icon_next", in: .yapPakistan), for: .normal)
        currentLocationButton.setImage(UIImage(named: "current_location", in: .yapPakistan)?.asTemplate, for: .normal)
        locationImage.image = UIImage(named: "location_image", in: .yapPakistan)?.asTemplate

        confirmButton.setTitle("Confirm location", for: .normal)
    }

    func setupLanguageStrings() {
        viewModel.outputs.languageStrings.withUnretained(self)
            .subscribe(onNext: { `self`, strings in
                self.titleLabel.text = strings.title
                self.subTitleLabel.text = strings.subTitle
                self.tapLabel.text = strings.location
                self.addressTextField.placeholder = strings.address
                self.flatTextField.placeholder = strings.flatnumber
                self.cityTextField.placeholder = strings.city
                self.nextButton.setTitle(strings.next, for: .normal)
            })
            .disposed(by: rx.disposeBag)
    }

    func setupBindings() {
        viewModel.outputs.openMap.skip(1).withUnretained(self)
            .subscribe(onNext: { `self`, isOpen in self.mapOpenAction(isOpen) })
            .disposed(by: rx.disposeBag)
        // viewModel.outputs.search
        let currentLocation = viewModel.outputs.location.withUnretained(self).share()
        currentLocation.subscribe(onNext: { `self`, location in
 
            self.locationTitle.text = location.address.first ?? "" // location.formattAdaddress.replacingOccurrences(of: subTitle, with: "")
            self.locationSubTitle.text = location.address.last ?? "" // subTitle

                self.mapView.animate(toLocation: location.coordinates)
            }).disposed(by: rx.disposeBag)
        currentLocation.element(at: 0).subscribe(onNext: { `self`, location in
                self.mapView.animate(toZoom: 15)
            }).disposed(by: rx.disposeBag)

        backBarButtonItem.button?.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
        
        // viewModel.outputs.confirm
        viewModel.outputs.isMapMarker.withUnretained(self)
            .subscribe(onNext: { `self`, isMarker in
                self.marker.position = self.mapView.camera.target
                (self.marker.map, self.markerImageView.isHidden) = (isMarker ? self.mapView: nil, isMarker)
            }).disposed(by: rx.disposeBag)
        viewModel.outputs.citySelected.bind(to: cityTextField.rx.text).disposed(by: rx.disposeBag)
        viewModel.outputs.location.withUnretained(self)
            .subscribe(onNext: { `self`, location in
// <<<<<<< Updated upstream
                self.addressTextField.text = location.address.first ?? ""
                self.flatTextField.text = location.address.last ?? ""
// =======
//                self.addressTextField.text = location.formattAdaddress
// >>>>>>> Stashed changes
                self.cityTextField.text = location.city
            })
            .disposed(by: rx.disposeBag)

        viewModel.outputs.loader.bind(to: rx.loader).disposed(by: rx.disposeBag)

        viewModel.outputs.error.withUnretained(self)
            .subscribe(onNext: { `self`, message in
                self.showAlert(title: "", message: message,
                                defaultButtonTitle: "common_button_ok".localized)
            }).disposed(by: rx.disposeBag)

//        mapView.rx.idleAt.withUnretained(self)
//            .delay(.milliseconds(10), scheduler: MainScheduler.instance)
//            .subscribe(onNext: { `self`, position in
//                self.marker.position = position.target
//                self.marker.map = self.mapView
//                self.markerImageView.isHidden = true
//            })
//            .disposed(by: rx.disposeBag)
//
//        mapView.rx.willMove.withUnretained(self)
//            .subscribe(onNext: { `self`, _ in
//                self.markerImageView.isHidden = false
//                self.marker.map = nil
//            })
//            .disposed(by: rx.disposeBag)

        mapView.rx.idleAt.bind(to: viewModel.inputs.didIdleAtObserver).disposed(by: rx.disposeBag)
        mapView.rx.willMove.bind(to: viewModel.inputs.willMoveObserver).disposed(by: rx.disposeBag)

        currentLocationButton.rx.tap.bind(to: viewModel.inputs.currentLocationObserver).disposed(by: rx.disposeBag)

        tapContainer.rx.tapGesture().bind(to: viewModel.inputs.openMapObserver).disposed(by: rx.disposeBag)
        confirmButton.rx.tap.bind(to: viewModel.inputs.confirmLocationObserver).disposed(by: rx.disposeBag)

        let editingDidBegin = cityTextField.rx.controlEvent(.editingDidBegin).share()
        editingDidBegin.bind(to: viewModel.inputs.cityObserver).disposed(by: rx.disposeBag)
        editingDidBegin.map({ _ in false }).bind(to: cityTextField.rx.isFirstResponder ).disposed(by: rx.disposeBag)
        backButton.rx.tap.bind(to: viewModel.inputs.backObserver).disposed(by: rx.disposeBag)
        nextButton.rx.tap.bind(to: viewModel.inputs.nextObserver).disposed(by: rx.disposeBag)
        
        searchButton.rx.tap.withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.autocompleteClicked() })
            .disposed(by: rx.disposeBag)

        flatTextField.rx.controlEvent(.editingDidBegin).withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                UIView.animate(withDuration: 0.3) {
                    self.nextButtonBottomAncher.constant = 165
                    self.view.layoutSubviews()
                }
            }).disposed(by: rx.disposeBag)

        addressTextField.rx.controlEvent(.editingDidBegin).withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                UIView.animate(withDuration: 0.3) {
                    self.nextButtonBottomAncher.constant = 90
                    self.view.layoutSubviews()
                }
            }).disposed(by: rx.disposeBag)

        flatTextField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] _ in guard let self = self else { return }
                UIView.animate(withDuration: 0.3) {
                    self.nextButtonBottomAncher.constant = 25
                    self.view.layoutSubviews()
                }
            }).disposed(by: rx.disposeBag)

        addressTextField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] _ in guard let self = self else { return }
                UIView.animate(withDuration: 0.3) {
                    self.nextButtonBottomAncher.constant = 25
                    self.view.layoutSubviews()
                }
            }).disposed(by: rx.disposeBag)

        nextButton.rx.tap.bind(to: viewModel.inputs.nextObserver).disposed(by: rx.disposeBag)

        view.rx.tapGesture().withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.view.endEditing(true) })
            .disposed(by: rx.disposeBag)

        let flatNumber = flatTextField.rx.text.asObservable().unwrap()
        let address = addressTextField.rx.text.asObservable().unwrap()
        Observable.combineLatest(flatNumber, address).map{ $0 + $1 }.bind(to: viewModel.inputs.addressObserver).disposed(by: rx.disposeBag)
    }

    func setupConstraints() {
        topContainerView.alignEdgesWithSuperview([.left, .right, .top])

        let gFrame = searchButton.globalFrame!
        let constant = UIScreen.size.width - gFrame.origin.x - gFrame.size.width

        currentLocationButton
            .alignEdgeWithSuperview(.right, constant: constant, assignTo: &searchLeft)
            .alignEdgeWithSuperview(.safeAreaTop, constant: constant, assignTo: &searchTop)
            .width(constant: 35)
            .height(constant: 35)

        titleLabel
            .alignEdgeWithSuperview(.safeAreaTop, constant: 10, priority: UILayoutPriority(753))
            .alignEdgesWithSuperview([.left, .right], constants: [20, 20])

        subTitleLabel
            .toBottomOf(titleLabel, constant: 10)
            .alignEdgesWithSuperview([.left, .right, .bottom], constant: 20)

        mapContainerView
            .alignEdgesWithSuperview([.left, .right, .top, .bottom])
        mapView
            .alignEdgesWithSuperview([.top, .bottom, .right, .left])
        markerImageView
            .centerHorizontallyInSuperview()
            .centerVerticallyInSuperview(constant: 5)
        tapContainer
            .toTopOf(bottomContainerView, constant: 15)
            .alignEdgesWithSuperview([.left], constants: [15])
            .height(constant: 35)
        tapImageView
            .alignEdgesWithSuperview([.left, .top, .bottom], constants: [12, 8, 8])
            .aspectRatio()
        tapLabel
            .alignEdgesWithSuperview([.right], constant: 10)
            .toRightOf(tapImageView, constant: 5)
            .centerVerticallyInSuperview()
        confirmContainer
            .alignEdgesWithSuperview([.left, .right, .safeAreaBottom], constant: 25)
        locationImage
            .alignEdgesWithSuperview([.left, .top, .bottom], constant: 16)
            .widthEqualToSuperView(multiplier: 80 / 325)
            .aspectRatio()
        locationTitle
            .toRightOf(locationImage, constant: 10)
            .alignEdgesWithSuperview([.top, .right], constants: [10, 16])
            .setContentHuggingPriority(UILayoutPriority(750), for: .vertical)
        locationSubTitle
            .toBottomOf(locationTitle)
            .toRightOf(locationImage, constant: 10)
            .alignEdgeWithSuperview(.right, constant: 16)
            .setContentHuggingPriority(UILayoutPriority(745), for: .vertical)
        confirmButton
            .toBottomOf(locationSubTitle, constant: 5)
            .toRightOf(locationImage, constant: 10)
            .alignEdgeWithSuperview(.bottom, constant: 10)
            .width(constant: 150)
            .height(constant: 28)

        bottomContainerView
            .alignEdgesWithSuperview([.left, .right, .bottom])

// <<<<<<< Updated upstream
//        flatTextField
//=======
//        addressTextField
//>>>>>>> Stashed changes
        addressTextField
            .alignEdgesWithSuperview([.left, .right, .top], constants: [25, 25, 20])
            .height(constant: 55)

        flatTextField
            .toBottomOf(addressTextField, constant: 20)
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
            .height(constant: 55)

        cityTextField
            .toBottomOf(flatTextField, constant: 20)
            .alignEdgesWithSuperview([.left, .right], constants: [25, 25])
            .height(constant: 55)

        nextButton
            .toBottomOf(cityTextField, constant: 25)
            .centerHorizontallyInSuperview()
            .width(constant: 250)
            .height(constant: 52)
            .alignEdge(.safeAreaBottom,
                       withView: self.view,
                       constant: 25,
                       priority: UILayoutPriority(750),
                       assignTo: &nextButtonBottomAncher)
    }
}

extension AddressViewController {
    func mapOpenAction(_ isMapView: Bool) {
        self.tapContainer.isHidden = false

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
            // let isMapView = self.topContainerView.frame.size.height != 0
            self.topContainerHeight?.isActive = isMapView
            self.confirmContainer.alpha = isMapView ? 1: 0
            self.currentLocationButton.alpha = isMapView ? 1: 0
            self.searchButton.alpha = isMapView ? 1: 0
            let image = UIImage(named: isMapView ? "icon_back_witCircle": "icon_back",
                                in: .yapPakistan)?.withRenderingMode(.alwaysTemplate)
            self.backButton.setImage(image, for: .normal)
            self.backButton.tintColor = isMapView ? UIColor(self.themeService.attrs.backgroundColor):
                UIColor(self.themeService.attrs.primaryDark)
            self.backButton.backgroundColor = isMapView ? UIColor(self.themeService.attrs.primary): UIColor.clear
            self.view.layoutSubviews()
        }

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
            // let isMapView = self.topContainerView.frame.size.height == 0
            self.botContainerHeight?.isActive = isMapView
            self.tapContainer.alpha = isMapView ? 0: 1
            self.view.layoutSubviews()
        } completion: { _ in
            // let isMapView = self.topContainerView.frame.size.height == 0
            self.searchButton.isEnabled = isMapView
            self.tapContainer.isHidden = isMapView
            self.mapView.setUserInteraction(isMapView)
        }
    }
}

extension AddressViewController {
    @objc func autocompleteClicked() {
        let autocompleteController = GMSAutocompleteViewController()

        autocompleteController.delegate = self

        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                    UInt(GMSPlaceField.placeID.rawValue))
        autocompleteController.placeFields = fields

        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .region
        filter.country = "pk"

        autocompleteController.autocompleteFilter = filter

        // Display the autocomplete view controller.
        self.navigationController?.pushViewController(autocompleteController)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            ((autocompleteController.value(forKey: "_contentController") as? UIViewController)?
                .value(forKey: "_resultsController") as? UIViewController)?.children.first?
                .navigationController?.navigationBar.tintColor = UIColor(self.themeService.attrs.primary)
        }
    }
}

extension AddressViewController: GMSAutocompleteViewControllerDelegate {

    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {

        LocationService().getPlace(placeID: place.placeID ?? "").asObservable().withUnretained(self)
            .subscribe(onNext: { `self`, placeDetail in
                self.mapView.animate(toLocation: placeDetail.coordinate)
            }).disposed(by: rx.disposeBag)

        self.navigationController?.popViewController(animated: true)
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }

    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

}
