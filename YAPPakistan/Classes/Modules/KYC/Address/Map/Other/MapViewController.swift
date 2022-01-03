//
//  MapViewController.swift
//  OARApp
//
//  Created by Abbas on 04/10/2020.
//  Copyright © 2020 Abbas. All rights reserved.
//

import GoogleMaps
import GooglePlaces
import YAPComponents

class MapViewController: UIViewController {
    let mapView = GMSFactory.makeMapView()
}

/*
class MapViewController: UIViewController {
    


    lazy var markerWhenAnimationg: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = true
        return image
    }()

    lazy var markerWhenStill = GMSMarker()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func initialSetup() {
        DispatchQueue.main.async { [unowned self] in
            self.initialSetup(self.view)
        }
    }

    func initialSetup(_ view:UIView) {
        view.addSubview(mapView)
        view.sendSubviewToBack(mapView)
        view.addSubview(markerWhenAnimationg)
        mapView.delegate = self
    }
}

// MARK:- Utility Methods
extension MapViewController {
    func addMarker(position:CLLocationCoordinate2D, title:String, icon:String) -> GMSMarker {
        let marker = GMSMarker()
        marker.position = position
        marker.title = title
        marker.icon = UIImage(named: icon)
        marker.map = mapView
        return marker
    }
    
    func addMarker(position:CLLocationCoordinate2D, title:String, iconURL:String) -> GMSMarker {
        let marker = GMSMarker()
        marker.position = position
        marker.title = title
        let markerImage: UIImageView = {
            let image = UIImageView() //.getImageView(imageURLString: iconURL, contentMode: .scaleAspectFill)
            // image.cornerRadius(50)
            // image.border(Theme.Colors.blueText, width: 2)
            return image
        }()
        marker.iconView = markerImage
        marker.map = mapView
        return marker
    }
    
}

// MARK: - Tap Handlers
extension MapViewController {
    
    @objc func btnCurrentLocationPressed(_ sender: Any) {
//        self.showProgress()
//        LocationManager.shared.getCurrentLocation { (status, location) in
//            self.dismissProgress()
//            if status.isSuccess, let location = location {
//                self.mapView.animate(toLocation: location.coordinate)
//                self.mapView.animate(toZoom: 18)
//                //let camera = GMSCameraPosition(target: location.coordinate, zoom: 18, bearing: 0, viewingAngle: 0)
//                //self.mapView.camera = camera
//                //self.mapView.animate(to: GMSCameraPosition(target: location.coordinate, zoom: 18, bearing: 0, viewingAngle: 0))
//            } else {
//                if status.isEqual(to: .locationDenied) { LocationManager.showLocationDeniedAlert(target: self) }
//                else { self.showToast(status.message, type: .error) }
//            }
//        }
    }
}

// MARK: - Utility Methdos
extension MapViewController {
    func setupUIElements() {
        // txtSearch.text = selectedLocation?.formattAdaddress
        // btnSelectLocation.isEnabled = selectedLocation != nil
        
        // if selectedLocation == nil || selectedLocation?.latitude == 0 || selectedLocation?.longitude == 0 {
//            LocationManager.shared.getCurrentLocation { [weak self] (status, location) in guard let self = self else { return }
//                if status.isSuccess, let location = location {
//                    self.mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
//                } else {
//                    if status.isEqual(to: .locationDenied) { LocationManager.showLocationDeniedAlert(target: self) }
//                    else { self.showToast(status.message, type: .error) }
//                }
//            }
        } else {
            let coordinate = CLLocationCoordinate2D(latitude: selectedLocation?.latitude ?? 0, longitude: selectedLocation?.longitude ?? 0)
            self.mapView.camera = GMSCameraPosition(target: coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            //self.mapView.animate(toLocation: coordinate)
            //self.mapView.animate(toZoom: 15)
        }
        
    }
    
    
    func setLocation(_ location: LocationModel, isSetManualy:Bool = true) {
        if isSetManualy { self.isSetManualy = true }
        view.endEditing(true)
        selectedLocation = location
        txtSearch.text = location.formattAdaddress
        if location.latitude == 0 && location.longitude == 0 {
            //viewActivityIndicator.isHidden = false
            
            //aivSearch.startAnimating()
//            location.getDetail {
//                let location = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
//                //self.mapView.animate(toLocation: location)
//                //self.mapView.animate(toZoom: 15)
//                //self.viewActivityIndicator.isHidden = true
//                //let zoom = self.mapView.camera.zoom
//                let camera = GMSCameraPosition(latitude: location.latitude, longitude: location.longitude, zoom: 15, bearing: 0, viewingAngle: 0)
//                self.mapView.camera = camera
//                //self.mapView.animate(to: camera)
//            }
        } else {
            //let location = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            //self.mapView.animate(toLocation: location)
            //self.mapView.animate(toZoom: 15)
            //let zoom = self.mapView.camera.zoom
            let camera = GMSCameraPosition(latitude: location.latitude, longitude: location.longitude, zoom: 15, bearing: 0, viewingAngle: 0)
            self.mapView.camera = camera
            //self.mapView.animate(to: camera)
            //self.mapView.animate(to: GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0))
        }
        
    }
    
    func angleFrom(_ coordinate: CLLocationCoordinate2D,
                   toCoordinate: CLLocationCoordinate2D) -> Double {
        
        let deltaLongitude: Double = toCoordinate.longitude - coordinate.longitude
        let deltaLatitude: Double = toCoordinate.latitude - coordinate.latitude
        let angle = (Double.pi * 0.5) - atan(deltaLatitude / deltaLongitude)
        
        if (deltaLongitude > 0) {
            return angle
        } else if (deltaLongitude < 0) {
            return angle + Double.pi
        } else if (deltaLatitude < 0) {
            return Double.pi
        } else {
            return 0.0
        }
    }
    
    func getHeadingForDirection(fromCoordinate fromLoc: CLLocationCoordinate2D, toCoordinate toLoc: CLLocationCoordinate2D) -> Float {
        
        let fLat: Float = Float((self.mapView.camera.target.latitude).degreesToRadians)
        let fLng: Float = Float((self.mapView.camera.target.longitude).degreesToRadians)
        let tLat: Float = Float((fromLoc.latitude).degreesToRadians)
        let tLng: Float = Float((fromLoc.longitude).degreesToRadians)
        let degree: Float = (atan2(sin(tLng - fLng) * cos(tLat), cos(fLat) * sin(tLat) - sin(fLat) * cos(tLat) * cos(tLng - fLng))).radiansToDegrees
        if degree >= 0 {
            return degree
        } else {
            return 360 + degree
        }
    }
}
extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
// MARK: - TextField Delegate
extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - MapView Delegate
extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//        self.processing += 1
//        //let p = mapView.projection.coordinate(for: mapView.center)
//        LocationManager.shared.reverseGeocodeCoordinate(position.target) { (location, errorMessage) in
//            //LocationManager.shared.getPlaceDetail(placeId: location?.placeId ?? "") { (location, status) in
//                self.selectedLocation = location
//            self.txtSearch.text = location?.formattAdaddress
//                self.locationDidUpdated()
//
//                //self.dismissProgress()
//                self.processing -= 1
//            //}
//        }
        
        selectedLocationMarker.position = position.target
        
        if markerImage.isHidden == false {
            selectedLocationMarker.map = mapView
            markerImage.isHidden = true
        }
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if markerImage.isHidden == false {
            selectedLocationMarker.map = nil
            markerImage.isHidden = false
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mapView.animate(toLocation: coordinate)
    }
}

extension MapViewController {
    
    fileprivate func addSelectedLocationMarker() {
        selectedLocationMarker.appearAnimation = .pop
        selectedLocationMarker.iconView = markerImage
        selectedLocationMarker.position = mapView.projection.coordinate(for: mapView.center)
        selectedLocationMarker.map = mapView
    }
    
    /* func updateReverseGeocodeCoordinate(showProcessing:Bool, completeion:@escaping ()->Void) {
        let p1 = mapView.projection.coordinate(for: mapView.center)
        let p2 = self.selectedLocation?.coordinates
        if showProcessing { self.showProgress() }
        if LocationMath.distance(p1:p1, p2: p2, unit: .metre) != 0 { //if distance is greator than 0 meters
            LocationManager.shared.reverseGeocodeCoordinate(p1) { (location, errorMessage) in
                self.selectedLocation = location
                self.txtSearch.text = location?.formattAdaddress
                
                completeion()
                self.dismissProgress()
            }
        } else {
            completeion()
            self.dismissProgress()
        }
    } */
    
//    func getSavedLocations(completion: @escaping (APIResponseStatus, [LocationModel]) -> Void) {
//        let endPoint = OarAPI.customorLocations(.fetch).endPoint
//        let parms = ["language":LanguageManager.shared.currentLanguage]
//        postRequestJSONAuth(endPoint, parms: parms) { (status, json) in
//            if status.isSuccess, let json = json {
//                let locations = json.arrayValue.map({LocationModel(json: $0)})
//                completion(status, locations)
//            } else {
//                completion(status, [])
//            }
//        }
//    }

}

*/
