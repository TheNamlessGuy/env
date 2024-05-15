#!/bin/bash

symlink-data() {
  local dir="$"
  if [[ -z "${dir}" ]]; then
    if [[ ! -z "${VSCODE_BINARY_LOCATION}" ]]; then
      # On linux, the binary is located somewhere like <INSTALL DIR>/bin/code
      dir="$(dirname "$(dirname "${VSCODE_BINARY_LOCATION}")")"
    else
      read -p 'VSCode install dir: ' dir

      if [[ ! -f "${dir}/bin/code" ]]; then
        echo >&2 "'${dir}' does not seem to be a VSCode install directory"
        exit 1
      fi
    fi
  fi

  if [[ ! -d "${dir}" ]]; then
    echo >&2 "Directory '${dir}' does not exist"
    exit 1
  fi

  if [[ -e "${dir}/data" ]]; then
    echo >&2 "'data' directory already exists in '${dir}'. Remove it to continue"
    exit 1
  fi

  local here="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
  ln -s "${here}/data" "${dir}/data"
  if [[ "$?" == "0" ]]; then
    echo "Successfully symlinked '${here}/data' to '${dir}/data'"
  else
    exit 1
  fi
}

symlink-data $@
