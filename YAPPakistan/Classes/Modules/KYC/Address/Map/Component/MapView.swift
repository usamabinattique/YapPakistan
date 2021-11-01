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
        Observable.just(GMSCameraPosition(latitude: 0, longitude: 0, zoom: 15, bearing: 0, viewingAngle: 0))
            .bind(to: rx.cameraToAnimate)
            .disposed(by: rx.disposeBag)

        Observable.just(false)
            .bind(to: rx.translatesAutoresizingMaskIntoConstraints)
            .disposed(by: rx.disposeBag)
    }
}

final class GMSFactory {
    static func makeMapView() -> GMSMapView {
        return MapView()
    }

    static func makeGMSMarker(position: CLLocationCoordinate2D, title: String? = nil, iconURL: String? = nil) -> GMSMarker {
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


    static func makeGMSMarker(position: CLLocationCoordinate2D, title: String?, icon: String?) -> GMSMarker {
        let marker = GMSMarker()
        marker.position = position
        marker.title = title
        //marker.icon = UIImage(named: icon)
        return marker
    }
}
