#!/usr/bin/env bash

# Runs the cleaner script in the specified profile(s)

set -euo pipefail

DIR="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")"
PROFILES_DIR="$(readlink -f "${DIR}/..")/profiles"

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

echo "Firefox should be fully closed before cleaning prefs."
read -r -p "Continue? [y/N] " answer
case "$answer" in
  y|Y|yes|YES) ;;
  *) echo "Aborting..."; exit 1 ;;
esac

while IFS= read -r profile; do
  name="$(basename "${profile}")"
  cleaner="${profile}/prefsCleaner.sh"

  if [[ ! -x "${cleaner}" ]]; then
    echo "Skipping ${name}: prefsCleaner.sh not found or not executable"
    continue
  fi

  echo "Cleaning profile: '${name}' (${profile})"
  "${cleaner}" -s
done < <(resolve_profiles "${1:-}")
