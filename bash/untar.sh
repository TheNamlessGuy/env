untar() {
  local file="$1"
  local to="$2"

  if [[ ! -f "${file}" ]]; then
    echo >&2 "Couldn't find '${file}'"
    return
  fi

  if [[ -z "${to}" ]]; then
    to="$(basename "${file}")"
    to="${to%.tar.gz}"
  fi

  if [[ -e "${to}" ]]; then
    echo >&2 "'${to}' already exists"
    return
  fi

  mkdir -p "${to}"
  tar -xzf "${file}" --directory "${to}"
}
