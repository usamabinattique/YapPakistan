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

                    var address: [String] = []
                    if lines.count > 1 {
                        address.append(lines.first ?? "")
                        if lines.count > 1 { address.append(lines[1]) }
                    } else {
                        var addressSplitted = lines[0].split(separator: ",").map { String($0) }

                        address.append(addressSplitted.first ?? "")
                        addressSplitted.removeFirst()

                        if address[0].count < 12, let apart2 = addressSplitted.first {
                            address[0] += (", " + apart2.trimmed)
                            addressSplitted.removeFirst()
                        }

                        address.append((addressSplitted.joined(separator: ", ")).trimmed)
                    }

                    if let country = result.country?.trimmed, !address.joined(separator: ",").lowercased().contains(country.lowercased()) {
                        address[address.count - 1] += ", \(country)"
                    }

                    observable.onNext(LocationModel(coordinates: coordinates,
                                                    country: result.country,
                                                    state: result.administrativeArea,
                                                    city: result.locality,
                                                    address: address))
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
