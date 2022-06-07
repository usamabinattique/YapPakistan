//
//  AddressViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 19/10/2021.
//

import Foundation
import RxSwift
import GoogleMaps
import GooglePlaces

protocol AddressViewModelInput {
    var openMapObserver: AnyObserver<UITapGestureRecognizer> { get }
    var searchObserver: AnyObserver<Void> { get }
    var currentLocationObserver: AnyObserver<Void> { get }
    var confirmLocationObserver: AnyObserver<Void> { get }
    var willMoveObserver: AnyObserver<Bool> { get }
    var didIdleAtObserver: AnyObserver<GMSCameraPosition> { get }
    var nextObserver: AnyObserver<Void> { get }
    var cityObserver: AnyObserver<Void> { get }
    var citySelectObserver: AnyObserver<String> { get }
    var backObserver: AnyObserver<Void> { get }
    var addressObserver: AnyObserver<String> { get }
}

protocol AddressViewModelOutput {
    var openMap: Observable<Bool> { get }
    var search: Observable<Void> { get }
    var location: Observable<LocationModel> { get }
    var confirm: Observable<LocationModel> { get }
    var isMapMarker: Observable<Bool> { get }
    var next: Observable<LocationModel> { get }
    var back: Observable<Void> { get }
    var city: Observable<Void> { get }
    var citySelected: Observable<String> { get }
    var loader: Observable<Bool> { get }
    var error: Observable<String> { get }
    var languageStrings: Observable<AddressViewModel.LanguageStrings> { get }
}

protocol AddressViewModelType {
    var inputs: AddressViewModelInput { get }
    var outputs: AddressViewModelOutput { get }
}

class AddressViewModel: AddressViewModelType, AddressViewModelInput, AddressViewModelOutput {

