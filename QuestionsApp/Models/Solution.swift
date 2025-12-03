//
//  Solution.swift
//  QuestionsApp
//
//  Created by William Cather on 12/1/25.
//

import Foundation

struct Solution: Decodable, Equatable {
    let UNID: String
    let SolutionCode: String
    let Solution: String
    let SubTitle: String?
    let UnitCost: String
    let UnitType: String
    
    // MARK: - Custom decoding to handle empty strings as nil
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.UNID = try container.decode(String.self, forKey: .UNID)
        self.SolutionCode = try container.decode(String.self, forKey: .SolutionCode)
        self.Solution = try container.decode(String.self, forKey: .Solution)
        
        // THIS IS THE FIX — convert "" → nil
        let subTitleRaw = try container.decode(String.self, forKey: .SubTitle)
        self.SubTitle = subTitleRaw.isEmpty ? nil : subTitleRaw
        
        self.UnitCost = try container.decode(String.self, forKey: .UnitCost)
        self.UnitType = try container.decode(String.self, forKey: .UnitType)
    }
        
    // MARK: - CodingKeys (exact match to your JSON)
    private enum CodingKeys: String, CodingKey {
        case UNID
        case SolutionCode
        case Solution
        case SubTitle
        case UnitCost
        case UnitType
    }
        
    // MARK: - Helpers
    var unitCostValue: Double {
        Double(UnitCost) ?? 0.0
    }
        
    var isNoCost: Bool {
        unitCostValue == 0.0 || UnitType.lowercased() == "n/a"
    }
}
