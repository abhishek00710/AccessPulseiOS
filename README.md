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
- `Examples/AccessPulseDemo`: sample demo app for contributors and adopters
- `.github/`: issue templates, PR template, and CI workflow

## Why this project matters

- iOS has strong platform accessibility support, but teams still miss basics like labels, touch targets, and dynamic type behavior.
- Developers need practical building blocks and automated feedback in pull requests.
- Open-source accessibility tooling is a meaningful place to contribute both engineering depth and social impact.

## Architecture

- Actor-based audit engine serializes shared report assembly while running rules concurrently with structured concurrency.
- Plugin-style rules let contributors ship new audits without modifying the engine.
- Scorecards convert findings into a module-level health snapshot that teams can track over time.
- The CLI emits markdown, JSON, or SARIF for CI comments, artifacts, dashboards, and code scanning.

## Current rule coverage

- Missing accessibility labels in common SwiftUI patterns
- Touch targets that appear smaller than 44x44 points
- Risky fixed-size fonts that often break dynamic type expectations
- Dynamic Type clamping that can block accessibility text sizes
- Interactive controls that are hidden from assistive technologies
- SwiftSyntax-based detection for placeholder-only `TextField` controls

## Quick start

```bash
cd AccessPulseiOS
swift test
swift run accesspulse audit --path Sources --format markdown
swift run accesspulse audit --path Sources --format sarif > accesspulse.sarif
swift run accesspulse audit --path Sources --exclude AccessPulseExamples --format markdown
```

## Start with the demo app

If you want the fastest way to understand how AccessPulse fits into a real app, start with the demo app in the public repository:

- Demo app reference: [AccessPulseDemo on GitHub](https://github.com/abhishek00710/AccessPulseiOS/tree/main/Examples/AccessPulseDemo)

This is the best first stop for contributors because it shows:

- how `AccessPulseUI` components are used in SwiftUI screens
- how accessible patterns look in a simple app structure
- how teams might adopt the toolkit in a production-style iOS project

If you are planning to contribute new components, rules, or docs, use the demo app first to get a practical feel for how someone would integrate AccessPulse into their own app.

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
    @State private var password = ""
    @State private var wantsHints = true

    var body: some View {
        VStack(spacing: 16) {
            AccessibleStatusBanner(
                title: "Checkout accessibility",
                message: "Labels, large hit areas, and readable text styles are enabled.",
                tone: .info
            )

            AccessibleFormField(
                title: "Email address",
                text: $email,
                prompt: "name@example.com",
                accessibilityHint: "Required for sending your receipt"
            )

            AccessibleSecureField(
                title: "Password",
                text: $password,
                prompt: "Required",
                accessibilityHint: "Use your account password to continue"
            )

            AccessibleToggleRow(
                title: "VoiceOver hints",
                description: "Keep extra spoken guidance enabled during checkout",
                isOn: $wantsHints
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
- SARIF output for GitHub code scanning
- a demo app in [`Examples/AccessPulseDemo`](Examples/AccessPulseDemo)

## Roadmap

- SwiftSyntax-backed analyzers for richer AST-aware rules
- UI test and snapshot hooks for runtime accessibility verification
- accessibility disclosure helpers for release workflows
- module trend tracking across pull requests

## Contributing

Contributions are welcome, especially around new rule packs, better heuristics, sample screens, and CI reporting. A good first step is to open the demo app and see how AccessPulse components would be used in a real project, then continue with [CONTRIBUTING.md](CONTRIBUTING.md).

High-impact contributor paths right now:

- add more accessibility-first SwiftUI and UIKit components to `AccessPulseUI`
- expand the SwiftSyntax rule pack with AST-aware checks
- improve report output for pull request comments and CI dashboards
- add runtime UI-test or snapshot hooks for accessibility verification
