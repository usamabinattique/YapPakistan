//
//  NameSequenceType.swift
//  YAPPakistan
//
//  Created by Yasir on 04/02/2022.
//

import Foundation

public enum NameSequenceType {
    case all
    case firstLastLetters
    case firstCharacterLastLetter
}

struct NameSequence {
    var nameFormatted: String? {
        switch type {
        case .all:
            return name
        case .firstLastLetters:
            return name.firstAndLastLetters
        case .firstCharacterLastLetter:
            return name.firstCharacterAndLastLetter
        }
    }
    var name: String
    
    
    public init(name: String) {
        self.name = name
    }
    
    var type = NameSequenceType.all
    var isChecked: Bool = false
    
    func allCases()-> [NameSequenceType] {
        return [.all,
                .firstLastLetters,
                .firstCharacterLastLetter]
    }
}
