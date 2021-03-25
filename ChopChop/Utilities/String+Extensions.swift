import Foundation

extension String {
    var length: Int {
        count
    }

    subscript (i: Int) -> String {
        self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }

    func componentsSeperatedByStrings(separators: [String]) -> [String] {
        let matches = matchesWithIndex(for: separators.joined(separator: "|"), in: self)
        var characterCount = 0
        var substrings: [String] = []
        guard !matches.isEmpty else {
            return [self]
        }
        for (substring, idx) in matches {
            if characterCount < idx {
                substrings.append(self[characterCount..<idx])
            }
            substrings.append(substring)
            characterCount = idx + substring.count
        }
        if characterCount < count {
            substrings.append(substring(fromIndex: characterCount))
        }
        return substrings
    }

}
