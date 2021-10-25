//
//  LoginRepository.swift
//  YAPPakistan_Example
//
//  Created by Umer on 13/10/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import YAPPakistan
import RxSwift

public protocol LoginRepositoryType: AnyObject {
    func verifyUser(username: String) -> Observable<Event<Bool>>
}

extension YAPPakistan.LoginRepository: LoginRepositoryType {
    
}
