#!/usr/bin/env bash

SCRIPT_DIR="$(realpath --no-symlinks "$(dirname "${BASH_SOURCE[0]}")")"
BASH_DIR="${SCRIPT_DIR}/../../bash"

# Load the function definition
source "${BASH_DIR}/winewrapper.sh"

# Call the function with all arguments passed from Dolphin
winewrapper "$@"
