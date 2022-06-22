//
//  PaymentCardOnboardingStageModel.swift
//  YAPPakistan
//
//  Created by Yasir on 13/04/2022.
//

import Foundation
import RxSwift


public enum PaymentCardOnboardingStage {
    case shipping
    case delivery
    case additionalRequirement
    case setPIN
    case topUp
    
    //new added
    case resumeKYC
    case applicationInProcess
    case noTransFound
}

struct PaymentCardOnboardingStageModelCustomData {
    internal init(title: String, subHeading: String?, actionTitle: String?, icon: UIImage?, showVerticleBreadcrum: Bool, completed: Bool, inProcess: Bool, isEnabled: Bool) {
        self.title = title
        self.subHeading = subHeading
        self.actionTitle = actionTitle
        self.icon = icon
        self.showVerticleBreadcrum = showVerticleBreadcrum
        self.completed = completed
        self.inProcess = inProcess
        self.isEnabled = isEnabled
    }
    
    let title: String
    let subHeading: String?
    let actionTitle: String?
    let icon: UIImage?
    let showVerticleBreadcrum: Bool
    let completed: Bool
    let inProcess: Bool
    let isEnabled: Bool
    
    
}

public struct PaymentCardOnboardingStageModel {
    
    let deliveryStatus: DeliveryStatus
    let deliveryDate: Date?
    let activationDate: Date?
    let partnerBankApprovalDate: Date?
    let isCardPinSet: Bool
    let stage: PaymentCardOnboardingStage
    let partnerBankStatus: PartnerBankStatus
    private let actionTapSubject = PublishSubject<Void>()
    let documentSubmissionDate: String?
    let accountStatus: AccountStatus?
    
    fileprivate let paymentCard: PaymentCard
    fileprivate var isCustom = false
    
    // MARK: - Init
    public init(paymentCard: PaymentCard,
                stage: PaymentCardOnboardingStage,
                partnerBankStatus: PartnerBankStatus,
                partnerBankApprovalDate: Date?,
                documentSubmissionDate: String?,
                accountStatus: AccountStatus?) {
        self.paymentCard = paymentCard
        self.deliveryStatus = paymentCard.deliveryStatus ?? .ordered
        self.deliveryDate = paymentCard.deliveryDate
        self.activationDate = paymentCard.setPinDate
        self.partnerBankApprovalDate = partnerBankApprovalDate
        self.stage = stage
        self.isCardPinSet = paymentCard.pinSet ?? false
        self.partnerBankStatus = partnerBankStatus
        self.documentSubmissionDate = documentSubmissionDate
        self.accountStatus = accountStatus
    }
    
    init(paymentCard: PaymentCard,
                stage: PaymentCardOnboardingStage,
                partnerBankStatus: PartnerBankStatus,
                partnerBankApprovalDate: Date?,
                documentSubmissionDate: String?,
         accountStatus: AccountStatus?, isCustom: Bool = true, customData: PaymentCardOnboardingStageModelCustomData) {
        self.paymentCard = paymentCard
        self.deliveryStatus = paymentCard.deliveryStatus ?? .ordered
        self.deliveryDate = paymentCard.deliveryDate
        self.activationDate = paymentCard.setPinDate
        self.partnerBankApprovalDate = partnerBankApprovalDate
        self.stage = stage
        self.isCardPinSet = paymentCard.pinSet ?? false
        self.partnerBankStatus = partnerBankStatus
        self.documentSubmissionDate = documentSubmissionDate
        self.accountStatus = accountStatus
        self.isCustom = isCustom
        self._title = customData.title
        self._subheading = customData.subHeading
        self._actionTitle = customData.actionTitle
        self._showVerticleBreadcrum = customData.showVerticleBreadcrum
        self._completed = customData.completed
        self._inProcess = customData.inProcess
        self._isEnabled = customData.isEnabled
        self._icon = customData.icon
    }
    
    var _title = ""
    
    var title: String {
        if !isCustom {
            switch stage {
            case .shipping:
                return "view_payment_card_onboarding_stage_card_on_the_way_title".localized
            case .delivery:
                return "view_payment_card_onboarding_stage_two_title".localized
            case .additionalRequirement:
                return "view_payment_card_onboarding_stage_additional_requirement_title".localized
            case .setPIN:
                return "view_payment_card_onboarding_stage_three_title".localized
            case .topUp:
                return "view_payment_card_onboarding_stage_four_title".localized
            case .applicationInProcess:
                return "view_payment_card_onboarding_stage_account_verification_label_title".localized
            default:
                return ""
            }
            
        }
        return _title
    }
    
