# AccessPulse Demo App

This folder contains a lightweight sample iOS app scaffold that shows how a product team could adopt AccessPulse in a real codebase.

## What it demonstrates

- before/after accessibility examples
- reusable `AccessPulseUI` components
- an in-app accessibility scorecard screen
- remediation guidance that mirrors the CLI report

## Suggested setup

1. Create a new iOS App target in Xcode named `AccessPulseDemoApp`.
2. Add the local `AccessPulseiOS` package.
3. Copy this folder's `App`, `Features`, `Views`, and `Resources` groups into the target.
4. Run the app on an iPhone simulator with larger Dynamic Type sizes and VoiceOver enabled.

The scaffold is kept as plain source so contributors can browse it directly on GitHub without needing generated project files in the repo.
