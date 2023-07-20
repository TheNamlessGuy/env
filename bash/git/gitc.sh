gitc() {
  git checkout $@
}

_comp_gitc() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local branches="$(git branch | awk -F ' +' '! /\(no branch\)/ {print $2}')"
  COMPREPLY=($(compgen -W "${branches}" -- "${cur}"))
  COMPREPLY+=($(compgen -d -- "${cur}"))
  COMPREPLY+=($(compgen -f -- "${cur}"))
}
complete -o nospace -F _comp_gitc gitc
