//
//  OnboardingCongratulationWaitingUserViewController.swift
//  OnBoarding
//
//  Created by Janbaz Ali on 01/03/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import UIKit

class OnboardingCongratulationWaitingUserViewController: OnboardingCongratulationViewController {

    lazy var footnoteWairingUserTopConstraint: NSLayoutConstraint = {
        let constraint = footnoteLabel.topAnchor.constraint(equalTo: paymentCardImageView.bottomAnchor, constant: 50)
        constraint.isActive = true
        return constraint
    }()

    override func setup() {
        _ = rowHeight
        animateHeading()
        animateSubheading()
        animatePaymentCard()
        animateFootnote()
        animateCompleteVerificationButton()
    }

    override func addFootnoteTopConstraint() -> NSLayoutConstraint {
       return footnoteWairingUserTopConstraint
    }

    override func rowHeightDivisor() -> CGFloat {
        return 90
    }

    override func footNoteText() -> String {
        "screen_onboarding_congratulations_waiting_user_display_text_meeting_note".localized
    }

    override func actionButtonText() -> String {
        "screen_onboarding_congratulations_waiting_user_button_complete_verification".localized
    }

}
