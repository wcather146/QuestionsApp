//
//  Form.swift
//  QuestionsApp
//
//  Created by William Cather on 7/16/25.
//

import Foundation

struct Form: Codable {
    var name: String
    var code: String
 
    enum CodingKeys: String, CodingKey {
        case name = "Form Name"
        case code = "Form Code"
    }
}
