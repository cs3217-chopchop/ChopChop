//
//  StringProtocol.swift
//  ChopChop
//
//  Created by Cao Wenjie on 16/3/21.
//

import Foundation

/// https://stackoverflow.com/questions/42476395/how-to-split-string-using-regex-expressions
extension StringProtocol {
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...].range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
