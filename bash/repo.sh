if [[ -z "${REPO_SOURCE_FILES}" ]]; then
  REPO_SOURCE_FILES=("env.sh")
fi

repo() {
  local NO_SOURCE=""
  local NO_SCREEN_CLEAR=""
  local repo=""

  while (($# > 0)); do
    if [[ "$1" == "-"* ]]; then
      local flag="$1"
      flag="${flag:1}"
      local i=""

      for i in $(seq 1 ${#flag}); do
        local c="${flag:i-1:1}"
        if [[ "${c}" == "s" ]]; then
          NO_SOURCE="-"
        elif [[ "${c}" == "r" ]]; then
          NO_SCREEN_CLEAR="-"
        else
          echo >&2 "Unknown flag '-${c}'"
          return 1
        fi
      done
    else
      repo="$1"
    fi

    shift
  done

  if [[ -z "${repo}" || "${repo}" == "." ]]; then
    repo="${PWD}"
  else
    cd "${repo}" &> /dev/null
    if [[ "$?" != "0" ]]; then
      echo >&2 "Couldn't find '${repo}'"
      return 1
    fi
  fi

  set-title --cur

  local file=""
  if [[ -z "${NO_SOURCE}" ]]; then
    local f=""
    for f in "${REPO_SOURCE_FILES[@]}"; do
      if [[ -f "${f}" ]]; then
        file="${f}"
        break
      fi
    done
  fi

  if [[ -n "${file}" ]]; then
    echo "Sourcing '${file}'..."
    source "${file}"
  fi

  if [[ -z "${NO_SCREEN_CLEAR}" ]]; then
    cclear
  fi
}

_comp_repo() {
  local cur="${COMP_WORDS[COMP_CWORD]}";
  local dir="$(echo "${REPO}/${cur}" | sed 's#/[^/]*$#/#')"
  local base="$(echo "${REPO}/${cur}" | awk '{print $NF}' FS=/)"
  local sct="$(lssct --name-only)"

  COMPREPLY=($(compgen -d -- "${dir}${base}" | sed -e "s#${REPO}/##g" -e 's#$#/#g'))
  COMPREPLY+=($(compgen -W "${sct}" -- "${cur}"))
}
complete -o nospace -F _comp_repo repo