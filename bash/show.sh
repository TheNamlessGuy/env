show() {
  if [[ -z "$@" ]]; then
    cat | tr ' ' '\n'
  else
    echo "$@" | tr ' ' '\n'
  fi
}