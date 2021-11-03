//
//  LocationService.swift
//  YAPPakistan
//
//  Created by Sarmad on 02/11/2021.
//

import CoreLocation
import GoogleMaps
import GooglePlaces
import RxSwift

class LocationService {
    
    func getLocation() -> Observable<CLLocationCoordinate2D> {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager.rx.location.debug().map({
            $0?.coordinate
        }).unwrap()
    }

    func reverseGeocodeCoordinate(_ coordinates: CLLocationCoordinate2D) -> Single<LocationModel> {
        return Observable<LocationModel>.create { observable in
            let coder = GMSGeocoder()
            coder.accessibilityLanguage = "en"
            coder.reverseGeocodeCoordinate(coordinates) { response, error in

                if let error = error {
                    observable.onError(error)
                } else {
                    guard let result = response?.firstResult(), let lines = result.lines else {
                        observable.onError(NSError())
                        return
                    }

                    var address = (lines.first ?? "") + " \(lines.count > 1 ? ", \(lines[1])":"")"
                    if let country = result.country?.trimmed, !address.lowercased().contains(country.lowercased()) {
                        address += ", \(country)"
                    }

                    observable.onNext(LocationModel(coordinates: coordinates,
                                                    country: result.country,
                                                    state: result.administrativeArea,
                                                    city: result.locality,
                                                    formattAdaddress: address))
                    observable.onCompleted()
                }
            }
            return Disposables.create()
        }.asSingle()
    }

    func getPlace(placeID: String) -> Single<GMSPlace> {
        return Observable<GMSPlace>.create { observable in
            let fields: GMSPlaceField = GMSPlaceField.coordinate

            let placesClient = GMSPlacesClient()

            placesClient.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil, callback: {
                (place: GMSPlace?, error: Error?) in
                if let error = error {
                    observable.onError(error)
                    return
                }
                if let place = place {
                    observable.onNext(place)
                    observable.onCompleted()
                }
            })
            return Disposables.create()
        }.asSingle()
    }
}
