gb() {
  local arr=("$@")
  [[ -z "${arr}" ]] && arr+=("-vv")
  git branch "${arr[@]}"
}

_comp_gb() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local branches="$(git branch | awk -F ' +' '! /\(no branch\)/ {print $2}')"
  COMPREPLY=($(compgen -W "${branches}" -- "${cur}"))
}
complete -F _comp_gb gb