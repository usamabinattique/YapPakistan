//
//  CreatePasscodeViewModel.swift
//  YAPKit
//
//  Created by Hussaan S on 29/07/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public class CreatePasscodeViewModel: PINViewModel {

    public override init(pinRange: ClosedRange<Int> = 4...6) {
        super.init(pinRange: pinRange)
        let locString = "screen_create_passcode_display_text_title".localized
        headingTextSubject.onNext(locString)
        termsAndConditionsSubject.onNext(createTermsAndConditions(text: "screen_create_passcode_display_text_terms_and_conditions".localized))
        actionTitleSubject.onNext( "screen_create_passcode_button_create_passcode".localized)
        hideNavigationBarSubject.onNext(false)
        actionSubject.withLatestFrom(pinSubject).unwrap().subscribe(onNext: {[unowned self] pin in
            do {
                try ValidationService.shared.validatePasscode(pin)
                self.resultSubject.onNext(pin)
                self.resultSubject.onCompleted()
            } catch {
                self.errorSubject.onNext(error.localizedDescription)
            }
        })
        .disposed(by: disposeBag)
    }
}
