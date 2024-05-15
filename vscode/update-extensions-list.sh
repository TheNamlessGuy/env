#!/bin/bash

update-extensions-list() {
  local bin="$1"
  if [[ -z "${bin}" ]]; then
    if [[ ! -z "${VSCODE_BINARY_LOCATION}" ]]; then
      bin="${VSCODE_BINARY_LOCATION}"
    else
      read -p 'VSCode binary location: ' bin
    fi
  fi

  if [[ ! -f "${bin}" ]]; then
    echo >&2 "Binary '${bin}' does not exist"
    exit 1
  fi

  local here="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
  "${bin}" --list-extensions --show-versions > "${here}/extensions.txt"
}

update-extensions-list $@