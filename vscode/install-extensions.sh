#!/bin/bash

install-extensions() {
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
  local ext=""
  while read ext; do
    "${bin}" --install-extension "${ext}" --force
  done < "${here}/extensions.txt"
}

install-extensions $@
