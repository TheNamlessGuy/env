#!/usr/bin/env bash

# Installs arkenfox to the specified profile(s)

set -euo pipefail

DIR="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")"
PROFILES_DIR="$(readlink -f "${DIR}/..")/profiles"

BASELINE="${DIR}/files/user.js"
OVERRIDES="${DIR}/user-overrides.js"
CLEANER="${DIR}/files/prefsCleaner.sh"

resolve_profiles() {
  if [[ -z "$1" ]]; then
    echo >&2 "Usage: $0 <profile-name|--all>"
    exit 1
  fi

  if [[ "$1" == "--all" ]]; then
    find "${PROFILES_DIR}" -mindepth 1 -maxdepth 1 -type d
  else
    local profile="${PROFILES_DIR}/$1"

    if [[ ! -d "${profile}" ]]; then
      echo "Profile not found: $1" >&2
      exit 1
    fi

    echo "${profile}"
  fi
}

[[ ! -f "${BASELINE}" ]] && { echo "Missing '${BASELINE}'"; exit 1; }
[[ ! -f "${OVERRIDES}" ]] && { echo "Missing '${OVERRIDES}'"; exit 1; }
[[ ! -f "${CLEANER}" ]] && { echo "Missing '${CLEANER}'"; exit 1; }

while IFS= read -r profile; do
  name="$(basename "${profile}")"
  echo "Installing arkenfox into profile: '${name}' (${profile})"

  cat "${BASELINE}" > "${profile}/user.js"
  printf '\n\n/*** === USER OVERRIDES BELOW === ***/\n\n' >> "${profile}/user.js"
  cat "${OVERRIDES}" >> "${profile}/user.js"

  cp "${CLEANER}" "${profile}/prefsCleaner.sh"
  chmod +x "${profile}/prefsCleaner.sh"
done < <(resolve_profiles "${1:-}")
