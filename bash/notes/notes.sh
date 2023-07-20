: "${NOTES_LOCATION:=$(readlink -f "$(dirname ${BASH_SOURCE[0]})")/.notes}"

notes() {
  local name=""
  local action="edit"
  local mv=""

  while (($# > 0)); do
    if [[ "$1" == "-l" ]]; then
      action="list"
    elif [[ "$1" == "-rm" ]]; then
      action="rm"
    elif [[ "$1" == "-mv" ]]; then
      action="mv"
      shift
      mv="${NOTES_LOCATION}/$1"
    elif [[ "$1" == "-h" || "$1" == "-help" || "$1" == "--help" ]]; then
      echo "Notes
===========
Take notes

Usage:
  notes (<flags>) (<name>)
  If no flags or name is specified, notes will generate a tmp-file for you
Flags:
  -l                           List all notes
  -rm <name>                   Remove the given note
  -mv <old name> <new name>    Rename the given node to the new name
  -h, -help, --help            Display this message" | less
      return 0
    else
      name="$1"
    fi

    shift
  done

  if [[ "${action}" == "list" ]]; then
    find "${NOTES_LOCATION}" -type f -printf '%P\n'
    return 0
  fi

  if [[ ! -d "${NOTES_LOCATION}" ]]; then
    mkdir -p "${NOTES_LOCATION}"
  fi

  if [[ -z "${name}" ]]; then
    if [[ ! -d "${NOTES_LOCATION}/tmp" ]]; then
      mkdir "${NOTES_LOCATION}/tmp"
    fi

    name="tmp/${RANDOM}"
    while [[ -f "${NOTES_LOCATION}/${name}" ]]; do
      name="tmp/${RANDOM}"
    done
  elif [[ "${name}" == "tmp" ]]; then
    echo >&2 "Cannot name a note 'tmp'"
    return 1
  fi

  local path="${NOTES_LOCATION}/${name}"

  if [[ "${action}" == "rm" ]]; then
    \rm -i "${path}"
  elif [[ "${action}" == "mv" ]]; then
    \mv -i "${mv}" "${path}"
  elif [[ "${action}" == "edit" ]]; then
    "${EDITOR}" "${path}"
    echo "Note location: ${path}"
  fi
}

_comp_notes() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local options="$(notes -l)"
  options="${options}"$'\n'"-l"
  options="${options}"$'\n'"-rm"
  options="${options}"$'\n'"-mv"

  COMPREPLY+=($(compgen -W "${options}" -- "${cur}"))
  return 0
}
complete -F _comp_notes notes