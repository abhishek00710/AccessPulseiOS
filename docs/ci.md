# CI Integration

## Local usage

```bash
swift run accesspulse audit --path Sources --format markdown
```

For code-scanning friendly output:

```bash
swift run accesspulse audit --path Sources --format sarif > accesspulse.sarif
```

To keep intentional demo violations out of CI:

```bash
swift run accesspulse audit --path Sources --exclude AccessPulseExamples --format markdown
```

## Pull request usage

The repository includes a GitHub Actions workflow that:

1. Builds the package
2. Runs the audit CLI
3. Stores a markdown report as an artifact
4. Uploads SARIF output to GitHub code scanning

If you want GitHub code scanning integration, emit `sarif` instead of markdown and upload the generated file as a SARIF artifact in your workflow.

If you want stricter gating, keep the CLI exit code behavior as-is so warnings or errors fail the workflow. If you want non-blocking reporting, change the workflow step to `continue-on-error: true`.

## Workflow location

The repository workflow lives at:

- `.github/workflows/ci.yml`

It runs:

```bash
swift test
swift run accesspulse audit --path Sources --exclude AccessPulseExamples --format markdown
swift run accesspulse audit --path Sources --exclude AccessPulseExamples --format sarif
```

The SARIF file is then uploaded using GitHub's `upload-sarif` action so findings can appear in the repository's Security or Code Scanning UI.
