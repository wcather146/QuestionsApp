//
//  SurveyProject.swift
//  QuestionsApp
//
//  Created by William Cather on 8/4/25.
//
import Foundation

struct SurveyProject: Codable {
    let project: String
    let campus: String
    let site: String
    let unid: String
    let standard: String
    let costFactor: String
    var surveyDate: Date?
    var teamLead: String?
    var team: String?
    
    enum CodingKeys: String, CodingKey {
        case project
        case campus
        case site
        case unid
        case standard
        case costFactor
        case surveyDate
        case teamLead
        case team
    }
}

struct Campus: Codable {
    let campus: String
    
    enum CodingKeys: String, CodingKey {
        case campus = "Campus"
    }
}

struct Site: Codable {
    let unid: String
    let site: String
    let standard: String
    let costFactor: String
    
    enum CodingKeys: String, CodingKey {
        case unid = "UNID"
        case site = "Site"
        case standard = "Standard"
        case costFactor = "CostFactor"
    }
}
