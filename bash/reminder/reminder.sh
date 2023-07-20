reminder() {
  local dir="$(dirname "${BASH_SOURCE[0]}")"
  "${dir}/reminder.py" $@
  return $?
}