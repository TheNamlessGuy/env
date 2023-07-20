svsct() {
  local var=""
  local path=""
  local FORCE=""

  while (($# > 0)); do
    if [[ "$1" == "--force" || "$1" == "-f" ]]; then
      FORCE="-"
    elif [[ -z "${var}" ]]; then
      var="$1"
    elif [[ -z "${path}" ]]; then
      path="$1"
    fi

    shift
  done

  if [[ -z "${var}" ]]; then
    echo >&2 "No shortcut name given"
    return 1
  elif [[ "${var}" == *"|"* || "${var}" == *"/"* ]]; then
    echo >&2 "Shortcut name cannot contain '|' nor '/'"
    return 1
  fi

  [[ -z "${path}" ]] && path="${PWD}"

  if [[ -z "${FORCE}" && -e "${SCT_LOCATION}/${var}" ]]; then
    local response=""
    read -r -p "Overwrite shortcut '${var}'? [Y/n] " response
    if [[ "${response}" == *"n"* || "${response}" == *"N"* ]]; then
      return 0
    fi
  fi

  if [[ ! -d "${SCT_LOCATION}" ]]; then
    mkdir -p "${SCT_LOCATION}"
  fi

  rmsct "${var}" -f &> /dev/null
  ln -s "${path}" "${SCT_LOCATION}/${var}"
}