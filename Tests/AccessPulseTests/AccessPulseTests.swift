import AccessPulseAuditEngine
import AccessPulseCore
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
