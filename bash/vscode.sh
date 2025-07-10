vscode() {
  if [[ ! -f "${VSCODE_BINARY_LOCATION}" ]]; then
    echo >&2 "'\$VSCODE_BINARY_LOCATION' does not point to a file (value: '${VSCODE_BINARY_LOCATION}')"
    return 1
  fi

  local wd="$1"
  [[ -z "${wd}" ]] && wd="."
  [[ -f "${wd}" ]] && wd="$(dirname "${wd}")"

  "${VSCODE_BINARY_LOCATION}" "${wd}" &> /dev/null & disown
}
