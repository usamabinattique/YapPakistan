//
//  CreateNewPasscodeViewModel.swift
//  YAPPakistan
//
//  Created by Sarmad on 29/09/2021.
//

import Foundation

class CreateNewPasscodeViewModel: PasscodeViewModel {

    init(repository: LoginRepositoryType) {
        let pinRange: ClosedRange<Int> = 4...6
        let strings = PasscodeViewStrings(heading: "screen_create_passcode_display_text_title".localized,
                                          agrement: "screen_create_passcode_display_text_terms_and_conditions".localized,
                                          terms: "screen_create_passcode_display_button_terms_and_conditions".localized,
                                          action: "screen_create_passcode_button_create_new_passcode".localized)
        super.init(pinRange: pinRange, localizeableKeys: strings)

        actionSubject.withLatestFrom(pinTextSubject).unwrap()
            .flatMapLatest{ }
            .subscribe()
            .disposed(by: disposeBag)

        /* actionSubject.withLatestFrom(pinSubject).unwrap().subscribe(onNext: {[unowned self] pin in
            do {
                try ValidationService.shared.validatePasscode(pin)
                self.resultSubject.onNext(pin)
                self.resultSubject.onCompleted()
            } catch {
                self.errorSubject.onNext(error.localizedDescription)
            }
        })
        .disposed(by: disposeBag) */
    }
}
