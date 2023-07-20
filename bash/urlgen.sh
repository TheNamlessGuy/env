urlgen() {
  local url="$@"
  if [[ -z "${url}" ]]; then
    echo "No URL given"
    return 1
  fi

  local file="website.url"
  local i=0
  while [[ -f "${file}" ]]; do
    ((i++))
    file="website-${i}.url"
  done

  echo "[InternetShortcut]
URL="${url}"" > "${file}"
}