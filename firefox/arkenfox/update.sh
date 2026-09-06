#!/usr/bin/env bash

# Updates the arkenfox files by pulling the latest version

set -euo pipefail

DIR="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")"
BASE_URL="https://raw.githubusercontent.com/arkenfox/user.js/master"

curl -fsSL "${BASE_URL}/user.js" -o "${DIR}/files/user.js"
curl -fsSL "${BASE_URL}/prefsCleaner.sh" -o "${DIR}/files/prefsCleaner.sh"

chmod +x "${DIR}/files/prefsCleaner.sh"
