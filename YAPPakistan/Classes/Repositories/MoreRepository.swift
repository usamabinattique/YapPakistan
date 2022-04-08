//
//  MoreRepository.swift
//  YAPPakistan
//
//  Created by Umair  on 04/04/2022.
//

import Foundation
import YAPComponents
import RxSwift

public protocol MoreRepositoryType {
    func getHelpLineNumber() -> Observable<Event<String?>>
//    func getFAQ() -> Observable<Event<String?>>
//    func getAchievements() -> Observable<Event<[AchievementResponse]>>
    func logout(deviceUUID: String) -> Observable<Event<[String: String]?>>
//    func getATMCDMLocations() -> Observable<Event<[ATMCDMMarker]>>
}

public class MoreRepository: MoreRepositoryType {
    
    private let messagesService: MessagesServiceType
    private let authenticationService: AuthenticationService
    
    init(messagesService: MessagesServiceType, authenticationService: AuthenticationService) {
        self.messagesService = messagesService
        self.authenticationService = authenticationService
    }
    
    public func getHelpLineNumber() -> Observable<Event<String?>> {
        return messagesService.getHelplineNumber().materialize()
    }
    
//    public func getFAQ() -> Observable<Event<String?>> {
//        return messagesService.getFAQ().materialize()
//    }
    
//    public func getAchievements() -> Observable<Event<[AchievementResponse]>> {
//        transactionService.fetchAchievemets().materialize()
//    }
    
    public func logout(deviceUUID: String) -> Observable<Event<[String: String]?>> {
        return authenticationService.logout(deviceUUID: deviceUUID).materialize()
    }
    
//    public func getATMCDMLocations() -> Observable<Event<[ATMCDMMarker]>> {
//        return cardsService.getATMsCDMs().materialize()
//    }
}

//public class MockMoreRepository: MoreRepositoryType {
//    public func getHelpLineNumber() -> Observable<Event<String?>> {
//        .empty()
//    }
//
//    public func getFAQ() -> Observable<Event<String?>> {
//        .empty()
//    }
//
////    public func getAchievements() -> Observable<Event<[AchievementResponse]>> {
////        Observable.create { [weak self] observer in
////            guard let `self` = self else { return Disposables.create() }
////            observer.onNext(self.achievements)
////            return Disposables.create()
////        }.materialize()
////    }
//
//    public func logout(deviceUUID: String) -> Observable<Event<[String : String]?>> {
//        .empty()
//    }
//
////    public func getATMCDMLocations() -> Observable<Event<[ATMCDMMarker]>> {
////        .empty()
////    }
//
//
//    // MARK: - Init
//    init(achievements: [AchievementResponse] = []) {
//        self.achievements = achievements
//    }
//
//    // MARK: - Properties
//    var achievements: [AchievementResponse]
//}

