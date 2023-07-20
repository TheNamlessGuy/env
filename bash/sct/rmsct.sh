rmsct() {
  local var=""
  local FORCE=""

  while (($# > 0)); do
    if [[ "$1" == "--force" || "$1" == "-f" ]]; then
      FORCE="-"
    else
      var="$1"
    fi

    shift
  done

  if [[ -z "${var}" ]]; then
    echo >&2 "No shortcut name given"
    return 1
  fi

  if [[ "${var}" == */* ]]; then
    echo >&2 "Invalid variable name '${var}'"
    return 1
  fi

  if [[ ! -L "${SCT_LOCATION}/${var}" ]]; then
    echo >&2 "Shortcut '${var}' does not exist"
    return 1
  fi

  if [[ -z "${FORCE}" ]]; then
    local response=""
    read -r -p "Delete shortcut '${var}'? [Y/n] " response
    if [[ "${response}" == *"n"* || "${response}" == *"N"* ]]; then
      return 0
    fi
  fi

  \rm -f "${SCT_LOCATION}/${var}"
}

_comp_rmsct() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local options="$(lssct --name-only)"

  if [[ "${cur}" != "-"* ]]; then
    COMPREPLY+=($(compgen -W "${options}" -- "${cur}"))
  fi
}
complete -F _comp_rmsct rmsct