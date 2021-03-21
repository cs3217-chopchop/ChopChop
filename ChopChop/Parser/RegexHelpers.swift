import Foundation

//https://www.hackingwithswift.com/articles/108/how-to-use-regular-expressions-in-swift
//https://stackoverflow.com/questions/27880650/swift-extract-regex-matches
func matchesWithIndex(for regex: String, in text: String) -> [(String, Int)] {
    do {
        let regex = try NSRegularExpression(pattern: regex, options: .caseInsensitive)
        let results = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))

        return results.compactMap {
            guard let range = Range($0.range, in: text) else {
                return nil
            }

            return (String(text[range]), $0.range.lowerBound)
        }
    } catch {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

extension NSRegularExpression {
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }

    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}

extension String {
    static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs, options: .caseInsensitive) else {
            return false
        }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }
}
