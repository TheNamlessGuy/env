ptt() {
  if [[ -t 0 ]]; then
    echo "No piped data found"
  else
    echo "$(cat)"
  fi
}