    var _subheading: String?
    var subheading: String? {
        if !isCustom {
            switch (deliveryStatus, stage, isCardPinSet, partnerBankStatus) {
            case (.shipped, .shipping, _, _):
                return makeCardDeliveryDateSubheading()
            case (.shipped, .delivery, _, .activated),
                (.shipped, .delivery, _, .additionalRequirementsPending),
                (.shipped, .delivery, _, .additionalRequirementsRequired),
                (.shipped, .delivery, _, .additionalRequirementsProvided):
                return makePartnerBankApprovalDateSubheading()
            case (.shipped, .delivery, _, _):
                return "view_payment_card_onboarding_stage_two_active_subheading".localized
            case (_, .shipping, _, _):
                return "view_payment_card_onboarding_stage_card_on_the_way_subheading".localized
            case (_, .delivery, _, _):
                return "view_payment_card_onboarding_stage_two_initial_subtitle".localized
            case (_, .additionalRequirement, _, .additionalRequirementsPending),
                (_, .additionalRequirement, _, .additionalRequirementsRequired):
                return "view_payment_card_onboarding_stage_additional_requirement_subtitle".localized
            case (_, .additionalRequirement, _, .additionalRequirementsProvided),
                (_, .additionalRequirement, _, .additionalRequirementsSubmitted):
                let date = DateFormatter.transferDateFormatter.date(from: documentSubmissionDate ?? "") ?? Date()
                return String.init(format: "view_payment_card_onboarding_stage_additional_requirement_provided_subtitle".localized, DateFormatter.appReadableDateFormatter.string(from: date))
            case (_, .setPIN, false, _):
                return "view_payment_card_onboarding_stage_three_initial_subtitle".localized
            case (_, .setPIN, true, _):
                return makeCardSetPINDateSubheading()
            case (_, .topUp, _, _):
                return "view_payment_card_onboarding_stage_four_subheading".localized
            case (_, .applicationInProcess, _, _):
                return "view_payment_card_onboarding_stage_initial_in_process_subtitle".localized
            case (_, .noTransFound, _, _):
                return "view_payment_card_onboarding_stage_initial_in_no_trans_found_subtitle".localized
            default:
                return nil
            }
        }
        return _subheading
    }
    
    var _actionTitle: String?
    var actionTitle: String? {
        if !isCustom {
            switch (deliveryStatus, stage, isCardPinSet, partnerBankStatus) {
            case (.ordered, .shipping, _, _):
                return "view_payment_card_onboarding_stage_card_on_the_way_action_title".localized
            case (.shipped, .shipping, _, _):
                return "view_payment_card_onboarding_stage_card_on_the_way_action_title".localized
            case (.delivered, .shipping, _, _):
                return "view_payment_card_onboarding_stage_card_on_the_way_action_title".localized
            case (_, .additionalRequirement, _, .additionalRequirementsPending),
                (_, .additionalRequirement, _, .additionalRequirementsRequired):
                return "view_payment_card_onboarding_stage_additional_requirement_action_title".localized
            case (_, .setPIN, false, _):
                return "view_payment_card_onboarding_stage_three_action_title".localized
            case (_, .topUp, _, _):
                return "view_payment_card_onboarding_stage_four_action_title".localized
            default:
                return nil
            }
        }
        return _actionTitle
    }
    
    var _icon: UIImage?
    var icon: UIImage? {
        if !isCustom {
            switch (stage, completed) {
            case (_, true):
                return UIImage.init(named: "icon_stage_completed", in: .yapPakistan)
            case (.shipping, false):
                return UIImage.init(named: "icon_stage_shipping_in_progress", in: .yapPakistan)
            case (.delivery, false):
                return UIImage.init(named: "icon_stage_delivery_in_progress", in: .yapPakistan)
            case (.additionalRequirement, false):
                return UIImage.init(named: "icon_stage_additional_info", in: .yapPakistan)?.asTemplate
            case (.applicationInProcess, false):
                return UIImage.init(named: "icon_stage_additional_info", in: .yapPakistan)?.asTemplate
            case (.setPIN, false):
                return UIImage.init(named: "icon_stage_set_pin_in_progress_secondary", in: .yapPakistan)
            case (.topUp, _):
                return UIImage.init(named: "icon_stage_top_up", in: .yapPakistan)?.asTemplate
            default:
                return nil
            }
        }
        return _icon
    }
    
    var _showVerticleBreadcrum: Bool = false
    var showVerticleBreadcrum: Bool {
        if !isCustom {
            if stage == .topUp || stage == .noTransFound {
                return false
            }
            return true
        }
        return _showVerticleBreadcrum
    }
    
    var _completed = false
    var completed: Bool {
        if !isCustom {
            switch (deliveryStatus, stage, isCardPinSet, partnerBankStatus) {
            case (.shipped, .shipping, _, _):
                return true
            case (.shipped, .delivery, _, .initialVerificationSuccessful),
                (.shipped, .delivery, _, .activated),
                (.shipped, .delivery, _, .additionalRequirementsRequired),
                (.shipped, .delivery, _, .additionalRequirementsPending),
                (.shipped, .delivery, _, .additionalRequirementsProvided),
                (.shipped, .delivery, _, .additionalRequirementsSubmitted):
                return true
            case (.shipped, .additionalRequirement, _, .activated):
                return true
            case (.shipped, .setPIN, true, .activated):
                return true
            default:
                return false
            }
        }
        return _completed
    }
    
