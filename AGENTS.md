# Octos CLI Test Framework

Cross-platform automated test suite for Octos CLI.

## Running Tests

**Prerequisite:** Build the `octos` binary from the parent repo with `cargo build --all-features`.

**Bash (Linux/macOS):**
```bash
./run_tests.sh -v                           # verbose
./run_tests.sh -b ./target/release/octos   # custom binary
```

**PowerShell (Windows):**
```powershell
.\run_tests.ps1 -Verbose
.\run_tests.ps1 -Binary "C:\path\to\octos.exe"
```

**Options:** `-b/--binary`, `-o/--output-dir`, `-c/--config`, `-v/--verbose`

## Test Configuration

- Test cases: `test_cases.json`
- Test categories: CLI, Tools, Security, Init, Clean, Status, Completions, Skills, Auth, Channels, Cron, Chat, Gateway, Serve, Docs
- Placeholders: `{testDir}` (test workspace), `{tempDir}` (temp directory)
- Validation modes: `contains`, `not_contains`, `exitcode`

## Output

- Reports: `test-results/CLI_TEST_REPORT_YYYY-MM-DD.md`
- Logs: `test-results/logs/test_YYYYMMDD_HHMMSS.log`

## Notes

- Bash script requires `jq` (`apt install jq` / `brew install jq`)
- Windows binary lookup: first checks local path, then PATH environment variable
- Scripts create temp workspace at `$env:TEMP\octos-cli-test` (Windows) or `mktemp -d` (Bash)
