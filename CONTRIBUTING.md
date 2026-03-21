# Contributing

Thanks for helping make iOS apps more accessible.

## Good first contributions

- Add a new audit rule with tests
- Improve a reusable component for SwiftUI or UIKit
- Expand the sample screens with before/after examples
- Improve report formatting or CI output
- Strengthen documentation for remediation guidance

## Project principles

- Prefer actionable accessibility guidance over abstract warnings
- Keep APIs easy to adopt in production apps
- Default to inclusive patterns such as dynamic type, VoiceOver clarity, and touch target safety
- Keep heuristics transparent so contributors can improve them

## Adding a rule

1. Create a type that conforms to `AccessibilityRule`.
2. Use `SourceFile` content to inspect code patterns.
3. Return `AccessibilityFinding` values with a clear remediation message.
4. Add the rule to `RuleSet.default`.
5. Cover both positive and negative cases in tests.

## Pull request checklist

- Explain the user impact and accessibility rationale
- Add tests for behavior changes
- Update `README.md` or docs when new features are introduced
- Keep warnings actionable and contributor-friendly
