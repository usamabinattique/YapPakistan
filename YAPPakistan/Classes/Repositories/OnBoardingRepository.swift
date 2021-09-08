//
//  OnBoardingRepository.swift
//  YAPPakistan
//
//  Created by Tayyab on 07/09/2021.
//

import Foundation
import RxSwift

class OnBoardingRepository {
    private let customersService: CustomersService

    init(customersService: CustomersService) {
        self.customersService = customersService
    }

    func getWaitingListRanking() -> Observable<Event<WaitingListRank?>> {
        let rank = WaitingListRank(jump: nil, waitingNewRank: 1000, waitingBehind: 20, completedKyc: false, viewable: true, gainPoints: nil, inviteeDetails: [Invitee(inviteeCustomerId: "1", inviteeCustomerName: "Tayyab Akram")], totalGainedPoints: nil, waiting: false)

        return Observable.of(rank).delay(.seconds(3), scheduler: MainScheduler.instance).materialize()

        // return customersService.fetchRanking().materialize()
    }
}
