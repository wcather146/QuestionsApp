//
//  UseCode.swift
//  QuestionsApp
//
//  Created by William Cather on 7/25/25.
//

import Foundation

struct UseCode: Codable {
    let code: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case code = "Code"
        case description = "Description"
    }
}
