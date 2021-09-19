//
//  Kingfisher+Rx.swift
//  iOSApp
//
//  Created by Abbas on 06/06/2021.
//

import RxCocoa
import RxSwift
import SDWebImage
import UIKit

extension Reactive where Base: UIImageView {
    public var imageURL: Binder<URL?> {
        return self.imageURL(withPlaceholder: nil)
    }

    public func imageURL(
        withPlaceholder placeholderImage: UIImage?,
        options: SDWebImageOptions = []
    ) -> Binder<URL?> {
        return Binder(self.base, binding: { imageView, url in
            imageView
                .sd_setImage(
                    with: url,
                    placeholderImage: placeholderImage,
                    options: options,
                    progress: nil,
                    completed: nil)
        })
    }
}
