set-clipboard() {
  local content="$1"
  if [[ "${content}" == "-f" ]]; then
    content="$(cat "$2")"
  fi

  echo -n "${content}" | xclip -selection c
}