    var _inProcess = false
    var inProcess: Bool {
        if !isCustom {
            switch (deliveryStatus, stage, isCardPinSet, partnerBankStatus) {
            case (.shipped, .delivery, _, .activated),
                (.shipped, .delivery, _, .additionalRequirementsPending),
                (.shipped, .delivery, _, .additionalRequirementsRequired),
                (.shipped, .delivery, _, .additionalRequirementsProvided),
                (.shipped, .delivery, _, .additionalRequirementsSubmitted):
                return false
            case (.shipped, .delivery, _, _):
                return true
            case (.shipped, .additionalRequirement, _, .additionalRequirementsPending),
                (.shipped, .additionalRequirement, _, .additionalRequirementsRequired),
                (.shipped, .additionalRequirement, _, .additionalRequirementsProvided),
                (.shipped, .additionalRequirement, _, .additionalRequirementsSubmitted):
                return true
            case (_, .applicationInProcess, _, .ibanAssigned):
                return true
            default:
                return false
            }
        }
        return _inProcess
    }
    
    var _isEnabled = false
    var isEnabled: Bool {
        if !isCustom {
            switch (deliveryStatus, stage, isCardPinSet, partnerBankStatus, accountStatus) {
            case (_, .shipping, _, .signUpPending, .employmentInfoCompleted):
                return true
            case (_, .shipping, _, .signUpPending, _),
                (_, .shipping, _, _, .fatcaGenerated):
                return false
            //case (.booked, .shipping, _, _, _):
            case (.ordered, .shipping, _, _, _):
                return false
            case (_, .shipping, _, .physicalCardPending,_):
                return false
            case (_, .shipping, _, _, _):
                return true
            case (.shipped, .delivery, _, _, _):
                return true
            case (.shipped, .setPIN, _, .activated, _):
                return true
            case (.shipped, .topUp, _, .activated, _):
                return true
            case (.shipped, .topUp, false, .physicalCardSuccess, .addressCaptured):
                return true
            case (.shipped, .additionalRequirement, _, .additionalRequirementsRequired, _),
                (.shipped, .additionalRequirement, _, .additionalRequirementsProvided, _),
                (.shipped, .additionalRequirement, _, .additionalRequirementsSubmitted, _):
                return true
                
            case (_, .additionalRequirement, _, _, .addressCaptured):
                return true
            case (.shipped, .setPIN, !isCardPinSet, .physicalCardSuccess, _), (_, .setPIN, _, .physicalCardSuccess, .addressCaptured):
                return false
            case (.shipped, .setPIN, _, .physicalCardSuccess, _), (_, .setPIN, _, .physicalCardSuccess, _):
                return true
            default:
                return false
            }
        }
        return _isEnabled
    }
    
    var actionTapObserver: AnyObserver<Void> { actionTapSubject.asObserver() }
    var actionTap: Observable<PaymentCardOnboardingStage> { actionTapSubject.map { self.stage } }
}

extension PaymentCardOnboardingStageModel: Equatable {
    public static func == (lhs: PaymentCardOnboardingStageModel, rhs: PaymentCardOnboardingStageModel) -> Bool {
        lhs.deliveryStatus == rhs.deliveryStatus &&
            lhs.title == rhs.title &&
            lhs.subheading == rhs.subheading &&
            lhs.showVerticleBreadcrum == rhs.showVerticleBreadcrum &&
            lhs.stage == rhs.stage &&
            lhs.completed == rhs.completed
    }
}

fileprivate extension PaymentCardOnboardingStageModel {
    func makeCardDeliveryDateSubheading() -> String? {
        let formattedDate = deliveryDate.map { DateFormatter.appReadableDateFormatter.string(from: $0) }
        return formattedDate.map { date in
            let subheading = String(format: "view_payment_card_onboarding_stage_completed_subheading".localized, date)
            return subheading
        }
    }
    
    func makePartnerBankApprovalDateSubheading() -> String? {
        let formattedDate = partnerBankApprovalDate.map { DateFormatter.appReadableDateFormatter.string(from: $0) }
        return formattedDate.map { date in
            let subheading = String(format: "view_payment_card_onboarding_stage_two_completed_subheading".localized, date)
            return subheading
        }
    }
    
    func makeCardSetPINDateSubheading() -> String? {
        let formattedDate = activationDate.map { DateFormatter.appReadableDateFormatter.string(from: $0) }
        return formattedDate.map { date in
            let subheading = String(format: "view_payment_card_onboarding_stage_three_completed_subheading".localized, date)
            return subheading
        }
    }
}

fileprivate extension PaymentCardOnboardingStageModel {
    
//    func getCardOntheWayDisabledView() -> PaymentCardOnboardingStageModel {
//        self._title = "view_payment_card_onboarding_stage_card_on_the_way_action_title".localized
//
//    }
}
