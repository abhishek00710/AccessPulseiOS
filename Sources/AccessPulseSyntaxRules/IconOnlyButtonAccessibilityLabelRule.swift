import AccessPulseCore
import Foundation

public struct IconOnlyButtonAccessibilityLabelRule: AccessibilityRule {
    public let id = "missing_accessibility_label"
    public let name = "Missing Accessibility Label"

    public init() {}

    public func audit(in context: AuditContext) async -> [AccessibilityFinding] {
        context.files.flatMap { file in
            audit(file: file)
        }
    }

    private func audit(file: SourceFile) -> [AccessibilityFinding] {
        let sanitized = stripCommentsPreservingLayout(in: file.content)
        let patterns = [
            #"Button\s*\(\s*action:\s*\{[\s\S]*?\}\s*\)\s*\{\s*Image\s*\("#,
            #"Button\s*\{\s*[\s\S]*?\}\s*label:\s*\{\s*Image\s*\("#
        ]

        return patterns.flatMap { pattern -> [AccessibilityFinding] in
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
                return []
            }

            let range = NSRange(sanitized.startIndex..<sanitized.endIndex, in: sanitized)
            return regex.matches(in: sanitized, options: [], range: range).compactMap { match in
                let startOffset = match.range.location
                let endOffset = min(sanitized.utf16.count, match.range.location + match.range.length + 220)
                let contextRange = NSRange(location: match.range.location, length: max(0, endOffset - match.range.location))
                let localContext = string(in: sanitized, for: contextRange)

                if localContext.contains(".accessibilityLabel(") || localContext.contains("Text(") || localContext.contains("Label(") {
                    return nil
                }

                return AccessibilityFinding(
                    ruleID: id,
                    summary: "Potential missing accessibility label",
                    detail: "An icon-only button was found without a nearby explicit accessibility label.",
                    severity: .warning,
                    remediation: "Add `.accessibilityLabel(...)` or use a text-based `Button` label so VoiceOver can announce the action clearly.",
                    location: AccessibilityLocation(
                        filePath: file.path,
                        line: lineNumber(in: sanitized, utf16Offset: startOffset),
                        column: 1
                    ),
                    tags: ["voiceover", "label", "button"]
                )
            }
        }
    }

    private func stripCommentsPreservingLayout(in source: String) -> String {
        enum State {
            case code
            case lineComment
            case blockComment
            case stringLiteral
        }

        var result = ""
        var state: State = .code
        var iterator = source.makeIterator()
        var current = iterator.next()
        var next = iterator.next()

        while let character = current {
            switch state {
            case .code:
                if character == "/", next == "/" {
                    result.append(" ")
                    current = next
                    next = iterator.next()
                    state = .lineComment
                } else if character == "/", next == "*" {
                    result.append(" ")
                    current = next
                    next = iterator.next()
                    state = .blockComment
                } else {
                    result.append(character)
                    if character == "\"" {
                        state = .stringLiteral
                    }
                }
            case .lineComment:
                if character == "\n" {
                    result.append("\n")
                    state = .code
                } else {
                    result.append(" ")
                }
            case .blockComment:
                if character == "*", next == "/" {
                    result.append(" ")
                    current = next
                    next = iterator.next()
                    state = .code
                } else if character == "\n" {
                    result.append("\n")
                } else {
                    result.append(" ")
                }
            case .stringLiteral:
                result.append(character)
                if character == "\"" {
                    state = .code
                }
            }

            current = next
            next = iterator.next()
        }

        return result
    }

    private func string(in content: String, for range: NSRange) -> String {
        guard let swiftRange = Range(range, in: content) else {
            return ""
        }
        return String(content[swiftRange])
    }

    private func lineNumber(in content: String, utf16Offset: Int) -> Int {
        let index = String.Index(utf16Offset: utf16Offset, in: content)

        return content[..<index].reduce(into: 1) { line, character in
            if character == "\n" {
                line += 1
            }
        }
    }
}
