//
//  InitialsImageView+Rx.swift
//  YAPPakistan
//
//  Created by Tayyab on 07/09/2021.
//

import Foundation
import RxSwift

extension Reactive where Base: InitialsImageView {
    var image: Binder<UIImage> {
        return Binder(self.base) { initialsImageView, image in
            initialsImageView.setImage(image)
        }
    }

    var photoURL: Binder<URL?> {
        return Binder(self.base) { initialsImageView, url in
            initialsImageView.setPhotoURL(url)
        }
    }

    var labelColor: Binder<UIColor?> {
        return Binder(self.base) { initialsImageView, color in
            initialsImageView.setLabelColor(color)
        }
    }

    var initials: Binder<String> {
        return Binder(self.base) { initialsImageView, initials in
            initialsImageView.setInitials(initials)
        }
    }
}
