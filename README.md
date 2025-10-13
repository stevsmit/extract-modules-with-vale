# Extract Modules & Lint with Vale

This script extracts included AsciiDoc modules from assemblies and runs [Vale](https://vale.sh/) to lint them using the **AsciiDocDITA** style package. It prints results to the terminal and saves a per-assembly `_MODULES.txt` report. Note that this script may not be 100% accurate. Use at your own risk.

---

## Contents

- `extract_modules_with_vale.sh` — main script
- `.vale.ini` — Vale configuration (included in this repo)

---

## Prerequisites

- **Bash** (Linux/macOS; available by default)
- **Python 3** (if you use any helper tooling — not required for the script itself)
- **Vale** (prose linter)

Check Vale:

```bash
vale --version

---

## Quick Start

### Clone the repository

```bash
git clone https://github.com/<your-username>/<your-repo-name>.git
cd <your-repo-name>
