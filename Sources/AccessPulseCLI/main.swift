import AccessPulseAuditEngine
import AccessPulseCore
import Foundation

@main
enum AccessPulseCLI {
    static func main() async {
        let arguments = Array(CommandLine.arguments.dropFirst())

        guard let command = arguments.first else {
            print(usage)
            Foundation.exit(EXIT_FAILURE)
        }

        switch command {
        case "audit":
            await runAudit(arguments: Array(arguments.dropFirst()))
        default:
            print(usage)
            Foundation.exit(EXIT_FAILURE)
        }
    }

    private static var usage: String {
        """
        Usage:
          accesspulse audit --path <directory> [--format markdown|json|sarif]
        """
    }

    private static func runAudit(arguments: [String]) async {
        let path = value(after: "--path", in: arguments) ?? "."
        let format = value(after: "--format", in: arguments) ?? "markdown"

        do {
            let files = try loadSwiftFiles(at: path)
            let context = AuditContext(
                sourceRoot: path,
                moduleName: URL(fileURLWithPath: path).lastPathComponent,
                files: files
            )

            let engine = AuditEngine()
            let report = await engine.run(on: context)

            switch format {
            case "json":
                print(try AccessibilityReportFormatter.json(report))
            case "sarif":
                print(try AccessibilityReportFormatter.sarif(report))
            default:
                print(AccessibilityReportFormatter.markdown(report))
            }

            let shouldFail = report.findings.contains { $0.severity == .error || $0.severity == .warning }
            Foundation.exit(shouldFail ? EXIT_FAILURE : EXIT_SUCCESS)
        } catch {
            fputs("AccessPulse failed: \(error)\n", stderr)
            Foundation.exit(EXIT_FAILURE)
        }
    }

    private static func value(after flag: String, in arguments: [String]) -> String? {
        guard let flagIndex = arguments.firstIndex(of: flag), arguments.indices.contains(flagIndex + 1) else {
            return nil
        }
        return arguments[flagIndex + 1]
    }

    private static func loadSwiftFiles(at path: String) throws -> [SourceFile] {
        let fileManager = FileManager.default
        let rootURL = URL(fileURLWithPath: path)
        guard let enumerator = fileManager.enumerator(at: rootURL, includingPropertiesForKeys: nil) else {
            return []
        }

        var files: [SourceFile] = []
        for case let fileURL as URL in enumerator where fileURL.pathExtension == "swift" {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            files.append(SourceFile(path: fileURL.path, content: content))
        }
        return files
    }
}
