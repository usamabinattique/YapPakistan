//
//  TransactionDetailsMapCellViewModel.swift
//  YAP
//
//  Created by Zain on 21/02/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import RxSwift
import YAPCore
import YAPComponents
import GoogleMaps
import MapKit

protocol TransactionDetailsMapCellViewModelInput {
    
}

protocol TransactionDetailsMapCellViewModelOutput {
    var categoryImage: Observable<UIImage?>{ get }
    var showImage: Observable<Bool> {get}
    var showMap: Observable<Bool> {get}
    var mapMarker: Observable<GMSMarker?> { get }
}

protocol TransactionDetailsMapCellViewModelType {
    var inputs: TransactionDetailsMapCellViewModelInput { get }
    var outputs: TransactionDetailsMapCellViewModelOutput { get }
}

class TransactionDetailsMapCellViewModel: TransactionDetailsMapCellViewModelType, TransactionDetailsMapCellViewModelInput, TransactionDetailsMapCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var inputs: TransactionDetailsMapCellViewModelInput { self }
    var outputs: TransactionDetailsMapCellViewModelOutput { self }
    var reusableIdentifier: String { TransactionDetailsMapCell.defaultIdentifier }
    
    private let categoryImageSubject = BehaviorSubject<UIImage?>(value: nil)
    private let showImageSubject = BehaviorSubject<Bool>(value: false)
    private let showMapSubject = BehaviorSubject<Bool>(value: false)
    private let mapMarkerSubject = BehaviorSubject<GMSMarker?>(value: nil)
    
    // MARK: - Inputs
    
    // MARK: - Outputs
    var categoryImage: Observable<UIImage?>{ return categoryImageSubject.asObservable() }
    var showImage: Observable<Bool> {showImageSubject}
    var showMap: Observable<Bool> { showMapSubject }
    public var mapMarker: Observable<GMSMarker?> { return mapMarkerSubject }
    
    var transaction: TransactionResponse //CDTransaction
    // MARK: - Init
    init(catImage: UIImage?, showLocation: Bool, cdTransaction: TransactionResponse) { //CDTransaction) {
        self.transaction = cdTransaction
        setupGoogleAPIKey()
        categoryImageSubject.onNext(catImage)
        if isAllowedForMap {
            showImageSubject.onNext(true)
            showMapSubject.onNext(false)
            guard let image = UIImage.sharedImage(named: "icon_map_pin_purple") else {return}
            let marker = createMarker(icon: image)
            mapMarkerSubject.onNext(marker)
        }
        else {
            showImageSubject.onNext(false)
            showMapSubject.onNext(true)
        }
        
    }
    
    func createMarker(icon: UIImage)-> GMSMarker {
        let gMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: self.transaction.latitude, longitude: self.transaction.longitude))
        gMarker.icon = icon
        return gMarker
    }
    
    fileprivate func setupGoogleAPIKey() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GoogleMapsAPIKey") as? String else { return }
        GMSServices.provideAPIKey(apiKey)
    }
}

extension TransactionDetailsMapCellViewModel {
    var isAllowedForMap: Bool {
        switch self.transaction.productCode {
        case .atmWithdrawl, .posPurchase, .eCom:
            if self.transaction.latitude > 0.0 && self.transaction.longitude > 0.0 {
                return true
            }
            return false
        default:
            return false
        }
    }
}

