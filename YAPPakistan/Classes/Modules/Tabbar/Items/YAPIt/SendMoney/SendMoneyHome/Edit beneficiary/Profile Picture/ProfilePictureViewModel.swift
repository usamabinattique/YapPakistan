//
//  ProfilePictureViewModel.swift
//  YAPPakistan
//
//  Created by Muhammad Sohaib on 22/03/2022.
//

import Foundation
import RxSwift
import RxDataSources
import YAPCore
import YAPComponents
import UIKit

protocol ProfilePictureViewModelInput {
    var backObserver: AnyObserver<Void> { get }
    var usePhotoObserver: AnyObserver<Void> { get }
    var retakeObserver: AnyObserver<PictureReviewResult> { get }
}

protocol ProfilePictureViewModelOutput {
    var back: Observable<Void> { get }
    var error: Observable<String> { get }
    var image: Observable<UIImage> { get }
    var result: Observable<PictureReviewResult> { get }
}

protocol ProfilePictureViewModelType {
    var inputs: ProfilePictureViewModelInput { get }
    var outputs: ProfilePictureViewModelOutput { get }
}

class ProfilePictureViewModel: ProfilePictureViewModelType, ProfilePictureViewModelInput, ProfilePictureViewModelOutput {
        
    // MARK: Properties
    let disposeBag = DisposeBag()
    var inputs: ProfilePictureViewModelInput { self }
    var outputs: ProfilePictureViewModelOutput { self }
    
    var repository : YapItRepository!
    var beneficiary: SendMoneyBeneficiary!
    
    private let backSubject = PublishSubject<Void>()
    private let imageSubject: BehaviorSubject<UIImage>
    private let errorSubject = PublishSubject<String>()
    private let uploadPictureSubject = PublishSubject<Void>()
    private let resultSubject = PublishSubject<PictureReviewResult>()
    
    // MARK: inputs
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    var retakeObserver: AnyObserver<PictureReviewResult> { resultSubject.asObserver() }
    var usePhotoObserver: AnyObserver<Void> { uploadPictureSubject.asObserver() }
    
    // MARK: inputs
    var back: Observable<Void> { backSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var image: Observable<UIImage> { imageSubject.asObservable() }
    var result: Observable<PictureReviewResult> { resultSubject.asObservable() }
    
    // MARK: Init
    init(beneficiary: SendMoneyBeneficiary, repository: YapItRepository, image: UIImage) {
        self.beneficiary = beneficiary
        self.repository = repository
        imageSubject = BehaviorSubject<UIImage>(value: image)
        uploadPicture(repository)
    }
}

// MARK: Update Beneficiary API
extension ProfilePictureViewModel {
    func uploadPicture(_ repository: YapItRepository) {

        let request = uploadPictureSubject.withLatestFrom(imageSubject)
            .do(onNext: { _ in YAPProgressHud.showProgressHud() })
                .flatMap { image in repository.editBeneficiary([(image.jpegData(compressionQuality: 0.5)!, "image/jpg")], id: String(self.beneficiary.id ?? 0), nickname: self.beneficiary.nickName) }
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .share()

        request.errors().map { $0.localizedDescription }.bind(to: errorSubject).disposed(by: disposeBag)

        request.elements().filter { $0.beneficiaryPictureUrl != nil }.map { beneficiary in PictureReviewResult.uploaded(beneficiary.beneficiaryPictureUrl!) }.bind(to: resultSubject).disposed(by: disposeBag)
    }
}
