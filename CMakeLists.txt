cmake_minimum_required(VERSION 3.15)
project(example
  LANGUAGES CXX
  VERSION 1.0
)

add_subdirectory(dependencies)
add_subdirectory(src)

# --- CMake fragment to generate populate.sh ---

# 1. Get the list of all files currently tracked by Git.
# This command runs at CMake configuration time.
# It captures all files that Git knows about in the current repository.
execute_process(
    COMMAND git ls-files
    # Ensure git operates from the root of the current CMakeLists.txt's directory
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    # Store the output (newline-separated file paths) in GIT_TRACKED_FILES variable
    OUTPUT_VARIABLE GIT_TRACKED_FILES
    # Remove any trailing newline characters from the output
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# 2. Convert the newline-separated list from git to a CMake-friendly list (semicolon-separated).
# This is crucial for CMake's DEPENDS argument.
# First, escape any literal semicolons that might exist in file paths with a backslash.
string(REPLACE ";" "\\;" GIT_TRACKED_FILES "${GIT_TRACKED_FILES}")
# Then, replace newlines with semicolons.
string(REPLACE "\n" ";" GIT_TRACKED_FILES "${GIT_TRACKED_FILES}")

# 3. Define the custom target for 'populate.sh'.
# This target represents the action of generating the populate.sh script.
add_custom_target(
    populate.sh # The name of the target you can invoke (e.g., 'make populate.sh')
    ALL         # Make this target part of the default build (so 'make' alone builds it)

    # The command to execute to build this target.
    # It runs your 'generate_populate_script.sh' script.
    # We use CMAKE_CURRENT_SOURCE_DIR to ensure the path is correct regardless of where
    # this CMakeLists.txt is included from (assuming generate_populate_script.sh is in the same dir).
    COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/generate_populate_script.sh"

    # Define the dependencies for this target.
    # If any of these files change, the 'populate.sh' target will be rebuilt.
    DEPENDS
        # 1. The script that does the generation itself. If generate_populate_script.sh changes,
        #    populate.sh should be regenerated.
        "${CMAKE_CURRENT_SOURCE_DIR}/generate_populate_script.sh"
        # 2. All files tracked by Git. If any of these change, populate.sh needs updating.
        ${GIT_TRACKED_FILES}

    # An optional comment that will be displayed by the build system when this target is built.
    COMMENT "Generating populate.sh script based on repository content changes."
)

# --- End of CMake fragment ---
