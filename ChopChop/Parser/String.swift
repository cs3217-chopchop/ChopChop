//
//  String.swift
//  ChopChop
//
//  Created by Cao Wenjie on 16/3/21.
//

import Foundation

/// https://www.hackingwithswift.com/articles/108/how-to-use-regular-expressions-in-swift
extension String {
    static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }
}
