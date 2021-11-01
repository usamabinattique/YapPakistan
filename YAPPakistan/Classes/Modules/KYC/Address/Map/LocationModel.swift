//
//  LocationModel.swift
//  Carzly
//
//  Created by Zuhair Hussain on 24/06/2019.
//  Copyright © 2019 Zuhair Hussain. All rights reserved.
//

import Foundation
import CoreLocation

class LocationModel {
    var formattAdaddress = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var distanceMeters: Double = 0
    
    var country = ""
    var state = ""
    var city = ""
    
    var placeId = ""
    
    var coordinates:CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init() {}
    init(lat:Double, long:Double, address:String? = nil) {
        self.latitude = lat
        self.longitude = long
        if let address = address { self.formattAdaddress = address }
    }
    
    init(prediction: NSDictionary) {
        formattAdaddress = prediction["description"] as? String ?? ""
        country = (prediction["terms"] as? [NSDictionary])?.last?["value"] as? String ?? ""
        if country == "" {
            country = formattAdaddress.components(separatedBy: ",").last?.trimmed ?? ""
        }
        placeId = prediction["place_id"] as? String ?? ""
        distanceMeters = (prediction["distance_meters"] as? NSString)?.doubleValue ?? 0
    }
    
//    init(json:JSON) {
//        country = json["name"].stringValue //"Thokar Niaz Bag",
//        latitude = json["latitude"].doubleValue //"31.460768968415834",
//        longitude = json["longitude"].doubleValue //"74.25315354019403",
//        formattAdaddress = json["address"].stringValue //"3k Aitchison Society, Rasūlpur Aitchison Society, Lahore, Punjab, Pakistan"
//    }
    
}

class CountryModel {
    var id = 0
    var name = ""
    
    init() {}
    
    init(data: NSDictionary) {
        self.id = (data["Id"] as? NSString)?.integerValue ?? 0
        self.name = (data["Name"] as? String) ?? ""
    }
    
}


class CityModel {
    var id = 0
    var name = ""
    
    init() {}
    
    init(data: NSDictionary) {
        self.id = (data["Id"] as? NSString)?.integerValue ?? 0
        self.name = (data["Name"] as? String) ?? ""
    }
}


// MARK: - Utility Methods
//extension LocationModel {
//    func getDetail(completion: @escaping () -> Void) {
//        LocationManager.shared.getPlaceDetail(placeId: placeId) { (location, status) in
//            self.latitude = location.latitude
//            self.longitude = location.longitude
//
//            completion()
//        }
//    }
//}


