//
//  LocationModel.swift
//  OARApp
//
//  Created by Sarmad Abbas on 24/06/2020.
//  Copyright © 2019 Sarmad Abbas. All rights reserved.
//

import Foundation
import CoreLocation

public struct LocationModel {
    var latitude: Double = 0
    var longitude: Double = 0
    var placeId = ""
    var country: String = ""
    var state: String = ""
    var city: String = ""
// <<<<<<< Updated upstream
    var address: [String] = []
    var formattAdaddress: String { return address.joined(separator: ", ") }
// =======
//   var formattAdaddress: String = ""
// >>>>>>> Stashed changes

    var distanceMeters: Double = 0 // From current location

    var coordinates: CLLocationCoordinate2D {
        set { (self.latitude, self.longitude) = (newValue.latitude, newValue.longitude) }
        get { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
    }

    init() { }

    init(latitude: Double,
         longitude: Double,
         placeId: String? = nil,
         country: String? = nil,
         state: String? = nil,
         city: String? = nil,
//<<<<<<< Updated upstream
         address: [String] = []) {
// =======
//         formattAdaddress: String? = nil) {
// >>>>>>> Stashed changes

        self.latitude = latitude
        self.longitude = longitude

        if let placeId = placeId { self.placeId = placeId }
        if let country = country { self.country = country }
        if let state = state { self.state = state }
        if let city = city { self.city = city }
// <<<<<<< Updated upstream
        self.address = address
// =======
//        if let formattAdaddress = formattAdaddress { self.formattAdaddress = formattAdaddress }
// >>>>>>> Stashed changes
    }

    init(coordinates: CLLocationCoordinate2D,
         placeId: String? = nil,
         country: String? = nil,
         state: String? = nil,
         city: String? = nil,
// <<<<<<< Updated upstream
         address: [String] = []) {
// =======
//        formattAdaddress: String? = nil) {
// >>>>>>> Stashed changes

        self.latitude = coordinates.latitude
        self.longitude = coordinates.longitude

        if let placeId = placeId { self.placeId = placeId }
        if let country = country { self.country = country }
        if let state = state { self.state = state }
        if let city = city { self.city = city }
// <<<<<<< Updated upstream
        self.address = address
    }

    init(prediction: NSDictionary) {
        self.address = []
        self.address.append(prediction["description"] as? String ?? "")
// =======
//        if let formattAdaddress = formattAdaddress { self.formattAdaddress = formattAdaddress }
//    }
//
//    init(prediction: NSDictionary) {
//        formattAdaddress = prediction["description"] as? String ?? ""
// >>>>>>> Stashed changes
        country = (prediction["terms"] as? [NSDictionary])?.last?["value"] as? String ?? ""
        if country == "" {
            country = formattAdaddress.components(separatedBy: ",").last?.trimmed ?? ""
        }
        placeId = prediction["place_id"] as? String ?? ""
        distanceMeters = (prediction["distance_meters"] as? NSString)?.doubleValue ?? 0
    }
}

// class CountryModel {
//    var id = 0
//    var name = ""
//
//    init() {}
//
//    init(data: NSDictionary) {
//        self.id = (data["Id"] as? NSString)?.integerValue ?? 0
//        self.name = (data["Name"] as? String) ?? ""
//    }
//
// }
//
//
// class CityModel {
//    var id = 0
//    var name = ""
//
//    init() {}
//
//    init(data: NSDictionary) {
//        self.id = (data["Id"] as? NSString)?.integerValue ?? 0
//        self.name = (data["Name"] as? String) ?? ""
//    }
// }

// MARK: - Utility Methods
// extension LocationModel {
//    func getDetail(completion: @escaping () -> Void) {
//        LocationManager.shared.getPlaceDetail(placeId: placeId) { (location, status) in
//            self.latitude = location.latitude
//            self.longitude = location.longitude
//
//            completion()
//        }
//    }
// }
