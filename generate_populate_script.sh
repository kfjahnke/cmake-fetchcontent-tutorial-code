#!/bin/bash

# Get the absolute path to the directory where this script resides.
# This ensures we are always operating from the Git repository root.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Change the current working directory to the script's directory (the repo root).
cd "${SCRIPT_DIR}" || { echo "Error: Could not change to script directory: ${SCRIPT_DIR}"; exit 1; }

echo "--- Starting populate.sh generation ---"
echo "Operating from Git repository root: ${PWD}"

# --- 1. Pre-checks (now operating from repo root) ---
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed. Please install git to use this script."
    exit 1
fi
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "Error: Not inside a Git repository. Please run this this generation script from the root of a Git repository."
    exit 1
fi

# --- 2. Define the 'filify' function ---
# This function emits Bash code to create a file with specified content.
# It assumes the destination file path is the same as the source file path.
# $1: File path (both source of content and destination for creation)
filify() {
    local file_path="$1" # Renamed for clarity, now serves as both source and dest
    
    # Generate a unique end-of-file marker using dbus-uuidgen.
    # This is highly portable on Linux systems and produces a hyphen-less UUID.
    local eof_marker=$(dbus-uuidgen)

    # Validate that the source file exists
    if [[ ! -f "$file_path" ]]; then
        echo "Error: File '$file_path' not found or is not a regular file during filify call." >&2
        return 1
    fi

    # Emit the Bash code snippet:
    # First, ensure the directory for the file_path exists.
    echo "mkdir -p \"$(dirname "${file_path}")\""
    
    # Then, emit the cat << 'MARKER' > "file" block.
    echo "cat << '${eof_marker}' > \"${file_path}\""
    
    # Read content from the source file
    cat "$file_path"
    
    # Ensure a newline character is always present after the file content.
    echo "" 
    
    # Emit the unique marker to terminate the here-document.
    echo "${eof_marker}"
}

# --- 3. Generate 'populate.sh' (now created in the repo root) ---
echo "Generating 'populate.sh'..."

# Start by putting the shebang into populate.sh
echo "#!/bin/bash" > populate.sh
echo "" >> populate.sh # Add an empty line for readability

# Process each file tracked by Git
git ls-files | while IFS= read -r file; do
    # Skip populating the populate.sh script itself if it exists in the git index
    if [[ "$file" != "populate.sh" ]]; then
        filify "$file" >> populate.sh
    fi
done

# --- 4. Make 'populate.sh' executable (now in the repo root) ---
chmod +x populate.sh

echo "Script 'populate.sh' generated successfully in ${PWD}."
echo "You can now run './populate.sh' to recreate the git-tracked files in a new location."
echo "Example: mkdir new_repo && cd new_repo && ../populate.sh"
echo "--- populate.sh generation complete ---"

