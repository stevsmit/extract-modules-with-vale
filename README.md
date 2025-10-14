# Extract Modules from assemblies

Two scripts are provided in this repository:

1. The `extract-modules-with-vale.sh` script extracts AsciiDoc modules from assemblies and runs [Vale](https://vale.sh/) to lint them using the **AsciiDocDITA** style package. It prints results to the terminal and saves a per-assembly `_MODULES.txt` report in the extract-modules-with-vale folder. Use this option if you want to run Vale on all modules at one time and save the results in a .txt file.
2. The `multi_dir_extract_openshift_modules.sh` script ONLY extracts AsciiDoc modules from assemblies, and saves a modules-per-assembly.txt report in the folder. Use this option if you do want to run Vale manually on individual modules or assemblies.
---

Either option works, but note that if you use the `multi_dir_extract_openshift_modules.sh` script, you must run Vale manually on the assembly and the list of modules returned to generate the list of errors. I think this option is cleaner. 

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

4. Make the scripts executable:
```bash
chmod +x extract_modules_with_vale.sh multi_dir_extract_openshift_modules.sh
```
5. Run either script. The script accepts either a directory or a single assembly file.

```bash
# Scan a whole docs directory:
./extract_modules_with_vale.sh /home/path/to/openshift-docs/<directory_name>

# Process a single assembly file:
./extract_modules_with_vale.sh /home/path/to/openshift-docs/<directory_name>/<assembly_name>.adoc

# Only list modules within an directory:
./multi_dir_extract_openshift_modules.sh /home/path/to/openshift-docs/<directory_name>

# Only list modules with an assembly:
./multi_dir_extract_openshift_modules.sh /home/path/to/openshift-docs/<directory_name>/<assembly_name>.adoc
```
---

6. Optional: If you used the `multi_dir_extract_openshift_modules.sh` script, run Vale on the assembly and the modules returned:
```bash
# Run Vale on an assembly file:
vale /home/path/to/openshift-docs/<directory_name><assembly_name>.adoc

# Run Vale on a module:

vale /home/path/to/openshift-docs/modules/<module_name>.adoc
```

## Output
The script prints progress and Vale results to the terminal.

It also writes a per-assembly _MODULES.txt file in an output directory next to the target.
