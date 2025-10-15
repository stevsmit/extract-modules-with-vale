# Extract Modules from assemblies

The `multi_dir_extract_openshift_modules.sh` script extracts modules from assemblies, and saves a _MODULES.txt report in the folder. After the _MODULES.txt report has been created in the `extract-modules-with-vale` folder, you can run Vale manually on the assembly and the list of modules returned to generate the list of errors that must be resolved for migration.

---

## Contents

- `multi_dir_extract_openshift_modules.sh` - extracts modules from assemblies and saves them in a _MODULES.txt report.
- `.vale.ini` — Vale configuration with the `asciidoc-dita-vale` tool configuration.
---

## Prerequisites

- **Bash** (Linux/macOS; available by default)
- **Python 3** (if you use any helper tooling — not required for the script itself)
- [**Vale**](https://vale.sh/docs/install) 
- [**Asciidoctor**](https://docs.asciidoctor.org/asciidoctor/latest/install/). For RHEL/Fedora, see [DNF](https://docs.asciidoctor.org/asciidoctor/latest/install/linux-packaging/#dnf)

Check Vale version:

```bash
vale --version
```

Check Asciidoctor version:

```bash
asciidoctor --version
```
---

## Using the scripts

1. Clone the repository. Note that I suggest doing this in the home directory (`~ $`)

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

4. Make the script executable:
```bash
chmod +x multi_dir_extract_openshift_modules.sh
```
5. Run either script. The script accepts either a directory or a single assembly file.

```bash
# Only list modules within an directory:
./multi_dir_extract_openshift_modules.sh /home/path/to/openshift-docs/<directory_name>

# Only list modules with an assembly:
./multi_dir_extract_openshift_modules.sh /home/path/to/openshift-docs/<directory_name>/<assembly_name>.adoc
```
---
**Output:**
```bash
Output directory: etcd_extracted_modules
Found 1 assembly(s).
All assemblies processed successfully.
```

6. Concatenate the file to return the list of modules in your terminal. Or just open it.
```bash
cat <folder_name>/<file_name>.txt
 ```
**Output:**
```bash
• <assembly_name>.adoc
  - '/home/path/to/openshift-docs/modules/<module_name>.adoc'
  - '/home/home/path/to/openshift-docs/modules/<module_name>.adoc'
  - '/home/home/path/to/penshift-docs/modules/<module_name>.adoc'
  - '/home/home/path/to/openshift-docs/modules/<module_name>.adoc'
```

6. Run Vale on the assembly and the modules returned. **Note** Running `vale` without setting an alias only works in the `extract-modules-with-vale` directory. To set an alias, see "Setting an alias for Vale."
```bash
# Run Vale on an assembly file:
vale /home/path/to/openshift-docs/<directory_name><assembly_name>.adoc

# Run Vale on a module:

vale /home/path/to/openshift-docs/modules/<module_name>.adoc
```
**Output:**
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

**Verification**

1. Verify that the alias works by running it against a module or an assembly in the OpenShift documentation repository. For example:
```bash
$ ditavaleocp ./path/to/openshift/repository/modules/about-virtual-routing-and-forwarding.adoc 
```
**Output:**
```bash
 about-virtual-routing-and-forwarding.adoc
 1:1  warning  Assign [role="_abstract"]       AsciiDocDITA.ShortDescription 
               to a paragraph to use it as                                   
               <shortdesc> in DITA.                                          
 4:1  warning  Author lines are not supported  AsciiDocDITA.AuthorLine       
               for topics.                                                   

✖ 0 errors, 2 warnings and 0 suggestions in 1 file.
```
