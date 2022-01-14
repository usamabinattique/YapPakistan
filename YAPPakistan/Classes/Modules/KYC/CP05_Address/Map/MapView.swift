//
//  MapView.swift
//  YAPPakistan
//
//  Created by Sarmad on 27/10/2021.
//

import Foundation
import RxSwift
import RxCocoa
import GoogleMaps
import SDWebImage
import YAPComponents

private let locPak = CLLocationCoordinate2D(latitude: 31.48, longitude: 74.05)

class MapView: GMSMapView {

    convenience init() { self.init(frame: .zero) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.makeUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.makeUI()
    }

    func makeUI() {
        translatesAutoresizingMaskIntoConstraints = false
        camera = GMSCameraPosition(latitude: locPak.latitude,
                                   longitude: locPak.longitude,
                                   zoom: 6,
                                   bearing: 0,
                                   viewingAngle: 0)
    }
}

final class GMSFactory {
    static func makeMapView( markers: [GMSMarker] = [] ) -> GMSMapView {
        let mapView = MapView()
        for index in 0..<markers.count { markers[index].map = mapView }
        return mapView
    }

    static func makeMarker(position: CLLocationCoordinate2D = locPak,
                           title: String? = nil,
                           iconURL: String? = nil) -> GMSMarker {
        let marker = GMSMarker()
        marker.position = position
        marker.title = title
        if let urlString = iconURL, let url = URL(string: urlString) {
            let markerImage: UIImageView = UIImageView()
            markerImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
            markerImage.sd_setImage(with: url, completed: nil)
            marker.iconView = markerImage
        }
        return marker
    }

    static func makeMarker(position: CLLocationCoordinate2D = locPak,
                           title: String? = nil,
                           icon: String? = nil) -> GMSMarker {
        let marker = GMSMarker()
        marker.position = position
        marker.title = title
        if let icon = icon { marker.icon = UIImage(named: icon, in: .yapPakistan) }
        return marker
    }
}
