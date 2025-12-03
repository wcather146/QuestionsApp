//
//  Project.swift
//  QuestionsApp
//
//  Created by William Cather on 6/25/25.
//

// MARK: File - Model/Project.swift
import Foundation

struct Project: Codable {
    let projectNumber: String
    let projectName: String
    
    enum CodingKeys: String, CodingKey {
        case projectNumber = "Project Number"
        case projectName = "Project Name"
    }
}
