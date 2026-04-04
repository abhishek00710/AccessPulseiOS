import AccessPulseAuditEngine
import AccessPulseCore
import AccessPulseSyntaxRules
import Foundation
import Testing

@Test
func missingLabelRuleFindsImageWithoutAccessibleLabel() async throws {
    let source = """
    import SwiftUI

    struct DemoView: View {
        var body: some View {
            Image(systemName: "star.fill")
        }
    }
    """

    let context = AuditContext(
        sourceRoot: "/tmp",
        moduleName: "Demo",
        files: [SourceFile(path: "/tmp/DemoView.swift", content: source)]
    )

    let findings = await MissingAccessibilityLabelRule().audit(in: context)
    #expect(findings.count == 1)
    #expect(findings.first?.ruleID == "missing_accessibility_label")
}

@Test
func placeholderOnlyTextFieldRuleUsesSwiftSyntax() async throws {
    let source = #"""
    import SwiftUI

    struct DemoForm: View {
        @State private var name = ""

        var body: some View {
            TextField("", text: $name)
        }
    }
    """#

    let context = AuditContext(
        sourceRoot: "/tmp",
        moduleName: "Demo",
        files: [SourceFile(path: "/tmp/DemoForm.swift", content: source)]
    )

    let findings = await RuleSet.default.rules
        .first { $0.id == "placeholder_only_textfield" }?
        .audit(in: context) ?? []

    #expect(findings.count == 1)
    #expect(findings.first?.ruleID == "placeholder_only_textfield")
}

@Test
func placeholderOnlyTextFieldRuleIgnoresCommentedOutModifiers() async throws {
    let source = #"""
    import SwiftUI

    struct DemoForm: View {
        @State private var notes = ""

        var body: some View {
            TextField("", text: $notes)
            // .accessibilityLabel("Delivery notes")
        }
    }
    """#

    let context = AuditContext(
        sourceRoot: "/tmp",
        moduleName: "Demo",
        files: [SourceFile(path: "/tmp/DemoForm.swift", content: source)]
    )

    let findings = await RuleSet.default.rules
        .first { $0.id == "placeholder_only_textfield" }?
        .audit(in: context) ?? []

    #expect(findings.count == 1)
}

@Test
func iconOnlyButtonRuleUsesSwiftSyntax() async throws {
    let source = """
    import SwiftUI

    struct DemoView: View {
        var body: some View {
            Button(action: {}) {
                Image(systemName: "paperplane.fill")
            }
        }
    }
    """

    let context = AuditContext(
        sourceRoot: "/tmp",
        moduleName: "Demo",
        files: [SourceFile(path: "/tmp/DemoView.swift", content: source)]
    )

    let findings = await IconOnlyButtonAccessibilityLabelRule().audit(in: context)

    #expect(findings.count == 1)
    #expect(findings.first?.location.line == 5)
}

@Test
func textButtonDoesNotTriggerIconOnlyRule() async throws {
    let source = """
    import SwiftUI

    struct DemoView: View {
        var body: some View {
            Button("Review order", systemImage: "cart.fill.badge.plus") {}
        }
    }
    """

    let context = AuditContext(
        sourceRoot: "/tmp",
        moduleName: "Demo",
        files: [SourceFile(path: "/tmp/DemoView.swift", content: source)]
    )

    let findings = await IconOnlyButtonAccessibilityLabelRule().audit(in: context)
    #expect(findings.isEmpty)
}

@Test
func dynamicTypeClampRuleFindsRestrictedScaling() async throws {
    let source = """
    import SwiftUI

    struct ContentView: View {
        var body: some View {
            Text("Checkout")
                .dynamicTypeSize(.small ... .large)
        }
    }
    """

    let context = AuditContext(
        sourceRoot: "/tmp",
        moduleName: "Demo",
        files: [SourceFile(path: "/tmp/ContentView.swift", content: source)]
    )

    let findings = await DynamicTypeClampRule().audit(in: context)
    #expect(findings.count == 1)
    #expect(findings.first?.ruleID == "dynamic_type_clamp_risk")
}

@Test
func hiddenInteractiveRuleFlagsAccessibilityHiddenButtons() async throws {
    let source = """
    import SwiftUI

    struct ContentView: View {
        var body: some View {
            Button("Delete") {}
                .accessibilityHidden(true)
        }
    }
    """

    let context = AuditContext(
        sourceRoot: "/tmp",
        moduleName: "Demo",
        files: [SourceFile(path: "/tmp/ContentView.swift", content: source)]
    )

    let findings = await AccessibilityHiddenInteractiveRule().audit(in: context)
    #expect(findings.count == 1)
    #expect(findings.first?.severity == .error)
}

@Test
func engineBuildsScorecardAcrossRules() async throws {
    let source = """
    import SwiftUI

    struct DemoView: View {
        var body: some View {
            Button(action: {}) {
                Image(systemName: "paperplane.fill")
            }
            .frame(width: 28, height: 28)

            Text("Caption")
                .font(.system(size: 14))
        }
    }
    """

    let context = AuditContext(
        sourceRoot: "/tmp",
        moduleName: "Demo",
        files: [SourceFile(path: "/tmp/DemoView.swift", content: source)]
    )

    let report = await AuditEngine().run(on: context)
    #expect(report.findings.count >= 2)
    #expect(report.scorecard.score < 100)
    #expect(report.scorecard.moduleName == "Demo")
}

private struct CustomRule: AccessibilityRule {
    let id = "custom_rule"
    let name = "Custom Rule"

    func audit(in context: AuditContext) async -> [AccessibilityFinding] {
        [
            AccessibilityFinding(
                ruleID: id,
                summary: "Custom rule executed",
                detail: "Third-party rules can plug into the engine.",
                severity: .info,
                remediation: "No action needed.",
                location: AccessibilityLocation(filePath: context.files[0].path, line: 1)
            )
        ]
    }
}

@Test
func customRuleCanBeRegistered() async throws {
    var ruleSet = RuleSet.default
    ruleSet.register(CustomRule())

    let context = AuditContext(
        sourceRoot: "/tmp",
        moduleName: "Demo",
        files: [SourceFile(path: "/tmp/DemoView.swift", content: "struct DemoView {}")]
    )

    let report = await AuditEngine(ruleSet: ruleSet).run(on: context)
    #expect(report.findings.contains(where: { $0.ruleID == "custom_rule" }))
}

@Test
func sarifFormatterProducesCodeScanningShape() throws {
    let report = AccessibilityReport(
        findings: [
            AccessibilityFinding(
                ruleID: "small_touch_target",
                summary: "Touch target may be smaller than 44x44 points",
                detail: "Small interactive targets can be hard to activate for many users.",
                severity: .warning,
                remediation: "Increase the tappable area to at least 44x44 points.",
                location: AccessibilityLocation(
                    filePath: "/tmp/CheckoutView.swift",
                    line: 42,
                    column: 3
                ),
                tags: ["touch-target", "swiftui"]
            )
        ],
        scorecard: AccessibilityScorecard(
            moduleName: "Demo",
            score: 96,
            totalChecks: 10,
            passedChecks: 9,
            findingCount: 1
        )
    )

    let output = try AccessibilityReportFormatter.sarif(report)
    let data = try #require(output.data(using: .utf8))
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    let runs = try #require(json?["runs"] as? [[String: Any]])
    let firstRun = try #require(runs.first)
    let tool = try #require(firstRun["tool"] as? [String: Any])
    let driver = try #require(tool["driver"] as? [String: Any])
    let results = try #require(firstRun["results"] as? [[String: Any]])
    let firstResult = try #require(results.first)

    #expect(json?["version"] as? String == "2.1.0")
    #expect(driver["name"] as? String == "AccessPulse iOS")
    #expect(firstResult["ruleId"] as? String == "small_touch_target")
    #expect(firstResult["level"] as? String == "warning")
}
