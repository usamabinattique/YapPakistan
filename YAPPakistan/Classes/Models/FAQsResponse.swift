//
//  FAQsModel.swift
//  YAPPakistan
//
//  Created by Awais on 17/05/2022.
//

import Foundation

// MARK: - FAQs Model
public struct FAQsResponse: Codable {
    let title, question, answer: String
}


public struct GroupedFAQs: Codable {
    let title : String
    let questionsAnswers = [QuestionAndAnsers]()
}

public struct QuestionAndAnsers : Codable {
    let question: String
    let answer: String
}
