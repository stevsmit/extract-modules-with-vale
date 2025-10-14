# Extract Modules from assemblies

Two scripts are provided in this repository:

1. The `extract-modules-with-vale.sh` script extracts AsciiDoc modules from assemblies and runs [Vale](https://vale.sh/) to lint them using the **AsciiDocDITA** style package. It prints results to the terminal and saves a per-assembly `_MODULES.txt` report in the extract-modules-with-vale folder. Use this option if you want to run Vale on all modules at one time and save the results in a .txt file.
2. The `multi_dir_extract_openshift_modules.sh` script ONLY extracts modules from assemblies, and saves a modules-per-assembly.txt report in the folder. Use this option if you do want to run Vale manually on individual modules or assemblies.
---

Either option works, but note that if you use the `multi_dir_extract_openshift_modules.sh` script, you must run Vale manually on the assembly and the list of modules returned to generate the list of errors. I think this option is cleaner. 

## Contents

- `extract_modules_with_vale.sh` — extracts and lints all assemblies and modules within that assembly. Returns the *AsciiDocDITA* results in both the terminal and in a .txt file.
- `multi_dir_extract_openshift_modules.sh` - extracts only modules from assemblies and saves them in a modules-per-assembly.txt report. Must use Vale separately.
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

## Using the scripts

1. Clone the repository:

```bash
git clone git@github.com:stevsmit/extract-modules-with-vale.git
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

6. Optional: If you used the `multi_dir_extract_openshift_modules.sh` script, run Vale on the assembly and the modules returned. **Note** Running `vale` without setting an alias only works in the `extract-modules-with-vale` directory. To set an alias, see "Setting an alias for Vale."
```bash
# Run Vale on an assembly file:
vale /home/path/to/openshift-docs/<directory_name><assembly_name>.adoc

# Run Vale on a module:

vale /home/path/to/openshift-docs/modules/<module_name>.adoc
```
Output:
```bash
 about-virtual-routing-and-forwarding.adoc
 1:1  warning  Assign [role="_abstract"]       AsciiDocDITA.ShortDescription 
               to a paragraph to use it as                                   
               <shortdesc> in DITA.                                          
 4:1  warning  Author lines are not supported  AsciiDocDITA.AuthorLine       
               for topics.                                                   

✖ 0 errors, 2 warnings and 0 suggestions in 1 file.
```
---

## Setting an alias for Vale
If you do not set an alias for Vale, you must run the `$ vale` command from within the `extract-modules-with-vale` folder. The following procedure shows you how to set up an alias for Vale so that you can run it from any location.

### Prerequisites

* You have cloned this repository and synced Vale.

### Procedure

1. Change into the directory:

```bash
cd extract-modules-with-vale
```

2. Create an alias that will be used to run the AsciiDocDITA tool against your content. Be sure to replace /path/to/ the actual path to your vale.ini file. You don’t have to use echo here – you can use an IDE, too.
```bash
# On Linux, add the alias to your ~/.bashrc file:
$ echo "alias ditavaleocp='vale --config=/path/to/asciidoctor-dita-vale-directory/vale.ini'" >> ~/.bashrc

# On Mac, add the alias to the last line on the ~/.zshrc file:
$ echo "alias ditavaleocp='vale 
--config=/path/to/asciidoctor-dita-vale-directory/vale.ini'" >> ~/.zshrc
```

3. Reload your configuration by entering the following command:
```bash
# On Linux:
$ source ~/.bashrc

# On Mac:
$ source ~/.zshrc
```

.Verification

1. Verify that the alias works by running it against a module or an assembly in the OpenShift documentation repository. For example:
```bash
$ ditavaleocp ./path/to/openshift/repository/modules/about-virtual-routing-and-forwarding.adoc 
```
Output:
```bash
 about-virtual-routing-and-forwarding.adoc
 1:1  warning  Assign [role="_abstract"]       AsciiDocDITA.ShortDescription 
               to a paragraph to use it as                                   
               <shortdesc> in DITA.                                          
 4:1  warning  Author lines are not supported  AsciiDocDITA.AuthorLine       
               for topics.                                                   

✖ 0 errors, 2 warnings and 0 suggestions in 1 file.
```
