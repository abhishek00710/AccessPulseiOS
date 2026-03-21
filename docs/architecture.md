# Architecture

AccessPulse iOS is organized around three responsibilities:

## 1. Remediation

`AccessPulseUI` gives teams components that already encode good defaults for labels, hints, dynamic type, and hit area expectations.

## 2. Audit

`AccessPulseAuditEngine` runs rule packs concurrently with structured concurrency. The engine is an actor so shared state such as report assembly and future caching hooks stay isolated.

`AccessPulseSyntaxRules` adds AST-aware static analysis through SwiftSyntax for rules that are too noisy when implemented with text matching alone.

## 3. Reporting

`AccessPulseCore` owns findings, severity, scorecards, and formatter output for markdown and JSON.

## Extension model

- Contributors can add rules by conforming to `AccessibilityRule`.
- Teams can assemble custom `RuleSet` values for local standards.
- The CLI can be embedded in CI, pre-commit hooks, or used as a standalone audit command.
