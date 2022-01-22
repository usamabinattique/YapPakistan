//
//  MotherMaidenNamesViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 07/10/2021.
//

import Foundation
import RxSwift
import YAPComponents

class MotherMaidenNamesViewModel: KYCQuestionViewModel {

    private let kycRepository: KYCRepository!

    init(accountProvider: AccountProvider,
         kycRepository: KYCRepository,
         strings: KYCStrings) {

        self.kycRepository = kycRepository

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { YAPProgressHud.showProgressHud() }

        let requestMother = self.kycRepository.getMotherMaidenNames().share()

        let cellViewModel = requestMother.elements()
            .map({ $0.map({ KYCQuestionCellViewModel(value: $0) }) })
            .do(onNext: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { YAPProgressHud.hideProgressHud() }
            })

        super.init(accountProvider: accountProvider, cellViewModel: cellViewModel, strings: strings)

        requestMother.errors().map({ $0.localizedDescription })
            .do(onNext: { _ in YAPProgressHud.hideProgressHud() })
            .bind(to: showErrorSubject)
            .disposed(by: disposeBag)

        nextSubject
            .withLatestFrom(selectedItemSubject)
            .flatMap({ $0.value })
            .bind(to: successSubject).disposed(by: disposeBag)
        
    }
}