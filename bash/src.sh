src() {
  if [[ -z "$@" ]]; then
    source ~/.bashrc
  else
    source ~/.bashrc > /dev/null
  fi
}