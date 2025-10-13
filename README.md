# Extract Modules & Lint with Vale

This script extracts included AsciiDoc modules from assemblies and runs [Vale](https://vale.sh/) to lint them using the **AsciiDocDITA** style package. It prints results to the terminal and saves a per-assembly `_MODULES.txt` report in the extract-modules-with-vale folder. Note that this script may not be 100% accurate. Use at your own risk.

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
```
---

## Quick Start

1. Clone the repository:

```bash
git clone 
```
2. Change into the directory:

```bash
cd extract-modules-with-vale
```
3. Sync Vale by entering the following command:

 ```bash
vale sync
```

4. Make the script executable:

```bash
chmod +x extract_modules_with_vale.sh
```
5. Run the script. The script accepts either a directory or a single assembly file.

```bash
# Scan a whole docs directory
./extract_modules_with_vale.sh /home/path/to/openshift-docs/<directory_name>

# Process a single assembly file
./extract_modules_with_vale.sh /home/path/to/openshift-docs/<directory_name>/<assembly_name>.adoc
```
---
## Output
The script prints progress and Vale results to the terminal.

It also writes a per-assembly _MODULES.txt file in an output directory next to the target.
