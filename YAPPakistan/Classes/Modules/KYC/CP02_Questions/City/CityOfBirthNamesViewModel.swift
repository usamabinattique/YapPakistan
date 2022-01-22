//
//  CitiesNamesViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 07/10/2021.
//

import Foundation
import RxSwift
import YAPComponents

class CityOfBirthNamesViewModel: KYCQuestionViewModel {
    private let kycRepository: KYCRepository!
    var motherName: String = ""

    init(accountProvider: AccountProvider,
         kycRepository: KYCRepository,
         strings: KYCStrings,
         motherName: String) {

        self.kycRepository = kycRepository
        self.motherName = motherName

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { YAPProgressHud.showProgressHud() }
        let requestCities = self.kycRepository.getCityOfBirthNames().share()
        let cellViewModel = requestCities.elements()
            .map({ $0.map({ KYCQuestionCellViewModel(value: $0) }) })
            .do(onNext: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { YAPProgressHud.hideProgressHud() }
            })

        super.init(accountProvider: accountProvider, cellViewModel: cellViewModel, strings: strings)

        let verifyResult = nextSubject
            .withLatestFrom(selectedItemSubject)
            .flatMap({ $0.value })
            .withUnretained(self)
            .do(onNext: { `self`, _ in self.loaderSubject.onNext(true) })
            .flatMapLatest { `self`, city in
                self.kycRepository.verifySecretQuestions(motherMaidenName: self.motherName, cityOfBirth: city)
            }.share()

        let refreshAccountRequest = verifyResult.elements()
            .flatMap { [unowned self] _ in self.accountProvider.refreshAccount() }
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
            .share()

        refreshAccountRequest
            .withLatestFrom(selectedItemSubject)
            .flatMap({ $0.value })
            .bind(to: successSubject)
            .disposed(by: disposeBag)

        requestCities.errors().map({ $0.localizedDescription })
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .bind(to: showErrorSubject)
            .disposed(by: disposeBag)

        verifyResult.errors()
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
            .map { $0.localizedDescription }
            .bind(to: showErrorSubject)
            .disposed(by: disposeBag)
    }
}