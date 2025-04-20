//
//  String+.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 09/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

// MARK: - Email validation

extension String {
    var isValidEmail: Bool {
        // Regular expression pattern for email validation
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        // Create a regular expression object
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return false
        }
        // Check if the email matches the pattern
        let range = NSRange(location: 0, length: utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
}

// MARK: - Tags using #

extension String {
    func removeTagSymbol() -> String {
        guard hasPrefix("#") else { return self }
        return String(dropFirst(1)).removeTagSymbol()
    }

    func hashtags() -> [String] {
        if let regex = try? NSRegularExpression(pattern: "#[a-z0-9]+", options: .caseInsensitive) {
            let string = self as NSString

            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range).replacingOccurrences(of: "#", with: "").lowercased()
            }
        }

        return []
    }

    var asHashtagText: NSMutableAttributedString {
        let text: NSString = NSString(string: self)
        let words = text.components(separatedBy: " ").filter { $0.hasPrefix("#") }
        let attributed = NSMutableAttributedString(string: text as String)
        for word in words {
            attributed.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemBlue, range: text.range(of: word))
        }
        return attributed
    }
}
