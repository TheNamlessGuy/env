show() {
  if [[ $# -eq 0 ]]; then
    cat | tr ' ' '\n'
  else
    echo "$@" | tr ' ' '\n'
  fi
}
