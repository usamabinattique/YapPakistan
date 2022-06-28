//
//  MissingDocumentNameCellViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 09/06/2022.
//

import Foundation
import YAPComponents
import RxSwift

struct MissingDocumentData{
    var title: String
    var type: MissingDocumentType
    var isUploaded: Bool
}

protocol MissingDocumentNameCellViewModelInput {
    
}

protocol MissingDocumentNameCellViewModelOutput {
    var name: Observable<String> { get }
    var isUploaded: Observable<Bool> { get }
}

protocol MissingDocumentNameCellViewModelType {
    var inputs: MissingDocumentNameCellViewModelInput { get }
    var outputs: MissingDocumentNameCellViewModelOutput { get }
}

class MissingDocumentNameCellViewModel: MissingDocumentNameCellViewModelType, MissingDocumentNameCellViewModelInput, MissingDocumentNameCellViewModelOutput, ReusableTableViewCellViewModelType {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    var inputs: MissingDocumentNameCellViewModelInput { self }
    var outputs: MissingDocumentNameCellViewModelOutput { self }
    var reusableIdentifier: String { MissingDocumentNameCell.defaultIdentifier }
    
  //  private let bankImageSubject: BehaviorSubject<(String?, UIImage?)>
    
    private let nameSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let isUploadedSubject = ReplaySubject<Bool>.create(bufferSize: 1)
   
    // MARK: - Inputs
    
    // MARK: - Outputs
    var name: Observable<String> {  nameSubject.asObservable() }
    var isUploaded: Observable<Bool> { isUploadedSubject.asObservable() }
    
    let data: MissingDocumentData
    
    // MARK: - Init
    init(_ data: MissingDocumentData) {
        self.data = data
        nameSubject.onNext(data.title)
        isUploadedSubject.onNext(data.isUploaded)
    }
}

