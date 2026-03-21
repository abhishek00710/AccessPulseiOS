# CI Integration

## Local usage

```bash
swift run accesspulse audit --path Sources --format markdown
```

## Pull request usage

The repository includes a composite action that:

1. Builds the package
2. Runs the audit CLI
3. Stores a markdown report as an artifact

If you want stricter gating, keep the CLI exit code behavior as-is so warnings or errors fail the workflow. If you want non-blocking reporting, change the workflow step to `continue-on-error: true`.
