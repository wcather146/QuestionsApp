//
//  QuestionDetail.swift
//  QuestionsApp
//
//  Created by William Cather on 6/25/25.
//

// MARK: File - Model/QuestionDetail.swift
struct QuestionDetail: Codable {
    let questionNumber: String
    let acCode: String?
    let disabilityType: String
    let barrierQuestion: String
    let interpretation: String?
    let noteToSurveyor: String?
    let acceptableMeasurement: String?
    let desiredInformation: String
    let sectionNumber: String?
    let figureNumber: String?
    let codeReference: String?
    let coradaReference: String?
    
    enum CodingKeys: String, CodingKey {
        case questionNumber = "QuestionNumber"
        case acCode = "ACCode"
        case disabilityType = "Disability Type"
        case barrierQuestion = "Barrier Question"
        case interpretation = "Interpretation"
        case noteToSurveyor = "Note to Surveyor"
        case acceptableMeasurement = "Acceptable Measurement"
        case desiredInformation = "Desired Information"
        case sectionNumber = "Section Number"
        case figureNumber = "Figure Number"
        case codeReference = "Code Reference"
        case coradaReference = "Corada Reference"
    }
}
