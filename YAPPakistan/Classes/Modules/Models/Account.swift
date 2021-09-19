//
//  Account.swift
//  YAP
//
//  Created by MHS on 06/12/2018.
//  Copyright © 2018 YAP. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
public enum AccountError: Error {
    case notVerified
}

extension AccountError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notVerified:
            return  "asdf".localized
        }
    }
}

public struct ParentAccount: Codable {
    public let uuid: String
    public let _accountType: String
    public var accountType: AccountType { AccountType(rawValue: _accountType) ?? .b2cAccount }
    public let customer: Customer
    public let status: String
    public let active: Bool

    enum CodingKeys: String, CodingKey {
        case uuid, customer, status, active
        case _accountType = "accountType"
    }
}

public struct Account: Codable {

    public let uuid: String
    public let iban: String?
    public let accountNumber: String?
    public let accountType: AccountType
    public let defaultProfile: Bool
    public let companyName: String?
    public let packageName: String?
    public let status: String
    public let active: Bool
    public let documentsVerified: Bool
    public var companyType: String?
    public var soleProprietary: Bool
    public var accountStatus: AccountStatus? { AccountStatus(rawValue: _accountStatus ?? "") }
    private let _accountStatus: String?
    public let customer: Customer
    public let bank: Bank
    public var parnterBankStatus: PartnerBankStatus? { PartnerBankStatus(rawValue: _parnterBankStatus ?? "") }
    private let _parnterBankStatus: String?
    public let createdDate: String
    public let parentAccount: ParentAccount?
    public let otpBlocked: Bool?
    private let _eidExpiryStatus: String?
    public var eidExpiryStatus: EmiratesIdStatus { EmiratesIdStatus(rawValue: _eidExpiryStatus ?? "") ?? .updated }
    public let eidNotificationContent: String?
    private let _freezeCode: String?
    private let _freezeInitiator: String?
    private let _partnerBankApprovalDate: String?
    public var _isWaiting: Bool?

    public var freezeCode: AccountFreezeCode { AccountFreezeCode(rawValue: _freezeCode ?? "") ?? .none }
    public var freezeInitiator: AccountFreezeInitiator { AccountFreezeInitiator(rawValue: _freezeInitiator ?? "") ?? .none }
    public let qrCodeId: String?
    public let documentSubmissionDate: String?

    public var isWaiting: Bool {
        return _isWaiting ?? false
    }

    public var isUserVerfied: Bool {
        return accountStatus == .verificationSucceed || accountStatus == .cardActivated
    }

    public var securedIBAN: String? {
        return (accountStatus == .verificationSucceed || accountStatus == .cardActivated) ? iban : String(repeating: "*", count: iban?.count ?? 0)
    }

    public var securedBIC: String {
        return (accountStatus == .verificationSucceed || accountStatus == .cardActivated) ? bank.swiftCode : String(repeating: "*", count: bank.swiftCode.count)
    }

    public var creationDate: Date? { DateFormatter.transactionDateFormatter.date(from: createdDate) }

    private enum CodingKeys: String, CodingKey {
        case uuid, iban, accountType, defaultProfile, companyName, packageName, status, active, documentsVerified, companyType, soleProprietary, customer, bank, parentAccount, otpBlocked
        case _accountStatus = "notificationStatuses"
        case accountNumber = "accountNo"
        case _parnterBankStatus = "partnerBankStatus"
        case createdDate = "creationDate"
        case _eidExpiryStatus = "eidExpiryStatus"
        case eidNotificationContent = "eidNotificationContent"
        case _freezeCode = "freezeCode"
        case _freezeInitiator = "freezeInitiator"
        case qrCodeId = "encryptedAccountUUID"
        case _partnerBankApprovalDate = "partnerBankApprovalDate"
        case documentSubmissionDate = "additionalDocSubmitionDate"
        case _isWaiting = "isWaiting"
    }

    public var isOTPBlocked: Bool { otpBlocked ?? false }
}

