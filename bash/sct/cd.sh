if [[ -z "${SCT_LOCATION}" ]]; then
  SCT_LOCATION="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")/.sct"
fi

cd() {
  local dest="$@"
  if [[ -z "${dest}" ]]; then
    dest="${HOME}"
  elif [[ "${dest}" == "--" ]]; then
    popd &> /dev/null
    return $?
  elif [[ ! -d "${dest}" && "${dest}" != "-" ]]; then
    [[ "${dest}" == ":"* ]] && dest="${dest/:/}"

    local cont=""
    if [[ "${dest}" == *"/"* ]]; then
      cont="$(echo "${dest}" | sed 's#^[^/]*/#/#')"
      dest="${dest%$cont}"
    fi

    dest="$(lssct -p "${dest}")"
    if [[ -z "${dest}" ]]; then
      dest="$@"
    else
      dest="${dest#*|}${cont}"
    fi
  fi

  [[ "${dest}" != '-' ]] && dest="$(readlink -f "${dest}")"
  pushd "${dest}" > /dev/null
}

_comp_cd() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local sct="$(printf '%s\n' "$cur" | sed -e 's#/#\n#g' | head -1)"
  local rest="${cur#"${sct}"}"
  [[ -z "${rest}" ]] && rest="/"

  if [[ ! -z "${sct}" && ! -d "${sct}" && -n "$(lssct "${sct}")" ]]; then
    cur="$(lssct --path-only "${sct}")${rest}"
  fi

  if [[ "${cur}" != "-"* ]]; then
    COMPREPLY=()

    # Directories
    {
      local IFS=$'\n'
      local dirs=($(compgen -d -- "${cur}"))
      local d
      for d in "${dirs[@]}"; do
        COMPREPLY+=("${d}/")
      done
    }

    # Shortcuts
    {
      local names="$(lssct --name-only || printf '')"
      if [[ -n "${names}" ]]; then
        local IFS=$'\n'
        COMPREPLY+=($(compgen -W "${names}" -- "${cur}"))
      fi
    }
  fi
}
complete -o nospace -F _comp_cd cd
