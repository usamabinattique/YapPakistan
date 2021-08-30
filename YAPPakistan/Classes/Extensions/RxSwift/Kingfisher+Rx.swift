//
//  Kingfisher+Rx.swift
//  iOSApp
//
//  Created by Abbas on 06/06/2021.
//

import UIKit
import RxCocoa
import RxSwift
import SDWebImage

extension Reactive where Base: UIImageView {

    public var imageURL: Binder<URL?> {
        return self.imageURL(withPlaceholder: nil)
    }

    public func imageURL(
        withPlaceholder placeholderImage: UIImage?,
        options: SDWebImageOptions = []
    ) -> Binder<URL?> {
        return Binder(self.base, binding: { (imageView, url) in
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

/*
extension ImageCache: ReactiveCompatible {}

extension Reactive where Base: ImageCache {

    func retrieveCacheSize() -> Observable<Int> {
        return Single.create { single in
            self.base.calculateDiskStorageSize { (result) in
                do {
                    single(.success(Int(try result.get())))
                } catch {
                    single(.error(error))
                }
            }
            return Disposables.create { }
        }.asObservable()
    }

    public func clearCache() -> Observable<Void> {
        return Single.create { single in
            self.base.clearMemoryCache()
            self.base.clearDiskCache(completion: {
                single(.success(()))
            })
            return Disposables.create { }
        }.asObservable()
    }
}
*/
