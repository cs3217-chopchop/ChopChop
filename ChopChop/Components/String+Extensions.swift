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
    let inds: [String.Index] = separators.flatMap { s in
      self.components(separatedBy: s).map { r in [r.startIndex, r.endIndex] } ?? []
    }.flatMap { $0 }
    let ended: [String.Index] = [startIndex] + inds + [endIndex]
    guard ended.count >= 2 else {
        return [self]
    }
    let chunks = stride(from: 0, to: ended.count - 2, by: 1)
    let bounds = chunks.map { i in (ended[i], ended[i + 1]) }
    return bounds
      .map { s, e in String(self[s ..< e]) }
      .filter { sl in !sl.isEmpty }
  }

}
