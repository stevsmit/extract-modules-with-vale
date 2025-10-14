#!/bin/bash
# multi_dir_extract_openshift_modules.sh
# Finds all assemblies in a specified directory (recursively) OR processes
# a single assembly file, and saves a separate, formatted _MODULES.txt file
# for each assembly inside a new directory. Outputs full absolute paths for both
# assemblies and their included modules.

# --- Temporary files ---
TMP_RAW_MODULES="tmp_raw_modules.tmp"
TMP_ASSEMBLY_PATHS="tmp_assembly_paths.tmp"

# --- Argument check ---
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <target_directory_or_assembly.adoc>"
    exit 1
fi

INPUT_PATH="$1"

# --- Determine if input is a directory or a file ---
if [[ -d "$INPUT_PATH" ]]; then
    # Directory case: find all assembly .adoc files recursively
    find "$INPUT_PATH" -type f -name "*.adoc" -print0 | while IFS= read -r -d $'\0' adoc_file; do
        if grep -qE ":_mod-docs-content-type: ASSEMBLY" "$adoc_file"; then
            echo "$adoc_file" >> "$TMP_ASSEMBLY_PATHS"
        fi
    done
    OUTPUT_DIR="$(basename "$INPUT_PATH")_extracted_modules"
elif [[ -f "$INPUT_PATH" && "$INPUT_PATH" == *.adoc ]]; then
    # Single assembly file
    if ! grep -qE ":_mod-docs-content-type: ASSEMBLY" "$INPUT_PATH"; then
        echo "Error: The file '$INPUT_PATH' is not marked as an ASSEMBLY."
        exit 1
    fi
    echo "$INPUT_PATH" > "$TMP_ASSEMBLY_PATHS"
    # Output directory based on the parent directory of the file
    OUTPUT_DIR="$(basename "$(dirname "$INPUT_PATH")")_extracted_modules"
else
    echo "Error: '$INPUT_PATH' is not a valid directory or .adoc assembly file."
    exit 1
fi

# --- Create output directory ---
mkdir -p "$OUTPUT_DIR" || {
    echo "Error: Could not create output directory '$OUTPUT_DIR'."
    exit 1
}

echo "Output directory: $OUTPUT_DIR"

# --- Process assemblies ---
TOTAL_ASSEMBLIES=$(wc -l < "$TMP_ASSEMBLY_PATHS")
echo "Found $TOTAL_ASSEMBLIES assembly(s)."

while IFS= read -r TARGET_FILEPATH; do
    FILE_BASENAME=$(basename "$TARGET_FILEPATH")
    OUTPUT_FILE="$OUTPUT_DIR/${FILE_BASENAME}_MODULES.txt"
    rm -f "$TMP_RAW_MODULES" &>/dev/null

    grep -E "include::modules/" "$TARGET_FILEPATH" >> "$TMP_RAW_MODULES"

    echo "--- Module Extraction Results for $FILE_BASENAME ---" > "$OUTPUT_FILE"

    if [[ ! -s "$TMP_RAW_MODULES" ]]; then
        echo "• $FILE_BASENAME (No modules found)" >> "$OUTPUT_FILE"
        rm -f "$TMP_RAW_MODULES" &>/dev/null
        continue
    fi

    # --- New: Print full assembly path ---
    echo "• Assembly:" >> "$OUTPUT_FILE"
    echo "  - '$(realpath "$TARGET_FILEPATH")'" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    # --- Then print the module paths ---
    echo "• Modules:" >> "$OUTPUT_FILE"

    sed -E 's/.*include::modules\/(.*?)\[.*$/\1/' "$TMP_RAW_MODULES" | \
    sed -E 's/.*include::modules\/(.*)/\1/' | \
    sort | uniq | sed '/^$/d' | while read -r module_name; do
        # Resolve full path to module relative to assembly
        full_path="$(realpath "$(dirname "$TARGET_FILEPATH")/../modules/$module_name" 2>/dev/null)"
        if [[ -f "$full_path" ]]; then
            echo "  - '$full_path'" >> "$OUTPUT_FILE"
        else
            echo "  - (missing) $(dirname "$TARGET_FILEPATH")/../modules/$module_name" >> "$OUTPUT_FILE"
        fi
    done

    echo "" >> "$OUTPUT_FILE"
    rm -f "$TMP_RAW_MODULES" &>/dev/null
done < "$TMP_ASSEMBLY_PATHS"

echo "All assemblies processed successfully."
rm -f "$TMP_ASSEMBLY_PATHS" &>/dev/null
