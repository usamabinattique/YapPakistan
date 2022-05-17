//
//  PaymentCardInitiatoryStageViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 13/04/2022.
//

import Foundation
import RxSwift

public class PaymentCardInitiatoryStageViewModel {

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let stagesSubject = BehaviorSubject<[PaymentCardOnboardingStageModel]>(value: [])

    // MARK: - Inputs

    // MARK: - Outputs
    public var stages: Observable<[PaymentCardOnboardingStageModel]> { stagesSubject.share(replay: 1, scope: .whileConnected) }
    public var actionTap: Observable<PaymentCardOnboardingStage> { stages.flatMap { Observable.from($0) }.flatMap { $0.actionTap } }

    // MARK: - Init
    public init(paymentCard: PaymentCard, account: Account) {
        stagesSubject.onNext(makeStages(paymentCard: paymentCard, partnerBankStatus: account.parnterBankStatus ?? .signUpPending, partnerBankApprovalDate: account.partnerBankApprovalDate, documentSubmissionDate: account.documentSubmissionDate, accountStatus: account.accountStatus))
    }
    
    // in case debit card is nil
    public init( account: Account) {
        stagesSubject.onNext(makeStages(paymentCard: .mock, partnerBankStatus: account.parnterBankStatus ?? .signUpPending, partnerBankApprovalDate: account.partnerBankApprovalDate, documentSubmissionDate: account.documentSubmissionDate, accountStatus: account.accountStatus))
    }
}

