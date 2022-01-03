//
//  ReorderCardViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 25/12/2021.
//

import Foundation
import RxSwift

protocol ReorderCardViewModelInput {
    var nextObserver: AnyObserver<Void> { get }
    var backObserver: AnyObserver<Void> { get }
    var editAddressObserver: AnyObserver<Void> { get }
    var reorderAddressObserver: AnyObserver<Address?> { get }
}

protocol ReorderCardViewModelOutput {
    typealias LanguageStrings = (title: String, typeYourName: String, next: String)
    var next: Observable<Void> { get }
    var back: Observable<Void> { get }
    var editAddress: Observable<Void> { get }
    var loading: Observable<Bool> { get }
    var error: Observable<String> { get }

    var cardFee: Observable<String> { get }
    var balance: Observable<String> { get }
    var addressTitle: Observable<String> { get }
    var addressDetail: Observable<String> { get }
    var languageStrings: Observable<LanguageStrings> { get }
}

protocol ReorderCardViewModelType {
    var inputs: ReorderCardViewModelInput { get }
    var outputs: ReorderCardViewModelOutput { get }
}

class ReorderCardViewModel: ReorderCardViewModelType,
                            ReorderCardViewModelInput,
                            ReorderCardViewModelOutput {
    
    var inputs: ReorderCardViewModelInput { return self }
    var outputs: ReorderCardViewModelOutput { return self }
    
    // MARK: Inputs
    var editAddressObserver: AnyObserver<Void> { editAddressSubject.asObserver() }
    var nextObserver: AnyObserver<Void> { nextSubject.asObserver() }
    var backObserver: AnyObserver<Void> { backSubject.asObserver() }
    var reorderAddressObserver: AnyObserver<Address?> { reorderAddressSubject.asObserver() }
    
    // MARK: Outputs
    var next: Observable<Void> { nextResultSubject.asObservable() }
    var back: Observable<Void> { backSubject.asObservable() }
    var editAddress: Observable<Void> { editAddressSubject.asObservable() }
    var loading: Observable<Bool> { loadingSubject.asObservable() }
    var error: Observable<String> { errorSubject.asObservable() }
    var cardFee: Observable<String> { cardFeeSubject.asObservable() }
    var balance: Observable<String> { balanceSubject.asObservable() }
    var addressTitle: Observable<String> { addressTitleSubject.asObservable() }
    var addressDetail: Observable<String> { addressDetailSubject.asObservable() }
    var languageStrings: Observable<LanguageStrings> { languageStringsSubject.asObservable() }
    
    // MARK: Subjects
    private var nextSubject = PublishSubject<Void>()
    private var backSubject = PublishSubject<Void>()
    private var editAddressSubject = PublishSubject<Void>()
    private var nextResultSubject = PublishSubject<Void>()
    private var loadingSubject = BehaviorSubject<Bool>(value: false)
    private var errorSubject = PublishSubject<String>()
    private var cardFeeSubject = BehaviorSubject<String>(value: "")
    private var balanceSubject = BehaviorSubject<String>(value: "")
    private var addressTitleSubject = BehaviorSubject<String>(value: "")
    private var addressDetailSubject = BehaviorSubject<String>(value: "")
    private var languageStringsSubject: BehaviorSubject<LanguageStrings>!
    var reorderAddressSubject = BehaviorSubject<Address?>(value: nil)
    
    // MARK: Properties
    let serialNumber: String
    let disposeBag = DisposeBag()
    let repository: CardsRepositoryType
    
    init(serialNumber: String, repository: CardsRepositoryType) {
        self.serialNumber = serialNumber
        self.repository = repository


        
        languageSetup()

        let reorderFee = repository.fetchReorderFee().share()
        let address = repository.getPhysicalCardAddress().share()
        address.elements().bind(to: reorderAddressSubject).disposed(by: disposeBag)

        self.loadingSubject.onNext(true)
        let requestedData = Observable
            .zip(reorderFee.elements().unwrap(), address.elements().unwrap())
            .do(onNext: { [weak self] _ in self?.loadingSubject.onNext(false) })
            .share()

        requestedData.map({ "PKR \(Double($0.0.totalFee ?? 0))" }).bind(to: cardFeeSubject)
            .disposed(by: disposeBag)
        requestedData.map({ _ in "PKR 0.0" }).bind(to: balanceSubject)
            .disposed(by: disposeBag)
        requestedData.map({ $1.address1 ?? "" }).bind(to: addressTitleSubject)
            .disposed(by: disposeBag)
        requestedData.map({ $1.address2 ?? "" }).bind(to: addressDetailSubject)
            .disposed(by: disposeBag)

        #warning("Address is not updated")
        let reorderRequest = nextSubject
            .withLatestFrom(reorderAddressSubject.unwrap()).withUnretained(self)
            .do(onNext: { `self`, _ in self.loadingSubject.onNext(true) })
            .flatMap({ `self`, address in
                self.repository.reorderDebitCard(
                    cardSerialNumber: self.serialNumber,
                    address: (address.address1 ?? "") + (address.address2 ?? ""),
                    city: address.city ?? "",
                    country: address.country ?? "",
                    postCode: address.postalCode ?? "",
                    latitude: "\(address.latitude ?? 0)",
                    longitude: "\(address.longitude ?? 0)")
            })
            .do(onNext: { [weak self] _ in self?.loadingSubject.onNext(false) })
            .share()

        reorderRequest.elements()
            .map{ _ in () }
            .bind(to: nextResultSubject)
            .disposed(by: disposeBag)

        reorderFee.errors()
            .merge(with: address.errors())
            .merge(with: reorderRequest.errors())
            .map({ $0.localizedDescription })
            .bind(to: errorSubject)
            .disposed(by: disposeBag)
    }
}

fileprivate extension  ReorderCardViewModel {
    
    func languageSetup() {
        let strings = LanguageStrings(title: "Name your card",
                                      typeYourName: "Name your prime card",
                                      next: "Confirm")
        languageStringsSubject = BehaviorSubject<LanguageStrings>(value: strings)
    }
}
