//
//  ImageView+Extension.swift
//  Alamofire
//
//  Created by Sarmad on 31/08/2021.
//

import UIKit

extension UIImageView {
    @discardableResult func setImageInBundle(named: String) -> Self {
        image = UIImage(named: named, in: Bundle.yapPakistan)
        return self
    }
}

class BundleYapPak {
    static func image(_ name: String) -> UIImage? {
        return UIImage(named: name, in: Bundle.yapPakistan)
    }
}

extension UIImageView {
    @discardableResult func setImage(named: String, in bundle: Bundle) -> Self {
        image = UIImage(named: named, in: bundle)
        return self
    }
}

public extension UIImage {
    convenience init?(named: String, in bundle: Bundle?) {
        self.init(named: named, in: bundle, compatibleWith: nil)
    }
}
