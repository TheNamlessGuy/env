gclean() {
  "$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")/gclean.py" "$@"
}
