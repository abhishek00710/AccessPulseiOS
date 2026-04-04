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
          accesspulse audit --path <directory> [--format markdown|json|sarif] [--exclude <path> ...]
        """
    }

    private static func runAudit(arguments: [String]) async {
        let path = value(after: "--path", in: arguments) ?? "."
        let format = value(after: "--format", in: arguments) ?? "markdown"
        let excludedPaths = values(after: "--exclude", in: arguments)

        do {
            let files = try loadSwiftFiles(at: path, excluding: excludedPaths)
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

    private static func values(after flag: String, in arguments: [String]) -> [String] {
        arguments.enumerated().compactMap { index, argument in
            guard argument == flag, arguments.indices.contains(index + 1) else {
                return nil
            }
            return arguments[index + 1]
        }
    }

    private static func loadSwiftFiles(at path: String, excluding excludedPaths: [String]) throws -> [SourceFile] {
        let fileManager = FileManager.default
        let rootURL = URL(fileURLWithPath: path).standardizedFileURL
        let excludedURLs = excludedPaths.map {
            if $0.hasPrefix("/") {
                return URL(fileURLWithPath: $0).standardizedFileURL.path
            }
            return rootURL
                .appending(path: $0)
                .standardizedFileURL
                .path
        }

        guard let enumerator = fileManager.enumerator(at: rootURL, includingPropertiesForKeys: nil) else {
            return []
        }

        var files: [SourceFile] = []
        for case let fileURL as URL in enumerator where fileURL.pathExtension == "swift" {
            let standardizedPath = fileURL.standardizedFileURL.path
            if excludedURLs.contains(where: { standardizedPath.hasPrefix($0) }) {
                continue
            }

            let content = try String(contentsOf: fileURL, encoding: .utf8)
            files.append(SourceFile(path: fileURL.path, content: content))
        }
        return files
    }
}
