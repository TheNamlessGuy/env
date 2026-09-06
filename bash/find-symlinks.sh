find-symlinks() {
  if [[ $# -lt 1 ]]; then
    echo >&2 "No path given"
    return 1
  fi

  local path="$(realpath "$1")" || {
    echo >&2 "Failed to read path"
    return 1
  }

  local root="/"
  if [[ $# -gt 1 ]]; then
    root="$(realpath "$2")" || {
      echo >&2 "Failed to read root"
      return 1
    }
  fi

  local found=""
  local failed=0
  local link=""
  while IFS= read -r link; do
    local target="$(realpath "${link}" 2>/dev/null)" || {
      ((failed += 1))
      continue
    }

    if [[ "${target}" == "${path}" ]]; then
      echo "${link}"
      found="-"
    fi
  done < <(find "${root}" -type l 2>/dev/null)

  if ((failed > 0)); then
    if [[ -n "${found}" ]]; then
      echo
      echo "==============================="
      echo
    fi

    echo >&2 "Failed to scan or resolve ${failed} symlink(s)"
  fi
}
