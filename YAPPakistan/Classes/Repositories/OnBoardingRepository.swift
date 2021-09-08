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
        let invitees: [Invitee] = [
            Invitee(inviteeCustomerId: "1", inviteeCustomerName: "Logan Pearson"),
            Invitee(inviteeCustomerId: "2", inviteeCustomerName: "Virginia Alvarado"),
            Invitee(inviteeCustomerId: "3", inviteeCustomerName: "Bruce Guerrero"),
            Invitee(inviteeCustomerId: "4", inviteeCustomerName: "Emma Weber"),
            Invitee(inviteeCustomerId: "5", inviteeCustomerName: "Nada Hassan")
        ]

        let rank = WaitingListRank(jump: "100", waitingNewRank: 1000, waitingBehind: 20, completedKyc: false, viewable: true, gainPoints: nil, inviteeDetails: invitees, totalGainedPoints: 100, waiting: false)

        return Observable.of(rank).delay(.seconds(3), scheduler: MainScheduler.instance).materialize()

//        return customersService.fetchRanking().materialize()
    }
}
