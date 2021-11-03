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

    init(accountProvider: AccountProvider,
         kycRepository: KYCRepository,
         strings: KYCStrings) {

        self.kycRepository = kycRepository

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { YAPProgressHud.showProgressHud() }
        let requestCities = self.kycRepository.getCityOfBirthNames().share()
        let cellViewModel = requestCities.elements()
            .map({ $0.map({ KYCQuestionCellViewModel(value: $0) }) })
            .do(onNext: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { YAPProgressHud.hideProgressHud() }
            })

        super.init(accountProvider: accountProvider, cellViewModel: cellViewModel, strings: strings)

        let verifyResult = nextSubject
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(true) })
            .flatMap { self.kycRepository.verifySecretQuestions(motherMaidenName: "Nasreen", cityOfBirth: "Karachi") }
            .share()

        let refreshAccountRequest = verifyResult.elements()
            .flatMap { [unowned self] _ in self.accountProvider.refreshAccount() }
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
            .share()

        refreshAccountRequest
            .bind(to: successSubject)
            .disposed(by: disposeBag)

        verifyResult.errors()
            .do(onNext: { [weak self] _ in self?.loaderSubject.onNext(false) })
            .map { $0.localizedDescription }
            .bind(to: showErrorSubject)
            .disposed(by: disposeBag)
    }
}
