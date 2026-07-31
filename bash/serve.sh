serve() {
  local port=""
  local dir=""

  while (($# > 0)); do
    if [[ "$1" == "--port" || "$1" == "-p" ]]; then
      shift
      port="$1"
    elif [[ "$1" == "-"* ]]; then
      echo >&2 "Unknown flag '$1'"
      return 1
    elif [[ -z "${dir}" ]]; then
      dir="$1"
    else
      echo >&2 "Unknown value '$1'"
      return 1
    fi

    shift
  done

  if [[ -z "${dir}" ]]; then
    echo >&2 "No directory specified"
    return 1
  fi

  dir="$(realpath --no-symlinks "${dir}")"
  if [[ ! -d "${dir}" ]]; then
    echo >&2 "'${dir}' isn't a directory"
    return 1
  fi

  if [[ -z "${port}" ]]; then
    port="8080"
  fi

  set-title "Serving '${dir}'"

  echo "Serving: ${dir}"
  echo "Open:    http://localhost:${port}/"
  echo "Stop:    Ctrl-C"
  echo "============================"

  python3 -m http.server "${port}" \
    --bind 127.0.0.1 \
    --directory "${dir}"
}
