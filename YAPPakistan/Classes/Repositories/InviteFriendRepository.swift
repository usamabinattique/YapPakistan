//
//  InviteFriendRepository.swift
//  YAPPakistan
//
//  Created by Umair  on 10/01/2022.
//

import Foundation
import RxSwift
import RxCocoa

public protocol InviteFriendRepositoryType {
    func saveReferralInvite(customerId: String?) -> Observable<Event<String?>>
}

public class YAPInviteFriendRepository: InviteFriendRepositoryType {
    
    private let customersService: CustomersService
    private let accountProvider: AccountProvider
    private let disposeBag = DisposeBag()

    init(customersService: CustomersService, accountProvider: AccountProvider) {
        self.customersService = customersService
        self.accountProvider = accountProvider
    }
    
    public func saveReferralInvite(customerId: String?) -> Observable<Event<String?>> {
//        let customerId = self.accountProvider.currentAccount.unwrap()
//            .map({ return $0.customer.customerId })
//            .unwrap()
//            .subscribe(onNext: {
//                print()
//            })
//
        let timestamp = DateFormatter.referralsDateFormatter.string(from: Date())
        return customersService.saveReferralInvitation(inviterCustomerId: customerId ?? "", referralDate: timestamp).materialize()
    }
}