// MARK: - Convenience Init
public extension Account {
    init(account: Account, updatedMobileNumber: String) {
        self.uuid = account.uuid
        self.iban = account.iban
        self.accountNumber = account.accountNumber
        self.accountType = account.accountType
        self.defaultProfile = account.defaultProfile
        self.companyName = account.companyName
        self.packageName = account.packageName
        self.status = account.status
        self.active = account.active
        self.documentsVerified = account.documentsVerified
        self.companyType = account.companyType
        self.soleProprietary = account.soleProprietary
        self._accountStatus = account._accountStatus
        self.bank = account.bank
        self.customer = Customer(customer: account.customer, updatedMobileNumber: updatedMobileNumber)
        self._parnterBankStatus = account._parnterBankStatus
        self.createdDate = account.createdDate
        self.parentAccount = account.parentAccount
        self.otpBlocked = account.otpBlocked
        self._eidExpiryStatus = account._eidExpiryStatus
        self.eidNotificationContent = account.eidNotificationContent
        self._freezeCode = account._freezeCode
        self._freezeInitiator = account._freezeInitiator
        self.qrCodeId = account.qrCodeId
        self._partnerBankApprovalDate = account._partnerBankApprovalDate
        self.documentSubmissionDate = account.documentSubmissionDate
    }

    init(account: Account, updatedEmail: String) {
        self.uuid = account.uuid
        self.iban = account.iban
        self.accountNumber = account.accountNumber
        self.accountType = account.accountType
        self.defaultProfile = account.defaultProfile
        self.companyName = account.companyName
        self.packageName = account.packageName
        self.status = account.status
        self.active = account.active
        self.documentsVerified = account.documentsVerified
        self.companyType = account.companyType
        self.soleProprietary = account.soleProprietary
        self._accountStatus = account._accountStatus
        self.bank = account.bank
        self.customer = Customer(customer: account.customer, updatedEmail: updatedEmail)
        self._parnterBankStatus = account._parnterBankStatus
        self.createdDate = account.createdDate
        self.parentAccount = account.parentAccount
        self.otpBlocked = account.otpBlocked
        self._eidExpiryStatus = account._eidExpiryStatus
        self.eidNotificationContent = account.eidNotificationContent
        self._freezeCode = account._freezeCode
        self._freezeInitiator = account._freezeInitiator
        self.qrCodeId = account.qrCodeId
        self._partnerBankApprovalDate = account._partnerBankApprovalDate
        self.documentSubmissionDate = account.documentSubmissionDate
    }

    init(account: Account, soleProprietary: Bool) {
        self.uuid = account.uuid
        self.iban = account.iban
        self.accountNumber = account.accountNumber
        self.accountType = account.accountType
        self.defaultProfile = account.defaultProfile
        self.companyName = account.companyName
        self.packageName = account.packageName
        self.status = account.status
        self.active = account.active
        self.documentsVerified = account.documentsVerified
        self.companyType = account.companyType
        self.soleProprietary = soleProprietary
        self._accountStatus = account._accountStatus
        self.bank = account.bank
        self.customer = account.customer
        self._parnterBankStatus = account._parnterBankStatus
        self.createdDate = account.createdDate
        self.parentAccount = account.parentAccount
        self.otpBlocked = account.otpBlocked
        self._eidExpiryStatus = account._eidExpiryStatus
        self.eidNotificationContent = account.eidNotificationContent
        self._freezeCode = account._freezeCode
        self._freezeInitiator = account._freezeInitiator
        self.qrCodeId = account.qrCodeId
        self._partnerBankApprovalDate = account._partnerBankApprovalDate
        self.documentSubmissionDate = account.documentSubmissionDate
    }

    init(account: Account, accountStatus: AccountStatus) {
        self.uuid = account.uuid
        self.iban = account.iban
        self.accountNumber = account.accountNumber
        self.accountType = account.accountType
        self.defaultProfile = account.defaultProfile
        self.companyName = account.companyName
        self.packageName = account.packageName
        self.status = account.status
        self.active = account.active
        self.documentsVerified = account.documentsVerified
        self.companyType = account.companyType
        self.soleProprietary = account.soleProprietary
        self._accountStatus = accountStatus.rawValue
        self.bank = account.bank
        self.customer = account.customer
        self._parnterBankStatus = account._parnterBankStatus
        self.createdDate = account.createdDate
        self.parentAccount = account.parentAccount
        self.otpBlocked = account.otpBlocked
        self._eidExpiryStatus = account._eidExpiryStatus
        self.eidNotificationContent = account.eidNotificationContent
        self._freezeCode = account._freezeCode
        self._freezeInitiator = account._freezeInitiator
        self.qrCodeId = account.qrCodeId
        self._partnerBankApprovalDate = account._partnerBankApprovalDate
        self.documentSubmissionDate = account.documentSubmissionDate
    }
}

// MARK: - Equatable
extension Account: Equatable {
    public static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}

