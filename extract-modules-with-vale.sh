#!/bin/bash
# extract_modules_with_vale.sh
#
# Recursively finds all AsciiDoc assemblies in a given directory OR processes a single assembly,
# extracts their included modules, and runs Vale lint checks on both the assembly and its modules.
# Results are saved in a per-assembly report file inside an output directory AND shown in the terminal.
#
# Usage:
#   ./extract_modules_with_vale.sh <directory_or_assembly.adoc>

# --- Formatting ---
BOLD="\033[1m"
RESET="\033[0m"

# --- Temporary files ---
TMP_RAW_MODULES="tmp_raw_modules.tmp"
TMP_ASSEMBLY_PATHS="tmp_assembly_paths.tmp"

# --- Argument checks ---
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory_or_assembly.adoc>"
    exit 1
fi

INPUT_PATH="$1"

# --- Determine if input is a directory or a file ---
if [[ -d "$INPUT_PATH" ]]; then
    TARGET_DOCS_DIR="$INPUT_PATH"
    DIR_BASENAME=$(basename "$TARGET_DOCS_DIR")
    OUTPUT_DIR="${DIR_BASENAME}_extracted_modules"
    
    # --- Find assemblies in directory ---
    rm -f "$TMP_ASSEMBLY_PATHS" 2>/dev/null
    find "$TARGET_DOCS_DIR" -type f -name "*.adoc" -print0 | while IFS= read -r -d $'\0' adoc_file; do
        if grep -qE ":_mod-docs-content-type: ASSEMBLY" "$adoc_file"; then
            echo "$adoc_file" >> "$TMP_ASSEMBLY_PATHS"
        fi
    done
elif [[ -f "$INPUT_PATH" ]]; then
    TARGET_DOCS_DIR=$(dirname "$INPUT_PATH")
    DIR_BASENAME=$(basename "$TARGET_DOCS_DIR")
    OUTPUT_DIR="${DIR_BASENAME}_extracted_modules"
    
    # Check if the file is an assembly
    if ! grep -qE ":_mod-docs-content-type: ASSEMBLY" "$INPUT_PATH"; then
        echo "Error: File '$INPUT_PATH' is not marked as an assembly."
        exit 1
    fi
    
    # Use a temporary file to hold the single assembly
    echo "$INPUT_PATH" > "$TMP_ASSEMBLY_PATHS"
else
    echo "Error: '$INPUT_PATH' is not a valid file or directory."
    exit 1
fi

mkdir -p "$OUTPUT_DIR" || { echo "Error creating output dir"; exit 1; }

echo "📂 Processing path: $INPUT_PATH"
echo "🗂️  Output directory: $OUTPUT_DIR"
echo ""

# --- Check if any assemblies found ---
if [[ ! -s "$TMP_ASSEMBLY_PATHS" ]]; then
    echo "No assemblies found in '$INPUT_PATH'."
    rm -f "$TMP_RAW_MODULES" "$TMP_ASSEMBLY_PATHS"
    rmdir "$OUTPUT_DIR" 2>/dev/null
    exit 0
fi

TOTAL_ASSEMBLIES=$(wc -l < "$TMP_ASSEMBLY_PATHS")
echo "✅ Found $TOTAL_ASSEMBLIES assemblies."
echo ""

# --- Process each assembly ---
while IFS= read -r TARGET_FILEPATH; do
    FILE_BASENAME=$(basename "$TARGET_FILEPATH")
    OUTPUT_FILE="$OUTPUT_DIR/${FILE_BASENAME}_MODULES.txt"

    echo "🔧 Processing assembly: $FILE_BASENAME" | tee "$OUTPUT_FILE"

    rm -f "$TMP_RAW_MODULES" 2>/dev/null

    # Extract module includes
    grep -E "include::(.*modules/)" "$TARGET_FILEPATH" > "$TMP_RAW_MODULES"

    echo "--- Module Extraction Results for $FILE_BASENAME ---" | tee -a "$OUTPUT_FILE"

    if [[ ! -s "$TMP_RAW_MODULES" ]]; then
        echo -e "• ${BOLD}${FILE_BASENAME}${RESET} (No modules found)" | tee -a "$OUTPUT_FILE"
    else
        echo -e "• ${BOLD}${FILE_BASENAME}${RESET}" | tee -a "$OUTPUT_FILE"
        sed -E 's/.*include::modules\/(.*?)\[.*$/\1/' "$TMP_RAW_MODULES" | \
        sort | uniq | sed '/^$/d' | \
        sed "s/^/  - ${BOLD}/" | sed "s/$/${RESET}/" | tee -a "$OUTPUT_FILE"
    fi

    echo "" | tee -a "$OUTPUT_FILE"

    # --- Run Vale on the assembly ---
    echo "🔍 Vale lint results for assembly (${BOLD}${FILE_BASENAME}${RESET}):" | tee -a "$OUTPUT_FILE"
    echo "---------------------------------------------" | tee -a "$OUTPUT_FILE"

    vale_output=$(vale --minAlertLevel=warning --config=vale.ini "$TARGET_FILEPATH" 2>/dev/null)

    if [[ -z "$vale_output" ]]; then
        echo "No Vale issues found." | tee -a "$OUTPUT_FILE"
    else
        echo "$vale_output" | tee -a "$OUTPUT_FILE"
    fi

    echo "" | tee -a "$OUTPUT_FILE"

    # --- Run Vale on each included module ---
    if [[ -s "$TMP_RAW_MODULES" ]]; then
        echo "🔍 Vale lint results for included modules:" | tee -a "$OUTPUT_FILE"
        echo "---------------------------------------------" | tee -a "$OUTPUT_FILE"

        while IFS= read -r module; do
            module_clean=$(echo "$module" | sed -E 's/.*include::modules\/(.*?)\[.*$/\1/')
            module_path="$TARGET_DOCS_DIR/modules/$module_clean"

            if [[ -f "$module_path" ]]; then
                vale_result=$(vale --minAlertLevel=warning --config=vale.ini "$module_path" 2>/dev/null)
                if [[ -n "$vale_result" ]]; then
                    echo -e "⚠️  ${BOLD}${module_clean}${RESET}:" | tee -a "$OUTPUT_FILE"
                    echo "$vale_result" | tee -a "$OUTPUT_FILE"
                    echo "" | tee -a "$OUTPUT_FILE"
                else
                    echo -e "✅ ${BOLD}${module_clean}${RESET}: No Vale issues found." | tee -a "$OUTPUT_FILE"
                fi
            else
                echo -e "❌ ${BOLD}${module_clean}${RESET}: File not found at $module_path" | tee -a "$OUTPUT_FILE"
            fi
        done < "$TMP_RAW_MODULES"
    fi

    echo "" | tee -a "$OUTPUT_FILE"
    echo "✅ Processed $FILE_BASENAME" | tee -a "$OUTPUT_FILE"
    echo "" | tee -a "$OUTPUT_FILE"

    rm -f "$TMP_RAW_MODULES" 2>/dev/null
done < "$TMP_ASSEMBLY_PATHS"

rm -f "$TMP_ASSEMBLY_PATHS" 2>/dev/null
echo "🎉 All assemblies processed successfully." | tee -a "$OUTPUT_FILE"
echo "Reports available in: $OUTPUT_DIR" | tee -a "$OUTPUT_FILE"
