#!/bin/bash

get-data() {
  local dir="$1"
  local here="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

  if [[ -z "${dir}" ]]; then
    if [[ -f "${here}/install-dir.txt" ]]; then
      dir="$(cat "${here}/install-dir.txt")"
    else
      read -p "VLC config directory: " dir
    fi
  fi

  if [[ ! -d "${dir}" ]]; then
    echo >&2 "'${dir}' does not seem to exist"
    exit 1
  fi

  if [[ ! -f "${dir}/vlcrc" ]]; then
    echo >&2 "'${dir}' does not seem to be a VLC config directory"
    exit 1
  fi

  if [[ ! -f "${here}/install-dir.txt" ]]; then
    echo "${dir}" > "${here}/install-dir.txt"
  fi

  cp "${dir}/vlcrc" "${here}/vlcrc"
  if [[ "$?" != "0" ]]; then
    echo >&2 "Failed to copy 'vlcrc'"
    exit 1
  fi

  cp "${dir}/vlc-qt-interface.conf" "${here}/vlc-qt-interface.ini"
  if [[ "$?" != "0" ]]; then
    echo >&2 "Failed to copy 'vlc-qt-interface.ini'"
    exit 1
  fi
}

get-data $@
