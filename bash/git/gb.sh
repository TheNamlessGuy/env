gb() {
  if [[ -z "$@" ]]; then
    "$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")/gb.py"
  else
     git branch $@
  fi
}

_comp_gb() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local branches="$(git branch | awk -F ' +' '! /\(no branch\)/ {print $2}')"
  COMPREPLY=($(compgen -W "${branches}" -- "${cur}"))
}
complete -F _comp_gb gb