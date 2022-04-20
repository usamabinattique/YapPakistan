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
    var nameSequenceArray: [String] {
        let firstOption = name
        switch name.splits {
        case 0:
            return [name]
        case 1:
            let secondOption = (name.allLettersSepartedBySpaces[0])[0] + " " + name.allLettersSepartedBySpaces[1]
            return [firstOption,secondOption]
        case 2:
            let secondOption = name.allLettersSepartedBySpaces[0] + " " + name.allLettersSepartedBySpaces[1]
            let thirdOption = name.allLettersSepartedBySpaces[0] + " " + name.allLettersSepartedBySpaces[2]
            return [firstOption,secondOption,thirdOption]
        default:
            let secondOption = name.allLettersSepartedBySpaces[0] + " " + name.allLettersSepartedBySpaces[1]
            let thirdOption = name.allLettersSepartedBySpaces[0] + " " + name.allLettersSepartedBySpaces[2]
            let fourthOption = name.allLettersSepartedBySpaces[0] + " " + name.allLettersSepartedBySpaces[3]
            return [firstOption,secondOption,thirdOption,fourthOption]
//           return [name.allLettersSepartedBySpaces[0],name.allLettersSepartedBySpaces[1],name.allLettersSepartedBySpaces[2]]
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
