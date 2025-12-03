//
//  State.swift
//  QuestionsApp
//
//  Created by William Cather on 7/16/25.
//

import Foundation

struct State: Codable {
    let state: String
    let standard: String
    
    enum CodingKeys: String, CodingKey {
        case state = "State"
        case standard = "Standard"
    }
}
