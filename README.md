# Octos CLI Test Framework

Automated cross-platform test suite for Octos CLI.

## Structure

```
octos-cli-test/
├── run_tests.sh          # Bash script (Linux/macOS)
├── run_tests.ps1         # PowerShell script (Windows)
├── test_cases.json       # Test configuration
└── README.md            # This file
```

## Quick Start

### Bash (Linux/macOS)

```bash
cd octos-cli-test
chmod +x run_tests.sh
./run_tests.sh -v
```

### PowerShell (Windows)

```powershell
cd octos-cli-test
.\run_tests.ps1 -Verbose
```

## Options

### Bash

| Option | Description | Default |
|--------|-------------|---------|
| `-b, --binary NAME` | Octos binary name | `octos` |
| `-o, --output-dir DIR` | Output directory | `test-results` |
| `-c, --config FILE` | Config file | `test_cases.json` |
| `-v, --verbose` | Verbose output | false |

### PowerShell

| Parameter | Description | Default |
|-----------|-------------|---------|
| `-Binary NAME` | Octos binary path | `octos` |
| `-OutputDir DIR` | Output directory | `test-results` |
| `-ConfigFile FILE` | Config file path | `test_cases.json` |
| `-Verbose` | Verbose output | false |

## Output

- **Reports**: `test-results/CLI_TEST_REPORT_YYYY-MM-DD.md`
- **Logs**: `test-results/logs/test_YYYYMMDD_HHMMSS.log`

## Test Categories

1. CLI Basics - help, version, basic commands
2. Tool System - tool execution
3. Security - dangerous command rejection
4. Init - project initialization
5. Clean - cleanup operations
6. Status - status display
7. Completions - shell completions
8. Skills - skill management
9. Auth - authentication
10. Channels - channel management
11. Cron - scheduled tasks
12. Chat - chat functionality
13. Gateway - gateway commands
14. Serve - server commands
15. Docs - documentation

## GitHub Actions

Push to `main` or PRs trigger automated tests on:
- Ubuntu (Bash)
- macOS (Bash)
- Windows (PowerShell)

Reports are uploaded as artifacts.

## Requirements

- Bash 4.0+ or PowerShell 5.1+
- Built octos binary
- 60MB free disk space