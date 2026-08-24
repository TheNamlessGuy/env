vscode() {
  if [[ ! -x "${VSCODE_BINARY_LOCATION}" ]]; then
    echo >&2 "'\$VSCODE_BINARY_LOCATION' ('${VSCODE_BINARY_LOCATION}') does not point to an executable file"
    return 1
  fi

  if [[ $# -eq 0 ]]; then
    "${VSCODE_BINARY_LOCATION}" . &> /dev/null & disown
    return 0
  fi

  local root="$1"
  shift

  if [[ -f "${root}" ]]; then
    local file="${root}"
    root="$(dirname "${root}")"
    "${VSCODE_BINARY_LOCATION}" "${root}" "${file}" "$@" &> /dev/null & disown
  else
    "${VSCODE_BINARY_LOCATION}" "${root}" "$@" &> /dev/null & disown
  fi
}
