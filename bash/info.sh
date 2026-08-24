info() {
  echo "WHICH"
  echo "###############################"
  local tmp="$(which "$@" 2>&1)"
  [[ "${tmp}" != "which: no $@ in"* ]] && echo "${tmp}" || echo "Nothing found"

  echo

  echo "TYPE"
  echo "###############################"
  type "$@"
}