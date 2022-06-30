//
//  AppRestrictionManager.swift
//  YAPPakistan
//
//  Created by Umair  on 22/06/2022.
//

import Foundation
import YAPCore

public enum UserAccessRestriction {
    case cnicExpired
    case cnicNotVerified
    case debitCardFreeze
    case accountDormant
    case kycPending
    case none
    
    private static var alertView: YAPAlertView?
}

public extension UserAccessRestriction {
    
    func showFeatureBlockAlert() {
        guard self != .none else { return }
        
        let mesasge = AppRestrictionManager.shared.getAccessDeniedMessageFor(restriction: self)
        YAPToast.show(mesasge)
    }
}

class AppRestrictionManager: NSObject {
    
    static let shared = AppRestrictionManager()
    
    var account: Account? {
        didSet {
            self.restrictions = getRestrictionList()
            setBlockFeatures()
        }
    }
    
    var blockFeatures = [PKCoordinatorFeature]()
    var restrictions = [UserAccessRestriction]()
    
    func setBlockFeatures() {
        for rest in restrictions {
            getRestrictedFeature(for: rest)
        }
    }
    
    func showFeatureBlockAlert(message: String) {
        YAPToast.show(message)
    }
    
    func getRestrictedFeature(for restriction: UserAccessRestriction){
        
        switch restriction {
        case .cnicExpired:
            blockFeatures.append(contentsOf: [
                .changeAddress,
                .cardStatements,
                .accountStatements,
                .orderCard,
                .reorderCard
            ])
        case .cnicNotVerified, .kycPending:
            blockFeatures.append(contentsOf: [
                .changeAddress,
                .changeMobileNo,
                .orderCard,
                .reorderCard,
                .cardStatements,
                .accountStatements,
                .changeCardPin,
                .qrCodeAddMoney,
                .qrCodeSendMoney,
                .accountLimits,
                .analytics,
                .transactionDetails
            ])
        case .debitCardFreeze:
            blockFeatures = []
        case .accountDormant:
            blockFeatures.append(contentsOf: [
                .changeAddress,
                .changeMobileNo,
                .cardStatements,
                .accountStatements,
                .orderCard,
                .reorderCard,
                .qrCodeSendMoney,
                .analytics,
                .transactionDetails
            ])
        case .none:
            blockFeatures.append(.none)
        }
    }
    
    func getAccessDeniedMessageFor(restriction: UserAccessRestriction) -> String {
        switch restriction {
        case .cnicExpired:
            return "common_display_text_cnic_expired".localized
        case .cnicNotVerified:
            return "common_display_text_cnic_not_verified".localized
        case .debitCardFreeze:
            return "common_display_text_cnic_card_freeze".localized
        case .accountDormant:
            return "common_display_text_account_dormant".localized
        case .kycPending:
            return "common_display_text_account_kyc_pending".localized
        case .none:
            return "common_display_text_account_none".localized
        }
    }
    
    func getRestrictionList() -> [UserAccessRestriction] {
        guard let account = self.account else { return [] }
            var restrictionsType = [UserAccessRestriction]()
        //restrictionsType.append(UserAccessRestriction.kycPending)
//            if (accountState.cnicExpired == true) {
//                restrictionsType.append(UserAccessRestriction.cnicExpired)
//            }
//
//            if (accountState.cnicVerified == false) {
//                restrictionsType.append(UserAccessRestriction.cnicNotVerified)
//            }
//            if (accountState.debitCardFreeze == false) {
//                restrictionsType.append(UserAccessRestriction.debitCardFreeze)
//            }
//
//            if (accountState.accountStatus == "DORMANT") {
//                restrictionsType.append(UserAccessRestriction.accountDormant)
//            }
//
//            if (isRegistrationPending()) {
//                restrictionsType.append(UserAccessRestriction.kycPending)
//            }

            return restrictionsType
        }
    
    private func isRegistrationPending() -> Bool {
        guard let account = self.account else { return false }
        if account.accountStatus == .onboarded {
            return true
        } else if account.accountStatus == .secretQuestionPending {
            return true
        } else if account.accountStatus == .selfiePending {
            return true
        } else if (account.accountStatus == .cardSchemePending || account.accountStatus == .cardNamePending || account.accountStatus == .addressPending || account.accountStatus == .cardSchemeExternalCardPending) {
            return true
        } else {
            return false
        }
    }
    
}