public enum AccountStatus: String, Codable {
    case invitationPending = "INVITE_PENDING"
    case invitationDeclined = "INVITE_DECLINED"
    case parentMobileVerficationPending = "PARNET_MOBILE_VERIFICATION_PENDING"
    case pascodePending = "PASS_CODE_PENDING"
    case emailPending = "EMAIL_PENDING"
    case onboarded = "ON_BOARDED"
    case eidCaptured = "CAPTURED_EID"
    case eidFailed = "EID_FAILED"
    case addressCaptured = "CAPTURED_ADDRESS"
    case verificationPending = "MEETING_SCHEDULED"
    case birthInfoCollected = "BIRTH_INFO_COLLECTED"
    case employmentInfoCompleted = "EMP_INFO_COMPLETED"
    case fatcaGenerated = "FATCA_GENERATED"
    case softKYCCompleted = "SOFT_KYC_DONE"
    case softKYCFailed = "SOFT_KYC_FAILED"
    case hardKYCDone = "HARD_KYC_DONE"
    case physicalCardOrderd = "PHYSICAL_CARD_ORDERED"
    case verificationSucceed = "MEETING_SUCCESS"
    case verificationFailed = "MEETING_FAILED"
    case cardActivated = "CARD_ACTIVATED"
    case eidExpired = "EID_EXPIRED"
    case eidRescanRequired = "EID_RESCAN_REQ"
    case eidUpdated = "EID_UPDATED"
    case additionalRequirementsPending = "ADDITIONAL_COMPLIANCE_INFO_REQ"
    case additionalRequirementsRequired = "ADD_INFO_NOTIFICATION_DONE"
    case additionalRequirementsProvided = "ADDITIONAL_COMPLIANCE_INFO_PROVIDED"
    case additionalRequirementsSubmitted = "ADD_COMPLIANCE_INFO_SUBMITTED_BY_ADMIN"
}

public enum EmiratesIdStatus: String, Codable {
    case days30ToExpiry = "BEFORE_30_DAYS"
    case days7ToExpiry = "BEFORE_7_DAYS"
    case expired = "EID_EXPIRED"
    case gracePeriodOver = "GRACE_PERIOD_ENDED"
    case rescanRequired = "EID_RESCAN_REQ"
    case updated = "EID_UPDATED"
}

public enum AccountType: String, Codable {
    case b2bAccount = "B2B_ACCOUNT"
    case b2cAccount = "B2C_ACCOUNT"
    case b2bSubAccount = "B2B_SUB_ACCOUNT"
    case b2cSubAccount = "B2C_SUB_ACCOUNT"
    case household = "B2C_HOUSEHOLD"
    case partner = "PARTNER"
    case master = "MASTER"
    case admin = "ADMIN"
}

public enum PartnerBankStatus: String, Codable {
    case signUpPending = "SIGN_UP_PENDING"
    case documentUploaded = "DOCUMENT_UPLOADED"
    case physicalCardPending = "PHYSICAL_CARD_PENDING"
    case physicalCardSuccess = "PHYSICAL_CARD_SUCCESS"
    case hardKycPending = "HARD_KYC_PENDING"
    case hardKycCompleted = "HARD_KYC_DONE"
    case approved = "APPROVED"
    case rejected = "REJECTED"
    case activated = "ACTIVATED"
    case initialVerificationSuccessful = "INITIAL_VERIFICATION_SUCCESSFUL"
    case initialVerificationRejected = "REJECTED_AT_INITIAL_VERIFICATION"
    case processedSuccessfully = "PROCESSED_SUCCESSFULLY"
    case additionalRequirementsPending = "ADDITIONAL_COMPLIANCE_INFO_REQ"
    case additionalRequirementsRequired = "ADD_INFO_NOTIFICATION_DONE"
    case additionalRequirementsProvided = "ADDITIONAL_COMPLIANCE_INFO_PROVIDED"
    case additionalRequirementsSubmitted = "ADD_COMPLIANCE_INFO_SUBMITTED_BY_ADMIN"
}

public enum AccountFreezeCode: String, Codable {
    case totalBlock = "T"
    case debitBlock = "D"
    case crediBlock = "C"
    case hotlisted = "H"
    case expired = "E"
    case none
}

public enum AccountFreezeInitiator: String, Codable {
    case hotlistedByMobileApp = "MOBILE_APP_HOSTLIST"
    case hotlistedByCSR = "CUSTOMER_REQUEST"
    case blockedByBank = "BANK_REQUEST"
    case blockedByMasterCard = "MASTER_CARD_REQUEST"
    case blockedByYapComplianceTotal = "YAP_COMPLIANCE_TOTAL"
    case blockedByYapComplianceDebit = "YAP_COMPLIANCE_DEBIT"
    case blockedByYapComplianceCredit = "YAP_COMPLIANCE_CREDIT"
    case eidExpiredBySchedular = "EID_EXPIRED_SCHEDULER"
    case none
}

