//
//  CitiesNamesViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 07/10/2021.
//

import Foundation
import RxSwift
import YAPComponents

class CityOfBirthNamesViewModel:KYCQuestionViewModel {
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

        nextSubject
            .flatMap { self.kycRepository.verifySecretQuestions(motherMaidenName: "Rida", cityOfBirth: "Karachi") }
            .map({ _ in () })
            .bind(to: successSubject)
            .disposed(by: disposeBag)

    }
}
