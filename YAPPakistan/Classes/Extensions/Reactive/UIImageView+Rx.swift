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

public typealias ImageLoadingCompletion = (UIImage?, Error?, URL?) -> Void

public extension UIImageView {
    func loadImage(with urlString: String?, placeholder: UIImage? = nil, showsIndicator: Bool = false, refreshCachedImage: Bool = false) {
        loadImage(with: URL(addingPercentEncodingInString: urlString ?? ""), placeholder: placeholder, showsIndicator: showsIndicator, refreshCachedImage: refreshCachedImage)
    }

    func loadImage(with urlString: String?, placeholder: UIImage? = nil, showsIndicator: Bool = false, refreshCachedImage: Bool = false, completion: @escaping ImageLoadingCompletion) {
        loadImage(with: URL(addingPercentEncodingInString: urlString ?? ""), placeholder: placeholder, showsIndicator: showsIndicator, refreshCachedImage: refreshCachedImage, completion: completion)
    }

    func loadImage(with url: URL?, placeholder: UIImage? = nil, showsIndicator: Bool = false, loop: Int = 1, refreshCachedImage: Bool = false) {

//        if let url = url, url.absoluteString.hasSuffix("gif") {
//            setGifFromURL(url, loopCount: loop)
//            loopCount = loop
//        } else {
            sd_imageIndicator = showsIndicator ? SDWebImageActivityIndicator.gray : nil

            if refreshCachedImage {
                /// sdwebimage option .refreshCached was creating issues that's why first removed cached image and then loaded again.
                SDImageCache.shared.removeImage(forKey: url?.absoluteString)
                sd_setImage(with: url, placeholderImage: placeholder)
//                sd_setImage(with: url, placeholderImage: placeholder, options: .refreshCached)
            }else {
                sd_setImage(with: url, placeholderImage: placeholder)
            }

//        }
    }

    func loadImage(with url: URL?, placeholder: UIImage? = nil, showsIndicator: Bool = false, refreshCachedImage: Bool = false, completion: @escaping ImageLoadingCompletion) {

//        if let url = url, url.absoluteString.hasSuffix("gif") {
//            setGifFromURL(url, loopCount: 1)
//            loopCount = 1
//        } else {
            sd_imageIndicator = showsIndicator ? SDWebImageActivityIndicator.gray : nil
            if refreshCachedImage {
                /// sdwebimage option .refreshCached was creating issues that's why first removed cached image and then loaded again.
                SDImageCache.shared.removeImage(forKey: url?.absoluteString)
                sd_setImage(with: url, placeholderImage: placeholder) { (image, error, _, url) in
                    completion(image ?? placeholder, error, url)
                }
            } else {
                sd_setImage(with: url, placeholderImage: placeholder) { (image, error, _, url) in
                    completion(image ?? placeholder, error, url)
                }
            }
//        }
    }
}

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

public extension Reactive where Base: UIImageView {
    func loadImage(_ placeHolder: UIImage? = nil, _ showsIndicator: Bool = false, refreshCachedImage: Bool = false) -> Binder<String> {
        return Binder(self.base) { imageView, url -> Void in
            imageView.loadImage(with: URL(addingPercentEncodingInString: url), placeholder: placeHolder, showsIndicator: showsIndicator, refreshCachedImage: refreshCachedImage)
        }
    }

    func loadImage(_ placeHolder: UIImage? = nil, _ showsIndicator: Bool = false, refreshCachedImage: Bool = false) -> Binder<URL?> {
        return Binder(self.base) { imageView, url -> Void in
            imageView.loadImage(with: url, placeholder: placeHolder, showsIndicator: showsIndicator, refreshCachedImage: refreshCachedImage)
        }
    }

    func loadImage(_ showsIndicator: Bool = false, refreshCachedImage: Bool = false) -> Binder<(URL?, UIImage?)> {
        return Binder(self.base) { imageView, params -> Void in
            imageView.loadImage(with: params.0, placeholder: params.1, showsIndicator: showsIndicator, refreshCachedImage: refreshCachedImage)
        }
    }

    func loadImage(_ showsIndicator: Bool = false, loop: Int = 1, refreshCachedImage: Bool = false) -> Binder<ImageWithURL> {
        return Binder(self.base) { imageView, params -> Void in
            imageView.loadImage(with: URL(addingPercentEncodingInString: params.0 ?? ""), placeholder: params.1, showsIndicator: showsIndicator, loop: loop, refreshCachedImage: refreshCachedImage)
        }
    }

    func loadImage(_ showsIndicator: Bool = false, refreshCachedImage: Bool = false, completion: @escaping ImageLoadingCompletion) -> Binder<ImageWithURL> {
        return Binder(self.base) { imageView, params -> Void in
            imageView.loadImage(with: URL(addingPercentEncodingInString: params.0 ?? ""), placeholder: params.1, showsIndicator: showsIndicator, refreshCachedImage: refreshCachedImage, completion: completion)
        }
    }
}