public extension Account {
    var formattedIBAN: String? {
        guard let `iban` = iban else { return nil }
        return format(iban: iban)
    }

    var maskedAndFormattedIBAN: String? {
        guard let `iban` = iban else { return nil }
        return format(iban: mask(iban: iban))
    }

    var maskedAccountNumber: String? {
        guard let `accountNumber` = accountNumber else { return nil }
        return accountNumber.dropLast(6) + "******"
    }
}

/*
extension Account: StatementFetchable {
    public var idForStatements: String? { uuid }
    public var statementType: StatementType { .account }
}

// MARK: Account restrictions

public extension Account {
    var restrictions: [UserAccessRestriction] {
        var restrictions = [UserAccessRestriction]()
        
        if parnterBankStatus != .activated {
            restrictions.append(.accountInactive)
        }
        
        switch (freezeInitiator, freezeCode) {
        case (.eidExpiredBySchedular, .expired):
            restrictions.append(.eidBlocked)
        default:
            break
        }
        
        switch (freezeInitiator, freezeCode) {
        case (.hotlistedByMobileApp, _):
            restrictions.append(.cardHotlistedByApp)
        case (.hotlistedByCSR, _):
            restrictions.append(.cardHotlistedByCSR)
        case (.blockedByBank, .totalBlock):
            restrictions.append(.ibanBlockedByRAKTotal)
        case (.blockedByBank, .debitBlock):
            restrictions.append(.ibanBlockedByRAKDebit)
        case (.blockedByBank, .crediBlock):
            restrictions.append(.ibanBlcokedByRAKCredit)
        case (.blockedByMasterCard, _):
            restrictions.append(.cardBlockedByMasterCard)
        case (.blockedByYapComplianceTotal, .totalBlock):
            restrictions.append(.cardBlockedByYAPTotal)
        case (.blockedByYapComplianceDebit, .debitBlock):
            restrictions.append(.cardBlockedByYAPDebit)
        case (.blockedByYapComplianceCredit, .crediBlock):
            restrictions.append(.cardBlockedByYAPCredit)
        default:
            break
        }
        
        if otpBlocked ?? false {
            restrictions.append(.otpBlocked)
        }
        
        var pinBlocked = false
        CardsManager.shared.cards.map{ $0.filter{ $0.cardType == .debit}.first }.unwrap().subscribe(onNext: { pinBlocked = $0.pinStatus == .blocked }).dispose()
        
        if pinBlocked {
            restrictions.append(.debitCardPinBlocked)
        }
        
        return restrictions
    }
    
    var blockedFeatures: [CoordinatorFeature] {
        restrictions.flatMap{ $0.blockedFeatures }
    }
}

public extension Account {
    static func makeAccount(with partnerBankStatus: PartnerBankStatus,
                            approvalDate: Date?,
                            accountStatus: String? = nil) -> Account {
        Account(uuid: "",
                iban: "",
                accountNumber: "",
                accountType: .b2cAccount,
                defaultProfile: true,
                companyName: nil,
                packageName: nil,
                status: "", active: true,
                documentsVerified: true,
                companyType: nil,
                soleProprietary: false,
                _accountStatus: accountStatus,
                customer: Customer(uuid: "",
                                   _email: "",
                                   countryCode: nil,
                                   mobileNo: "",
                                   firstName: "",
                                   lastName: "",
                                   companyName: nil,
                                   emailVerified: true,
                                   mobileNoVerified: true,
                                   status: "",
                                   dob: nil,
                                   passportNo: nil,
                                   nationality: nil,
                                   imageURL: nil,
                                   customerId: nil,
                                   homeCountry: nil,
                                   founder: false, customerColor: nil),
                bank: Bank(id: 0, name: "", bankCode: "", swiftCode: "", address: ""),
                _parnterBankStatus: partnerBankStatus.rawValue,
                createdDate: "",
                parentAccount: nil,
                otpBlocked: nil,
                _eidExpiryStatus: nil,
                eidNotificationContent: nil,
                _freezeCode: nil,
                _freezeInitiator: nil,
                _partnerBankApprovalDate: approvalDate.map { DateFormatter.transactionDateFormatter.string(from: $0) },
                qrCodeId: nil,
                documentSubmissionDate: nil)
    }
}

*/
