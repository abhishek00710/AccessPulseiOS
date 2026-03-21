import Foundation

enum RuleHelpers {
    static func lines(for content: String) -> [String] {
        content.components(separatedBy: .newlines)
    }

    static func lineNumber(in content: String, for snippet: String) -> Int {
        let lines = lines(for: content)
        for (index, line) in lines.enumerated() where line.contains(snippet) {
            return index + 1
        }
        return 1
    }

    static func regexMatches(pattern: String, in content: String) -> [NSTextCheckingResult] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }

        let range = NSRange(content.startIndex..<content.endIndex, in: content)
        return regex.matches(in: content, options: [], range: range)
    }

    static func string(in content: String, for range: NSRange) -> String {
        guard let swiftRange = Range(range, in: content) else {
            return ""
        }
        return String(content[swiftRange])
    }
}
