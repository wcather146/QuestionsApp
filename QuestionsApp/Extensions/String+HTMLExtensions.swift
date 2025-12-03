//
//  String+HTMLExtensions.swift
//  QuestionsApp
//
//  Created by William Cather on 6/25/25.
//

// MARK: File - Extensions/String+HTMLExtensions.swift
import Foundation

extension String {
    func decodingHTMLEntities() -> String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }
        return attributedString.string
    }
}
