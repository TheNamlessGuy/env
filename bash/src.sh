src() {
  if [[ $# -eq 0 ]]; then
    source ~/.bashrc
  else
    source ~/.bashrc > /dev/null
  fi
}
