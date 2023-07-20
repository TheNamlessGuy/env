cclear() {
  clear

  if [[ -n "${CCLEAR_REMINDER}" ]]; then
    reminder list
    if [[ "$?" == "0" ]]; then
      echo
      echo "================="
      echo
    fi
  fi

  ls -lAh
}

alias c="cclear"