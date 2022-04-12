//
//  PKEvent.swift
//  YAPPakistan
//
//  Created by Zara on 28/02/2022.
//

import Foundation
import YAPCore



public enum PKAppEvent: AppEventType {
    case logout
    case loggedIn
    case cancel
    
    public func action() -> Void {
        switch(self) {
            case .logout:
                break
            case .loggedIn:
                break
            case .cancel:
                break
        }
    }
}
