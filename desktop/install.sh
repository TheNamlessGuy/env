#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(realpath --no-symlinks "$(dirname "${BASH_SOURCE[0]}")")"
SERVICEMENUS_DIR="${HOME}/.local/share/kio/servicemenus"
APPLICATIONS_DIR="${HOME}/.local/share/applications"

prompt_overwrite() {
  local destination_file="$1"
  local response=""

  while true; do
    read -r -p "'${destination_file}' already exists. Replace it? [Y/n] " response < /dev/tty
    case "${response}" in
      ""|[Yy]) return 0 ;;
      [Nn])    return 1 ;;
      *)       echo "Please answer y or n." ;;
    esac
  done
}

while IFS= read -r -d '' desktop_file; do
  desktop_file_name="$(basename "${desktop_file}")"
  desktop_file_dir="$(dirname "${desktop_file}")"

  if [[ "${desktop_file_name}" == *.servicemenu.desktop ]]; then
    destination_dir="${SERVICEMENUS_DIR}"
    destination_file_name="namless.${desktop_file_name/.servicemenu.desktop/.desktop}"
  elif [[ "${desktop_file_name}" == *.application.desktop ]]; then
    destination_dir="${APPLICATIONS_DIR}"
    destination_file_name="namless.${desktop_file_name/.application.desktop/.desktop}"
  else
    echo "What? '${desktop_file}'"
    continue
  fi

  if [[ ! -d "${destination_dir}" ]]; then
    mkdir -p "${destination_dir}"
    echo "(Created '${destination_dir}')"
  fi

  destination_file="${destination_dir}/${destination_file_name}"
  if [[ -e "${destination_file}" ]]; then
    if ! prompt_overwrite "${destination_file}"; then
      continue
    fi
  fi

  echo "Installing '${desktop_file}' as '${destination_file}'"
  cp "${desktop_file}" "${destination_file}"

  sed -i "s#{{ORIGINAL_DIR}}#${desktop_file_dir}#g" "${destination_file}"
done < <(find "${SCRIPT_DIR}" -mindepth 2 -type f '(' -name '*.servicemenu.desktop' -o -name '*.application.desktop' ')' -print0)
