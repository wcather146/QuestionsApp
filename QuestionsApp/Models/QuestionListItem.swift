//
//  QuestionListItem.swift
//  QuestionsApp
//
//  Created by William Cather on 6/25/25.
//

// MARK: File - Models/QuestionListItem.swift
import Foundation

struct QuestionListItem: Codable, Identifiable {
    let id = UUID()
    let questionID: String?
    let questionNumber: String
    let acCode: String
    let question: String
    let shortform: String
    let qtype: String
    let header: String
    let subHeader: String
    let stricter: String
    let stricterType: String
    let stricterState: String
    
    enum CodingKeys: String, CodingKey {
        case questionID = "QuestionID"
        case questionNumber = "QuestionNumber"
        case acCode = "AC Code"
        case question = "Question"
        case shortform = "Shortform"
        case qtype = "Type"
        case header = "Header"
        case subHeader = "SubHeader"
        case stricter = "Stricter"
        case stricterType = "StricterType"
        case stricterState = "StricterState"
    }
}
