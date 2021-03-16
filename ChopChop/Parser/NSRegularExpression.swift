//
//  NSRegularExpression.swift
//  ChopChop
//
//  Created by Cao Wenjie on 16/3/21.
//
import Foundation

/// https://www.hackingwithswift.com/articles/108/how-to-use-regular-expressions-in-swift
extension NSRegularExpression {

    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern, options: [.caseInsensitive])
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }

    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}