    // MARK: Inputs
    var openMapObserver: AnyObserver<UITapGestureRecognizer> { openMapSubject.asObserver() }
    var searchObserver: AnyObserver<Void> { searchSubject.asObserver() }
    var currentLocationObserver: AnyObserver<Void> { currentLocationSubject.asObserver() }
    var confirmLocationObserver: AnyObserver<Void> { confirmLocationSubject.asObserver() }
    var willMoveObserver: AnyObserver<Bool> { willMoveSubject.asObserver() }
    var didIdleAtObserver: AnyObserver<GMSCameraPosition> { didIdleAtSubject.asObserver() }
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backObserSubject.asObserver() }
    var cityObserver: AnyObserver<Void> { citySubject.asObserver() }
    var citySelectObserver: AnyObserver<String> { citySelectSubject.asObserver() }
    var addressObserver: AnyObserver<String> { addressObserverSubject.asObserver() }

    // MARK: Outputs
    var openMap: Observable<Bool> { openMapResultSubject.asObservable() }
    var search: Observable<Void> { searchSubject.asObservable() }
    var location: Observable<LocationModel> { currentLocationResultSubject.skip(1).asObservable() }
    var confirm: Observable<LocationModel> { confirmLocationResultSubject.asObservable() }
    var isMapMarker: Observable<Bool> { isMarkerSubject.asObservable() }
    var next: Observable<LocationModel> { nextResultSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var city: Observable<Void> { citySubject.asObservable() }
    var citySelected: Observable<String> { citySelectSubject.asObserver() }
    var loader: Observable<Bool> { loaderSubject.asObserver() }
    var languageStrings: Observable<LanguageStrings> { languageStringsSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }

    // MARK: Subjects
    private var languageStringsSubject: BehaviorSubject<LanguageStrings>!
    private var nextSubject = PublishSubject<Void>()
    private var nextResultSubject = PublishSubject<LocationModel>()
    private var backObserSubject = PublishSubject<Void>()
    private var backSubject = PublishSubject<Void>()
    private var citySubject = PublishSubject<Void>()
    private var citySelectSubject = PublishSubject<String>()
    private var openMapSubject = PublishSubject<UITapGestureRecognizer>()
    private var openMapResultSubject = BehaviorSubject<Bool>(value: false)
    private var searchSubject = PublishSubject<Void>()
    private var isMarkerSubject = PublishSubject<Bool>()
    private var currentLocationSubject = PublishSubject<Void>()
    private var confirmLocationSubject = PublishSubject<Void>()
    private var currentLocationResultSubject = BehaviorSubject<LocationModel>(value: LocationModel())
    private var confirmLocationResultSubject = PublishSubject<LocationModel>()
    private var willMoveSubject = PublishSubject<Bool>()
    
    private var loaderSubject = BehaviorSubject<Bool>(value: false)
    private var didIdleAtSubject = PublishSubject<GMSCameraPosition>()
    private var errorSubject = PublishSubject<String>()
    private var addressObserverSubject = BehaviorSubject<String>(value: "")
    

    var inputs: AddressViewModelInput { return self }
    var outputs: AddressViewModelOutput { return self }

    fileprivate var disposeBag = DisposeBag()
    private var locationService: LocationService!
    private var kycRepository: KYCRepository!
    private var accountProvider: AccountProvider!
    private let configuration: YAPPakistanConfiguration

    init(locationService: LocationService, kycRepository: KYCRepository, accountProvider: AccountProvider, configuration: YAPPakistanConfiguration) {

        self.locationService = locationService
        self.kycRepository = kycRepository
        self.accountProvider = accountProvider
        self.configuration = configuration
        
        setupGoogleMap()
        languageSetup()

        Observable.just(()).delay(.seconds(1), scheduler: MainScheduler.instance).withUnretained(self)
            .subscribe(onNext: { `self`, _ in self.currentLocationSubject.onNext(()) })
            .disposed(by: disposeBag)

        openMapSubject.skip(1).map({ _ in true }).bind(to: openMapResultSubject).disposed(by: disposeBag)
        confirmLocationSubject.map({ _ in false }).bind(to: openMapResultSubject).disposed(by: disposeBag)

        let backResult = backObserSubject.withLatestFrom(openMapResultSubject).share()
        backResult.filter({ $0 }).map({ _ in false }).bind(to: openMapResultSubject).disposed(by: disposeBag)
        backResult.filter({ !$0 }).map({ _ in () }).bind(to: backSubject).disposed(by: disposeBag)

        willMoveSubject.map({ _ in false }).skip(1).bind(to: isMarkerSubject).disposed(by: disposeBag)

        let shareIdleLocation = didIdleAtSubject.skip(1).map({ $0.target }).share()
        shareIdleLocation.map({ _ in true }).bind(to: isMarkerSubject).disposed(by: disposeBag)

        let currentLocation = currentLocationSubject.withUnretained(self)
            .flatMapLatest { `self`, _ in self.locationService.getLocation() }
            .do(onNext: { location in
                print(location)
            })
            .materialize()
            .debug()
            .share()

        let locationDecoded = currentLocation.elements().merge(with: shareIdleLocation).withUnretained(self)
            .flatMapLatest { $0.0.locationService.reverseGeocodeCoordinate($0.1) }
            .materialize().share()

        confirmLocationSubject
            .withLatestFrom(currentLocationResultSubject).withUnretained(self)
            .subscribe(onNext: {`self`, loc in
                DispatchQueue.main.async {
                    self.currentLocationResultSubject.onNext(loc)
                }
            })
            .disposed(by: disposeBag)
        
        locationDecoded.elements().debug("locationDecoded going to bind").bind(to: currentLocationResultSubject).disposed(by: disposeBag)

        //TODO: [UMAIR] - Discuss this skip with Hussaan and replace with appropriate solution
        let saveAddressRequest = nextSubject.skip(1)
            .withLatestFrom(
                Observable.combineLatest(currentLocationResultSubject,addressObserverSubject)
            )
          //  .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(true) })
            .map({ (location, address) -> LocationModel in
                var location = location
                if address.count > 0 {
                    location.address = []
                    location.address.append(address)
                }
                return location
            }).bind(to: nextResultSubject).disposed(by: disposeBag)
    }
    
    func setupGoogleMap() {
        GMSServices.provideAPIKey(configuration.googleMapsAPIKey)
        GMSPlacesClient.provideAPIKey(configuration.googleMapsAPIKey)
    }

    struct LanguageStrings {
        let title: String
        let subTitle: String
        let location: String
        let address: String
        let flatnumber: String
        let city: String
        let next: String
    }
}

fileprivate extension AddressViewModel {
    func languageSetup() {
        let strings = LanguageStrings(title: "screen_kyc_address_title".localized,
                                      subTitle: "screen_kyc_address_subtitle".localized,
                                      location: "screen_kyc_address_taplocation".localized,
                                      address: "screen_kyc_address_address".localized,
                                      flatnumber: "screen_kyc_address_flatbuilding".localized,
                                      city: "screen_kyc_address_city".localized,
                                      next: "common_button_next".localized)
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}
