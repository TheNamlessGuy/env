spread() {
  local line=""
  while IFS=$'\n' read -r line; do
    echo "${line}"
    echo
  done
}