fileprivate extension PaymentCardInitiatoryStageViewModel {
    func makeStages(paymentCard: PaymentCard, partnerBankStatus: PartnerBankStatus, partnerBankApprovalDate: Date?, documentSubmissionDate: String?, accountStatus: AccountStatus?) -> [PaymentCardOnboardingStageModel] {

      /*  var stages: [PaymentCardOnboardingStageModel] = [
            .init(paymentCard: paymentCard, stage: .shipping, partnerBankStatus: partnerBankStatus, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: accountStatus),
            .init(paymentCard: paymentCard, stage: .delivery, partnerBankStatus: partnerBankStatus, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: accountStatus)
        ]
        
        if partnerBankStatus == .additionalRequirementsRequired || partnerBankStatus == .additionalRequirementsPending || partnerBankStatus == .additionalRequirementsProvided || partnerBankStatus == .additionalRequirementsSubmitted || documentSubmissionDate != nil {
            stages.append(.init(paymentCard: paymentCard, stage: .additionalRequirement, partnerBankStatus: partnerBankStatus, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: accountStatus))
        }
        
        stages.append(contentsOf: [
            .init(paymentCard: paymentCard, stage: .setPIN, partnerBankStatus: partnerBankStatus, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: accountStatus),
            .init(paymentCard: paymentCard, stage: .topUp, partnerBankStatus: partnerBankStatus, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: accountStatus)
        ]) */
        
        
        var stages: [PaymentCardOnboardingStageModel] = []
        
        if accountStatus == .addressCaptured || accountStatus == .onboarded || accountStatus == .cardSchemeExternalCardPending || accountStatus == .cardSchemePending || partnerBankStatus == .signUpPending {
            
            if (paymentCard.active == false && paymentCard.cardScheme == "Mastercard" ) || (paymentCard.active == nil && paymentCard.cardScheme == nil && accountStatus == .cardSchemeExternalCardPending && partnerBankStatus != .signUpPending ) {
                //  stages.append(.init(paymentCard: paymentCard, stage: .topUp, partnerBankStatus: partnerBankStatus, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: accountStatus))
                let customData1 =  PaymentCardOnboardingStageModelCustomData(title: "view_payment_card_onboarding_stage_four_title".localized, subHeading: "view_payment_card_onboarding_stage_four_subheading".localized, actionTitle: "view_payment_card_onboarding_stage_four_action_title".localized, icon: UIImage.init(named: "icon_stage_top_up", in: .yapPakistan)?.asTemplate, showVerticleBreadcrum: true, completed: false, inProcess: false, isEnabled: true)
                
                stages.append(.init(paymentCard: paymentCard, stage: .topUp, partnerBankStatus: partnerBankStatus, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: accountStatus, customData: customData1))
                
//                stages.append(.init(paymentCard: paymentCard, stage: .applicationInProcess, partnerBankStatus: .additionalRequirementsPending, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: .addressCaptured))
                let customData2 =  PaymentCardOnboardingStageModelCustomData(title: "view_payment_card_onboarding_stage_account_verification_label_title".localized, subHeading: "view_payment_card_onboarding_stage_initial_in_process_subtitle".localized, actionTitle: nil, icon: UIImage.init(named: "timeline_account_verification", in: .yapPakistan), showVerticleBreadcrum: true, completed: false, inProcess: true, isEnabled: false)
                stages.append(.init(paymentCard: paymentCard, stage: .applicationInProcess, partnerBankStatus: .additionalRequirementsPending, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: .addressCaptured,customData: customData2))
               
                // for card is on the way/disabled
                let customData = PaymentCardOnboardingStageModelCustomData(title: "view_payment_card_onboarding_stage_card_on_the_way_title".localized, subHeading: "view_payment_card_onboarding_stage_card_on_the_way_subheading".localized, actionTitle: "view_payment_card_onboarding_stage_card_on_the_way_action_title".localized, icon: UIImage.init(named: "icon_stage_shipping_in_progress", in: .yapPakistan), showVerticleBreadcrum: true, completed: false, inProcess: false, isEnabled: false)
                let stageVM: PaymentCardOnboardingStageModel = .init(paymentCard: paymentCard, stage: .shipping, partnerBankStatus: .physicalCardPending, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: .addressCaptured,customData: customData)
                
                stages.append(stageVM)
                
            } else {
                stages.append(.init(paymentCard: paymentCard, stage: .additionalRequirement, partnerBankStatus: .additionalRequirementsPending, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: .addressCaptured))
            }
            
           
            if partnerBankStatus == .physicalCardSuccess && paymentCard.deliveryStatus == .shipped , let pinSet = paymentCard.pinSet, pinSet == false  {
                // so it won't append in list
                stages.append(.init(paymentCard: paymentCard, stage: .shipping, partnerBankStatus: partnerBankStatus, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: .addressCaptured))
            } else if accountStatus == .onboarded || accountStatus == .cardSchemeExternalCardPending || accountStatus == .cardSchemePending || accountStatus == .secretQuestionPending {
                
                if (paymentCard.active == nil && paymentCard.cardScheme == nil && accountStatus == .cardSchemeExternalCardPending && partnerBankStatus != .signUpPending) {
                    
                } else {
                    stages.append(.init(paymentCard: paymentCard, stage: .shipping, partnerBankStatus: partnerBankStatus, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: .addressCaptured))
                }
                
                
            }
            
            
            stages.append(.init(paymentCard: paymentCard, stage: .setPIN, partnerBankStatus: partnerBankStatus, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: .addressCaptured))
        } else if partnerBankStatus == .ibanAssigned {
            stages.append(.init(paymentCard: paymentCard, stage: .applicationInProcess, partnerBankStatus: .ibanAssigned, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: .addressCaptured))
            
            stages.append(.init(paymentCard: paymentCard, stage: .shipping, partnerBankStatus: partnerBankStatus, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: .addressCaptured))
            
            stages.append(.init(paymentCard: paymentCard, stage: .setPIN, partnerBankStatus: partnerBankStatus, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: .addressCaptured))
        } else if partnerBankStatus == .physicalCardSuccess {
            if paymentCard.deliveryStatus == .shipped && (paymentCard.pinSet ?? false) == false {
                stages.append(.init(paymentCard: paymentCard, stage: .setPIN, partnerBankStatus: .physicalCardSuccess, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: .addressCaptured))
            }
        }
        else {
        }
        
        return stages
        
      /*  var stages: [PaymentCardOnboardingStageModel] = [
            .init(paymentCard: paymentCard, stage: .shipping, partnerBankStatus: partnerBankStatus, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: accountStatus),
            .init(paymentCard: paymentCard, stage: .delivery, partnerBankStatus: partnerBankStatus, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: accountStatus)
        ]
        
        if partnerBankStatus == .additionalRequirementsRequired || partnerBankStatus == .additionalRequirementsPending || partnerBankStatus == .additionalRequirementsProvided || partnerBankStatus == .additionalRequirementsSubmitted || documentSubmissionDate != nil {
            stages.append(.init(paymentCard: paymentCard, stage: .additionalRequirement, partnerBankStatus: partnerBankStatus, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: accountStatus))
        }
        
        stages.append(contentsOf: [
            .init(paymentCard: paymentCard, stage: .setPIN, partnerBankStatus: partnerBankStatus, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: accountStatus),
            .init(paymentCard: paymentCard, stage: .topUp, partnerBankStatus: partnerBankStatus, partnerBankApprovalDate: partnerBankApprovalDate, documentSubmissionDate: documentSubmissionDate, accountStatus: accountStatus)
        ])
        return stages */
    }
}
