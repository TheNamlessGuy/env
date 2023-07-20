gits() {
  local arr=("$@")
  local i=""
  local s=""

  for ((i = 0; i < "${#arr[@]}"; ++i)); do
    if [[ "${arr[$i]}" == "--s" ]]; then
      unset "arr[$i]"
      s="-"
    fi
  done

  if [[ -z "${s}" ]]; then
    "$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")/gits.py" "${arr[@]}"
  else
    git status "${arr[@]}"
  fi
}