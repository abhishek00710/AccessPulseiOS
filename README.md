# AccessPulse iOS

<p align="center">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-6-orange.svg" />
  <img alt="Platforms" src="https://img.shields.io/badge/Platforms-iOS%2017%2B%20%7C%20macOS%2014%2B-blue.svg" />
  <img alt="License" src="https://img.shields.io/badge/License-MIT-green.svg" />
  <img alt="Focus" src="https://img.shields.io/badge/Focus-Accessibility-black.svg" />
</p>

AccessPulse iOS is an open-source accessibility audit and remediation toolkit for SwiftUI and UIKit teams. It combines reusable accessible components, an actor-based audit engine, a scoring system, sample implementations, and CI-ready reporting so accessibility work becomes part of normal development instead of a last-minute pass.

## What is included

- `AccessPulseUI`: reusable SwiftUI and UIKit accessibility-first components
- `AccessPulseAuditEngine`: concurrent rule execution for accessibility audits
- `AccessPulseSyntaxRules`: SwiftSyntax-backed static analysis rules
- `AccessPulseCore`: shared models, scoring, and report formatting
- `AccessPulseExamples`: before/after sample screens for contributor reference
- `accesspulse`: CLI for local checks and GitHub Actions integration
- `Examples/AccessPulseDemoApp`: sample app scaffold for GitHub contributors
- `.github/`: issue templates, PR template, and CI workflow

## Why this project matters

- iOS has strong platform accessibility support, but teams still miss basics like labels, touch targets, and dynamic type behavior.
- Developers need practical building blocks and automated feedback in pull requests.
- Open-source accessibility tooling is a meaningful place to contribute both engineering depth and social impact.

## Architecture

- Actor-based audit engine serializes shared report assembly while running rules concurrently with structured concurrency.
- Plugin-style rules let contributors ship new audits without modifying the engine.
- Scorecards convert findings into a module-level health snapshot that teams can track over time.
- The CLI emits markdown or JSON for CI comments, artifacts, and dashboards.

## Current rule coverage

- Missing accessibility labels in common SwiftUI patterns
- Touch targets that appear smaller than 44x44 points
- Risky fixed-size fonts that often break dynamic type expectations
- SwiftSyntax-based detection for placeholder-only `TextField` controls

## Quick start

```bash
cd AccessPulseiOS
swift test
swift run accesspulse audit --path Sources --format markdown
```

## Example CLI output

```markdown
# AccessPulse Report

- Score: 78/100
- Checks passed: 5/8
- Findings: 3

## Findings

1. [warning] `missing_accessibility_label`
   Missing accessibility label on Image
```

## Using the UI components

```swift
import AccessPulseUI
import SwiftUI

struct CheckoutView: View {
    @State private var email = ""

    var body: some View {
        VStack(spacing: 16) {
            AccessibleFormField(
                title: "Email address",
                text: $email,
                prompt: "name@example.com",
                accessibilityHint: "Required for sending your receipt"
            )

            AccessibleButton(
                accessibilityLabel: "Complete purchase",
                accessibilityHint: "Double tap to submit your order"
            ) {
                Label("Pay now", systemImage: "creditcard.fill")
            } action: {
                // Submit order
            }
        }
        .padding()
    }
}
```

## GitHub integration

The repository includes:

- a CI workflow in [`.github/workflows/ci.yml`](.github/workflows/ci.yml)
- a local composite action in [`.github/actions/accesspulse-audit/action.yml`](.github/actions/accesspulse-audit/action.yml)
- issue templates for bug reports, new rules, and component requests
- a sample app scaffold in [`Examples/AccessPulseDemoApp`](Examples/AccessPulseDemoApp)

## Roadmap

- SwiftSyntax-backed analyzers for richer AST-aware rules
- UI test and snapshot hooks for runtime accessibility verification
- accessibility disclosure helpers for release workflows
- module trend tracking across pull requests

## Contributing

Contributions are welcome, especially around new rule packs, better heuristics, sample screens, and CI reporting. Start with [CONTRIBUTING.md](CONTRIBUTING.md).
