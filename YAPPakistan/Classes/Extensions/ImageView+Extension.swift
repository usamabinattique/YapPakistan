//
//  ImageView+Extension.swift
//  Alamofire
//
//  Created by Sarmad on 31/08/2021.
//

import UIKit


extension UIImageView {
    @discardableResult func setImageInBundle(named:String) -> Self {
        image = BundleYapPak.image(named)
        return self
    }
}

class BundleYapPak {
    /* static func image(_ name: String) -> UIImage? {
        let podBundle = Bundle(for: BundleYapPak.self)
        return UIImage(named: name, in: podBundle, compatibleWith: nil)
    } */
    
    static func image(_ name: String) -> UIImage? {
        let podBundle = Bundle(for: BundleYapPak.self) // for getting pod url
        if let url = podBundle.url(forResource: "YAPPakistan", withExtension: "bundle") { //<YourBundleName> must be the same as you wrote in .podspec
            let bundle = Bundle(url: url)
            return UIImage(named: name, in: bundle, compatibleWith: nil)
        }
        return UIImage()
    }
}
