lssct() {
  if [[ ! -d "${SCT_LOCATION}" || ! "$(ls -A "${SCT_LOCATION}")" ]]; then
    return
  fi

  local NAME_ONLY=""
  local PATH_ONLY=""
  local var=""

  while (($# > 0)); do
    if [[ "$1" == "--name-only" || "$1" == "-n" ]]; then
      NAME_ONLY="-"
    elif [[ "$1" == "--path-only" || "$1" == "-p" ]]; then
      PATH_ONLY="-"
    else
      var="$1"
    fi

    shift
  done

  local toprint=""
  local d=""
  for d in "${SCT_LOCATION}/"*; do
    local name="$(basename "${d}")"
    local path="$(readlink -fn "${d}")"
    [[ -n "${var}" && "${var}" != "${name}" ]] && continue

    if [[ -n "${NAME_ONLY}" ]]; then
      toprint="${toprint}${name}"$'\n'
    elif [[ -n "${PATH_ONLY}" ]]; then
      toprint="${toprint}${path}"$'\n'
    else
      toprint="${toprint}${name}|->|${path}\n"
    fi
  done

  [[ "${toprint}" == "" ]] && return

  [[ -z "${NAME_ONLY}" && -z "${PATH_ONLY}" ]] && toprint="$(printf "${toprint}" | column -t -s'|')"$'\n'
  echo -n "${toprint}"
}

_comp_lssct() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local options="$(lssct --name-only)"

  if [[ "${cur}" != "-"* ]]; then
    COMPREPLY+=($(compgen -W "${options}" -- "${cur}"))
  fi
}
complete -F _comp_lssct lssct