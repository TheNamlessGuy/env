#!/usr/bin/env bash
set -euo pipefail

HERE="$(realpath --no-symlinks "$(dirname "${BASH_SOURCE[0]}")")"

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

dolphinrc() {
  local config_dir="${HOME}/.config"
  local actual_file="${config_dir}/dolphinrc"
  local local_file="${HERE}/dolphinrc"

  if [[ ! -d "${config_dir}" ]]; then
    mkdir -p "${config_dir}"
    echo "(Created '${config_dir}')"
  fi

  if [[ -e "${actual_file}" ]]; then
    if ! prompt_overwrite "${actual_file}"; then
      return
    fi

    \rm -f "${actual_file}"
  fi

  echo "Symlinking dolphinrc"
  ln -s "${local_file}" "${actual_file}"
}

dolphinviewproperties() {
  local folder="${HOME}/.local/share/dolphin/view_properties/global"

  if [[ ! -d "${folder}" ]]; then
    mkdir -p "${folder}"
    echo "(Created '${folder}')"
  fi

  echo "Setting dolphin view properties"
  setfattr -n "user.kde.fm.viewproperties#1" -v $'[Dolphin]\nHeaderColumnWidths=735,83,140,116\nPreviewsShown=false\nVersion=4\nViewMode=1\nVisibleRoles=CustomizedDetails,Details_text,Details_track,Details_size,Details_modificationtime\n\n[Settings]\nHiddenFilesShown=true\n' "${folder}"
}

service_menus_and_applications() {
  local servicemenus_dir="${HOME}/.local/share/kio/servicemenus"
  local applications_dir="${HOME}/.local/share/applications"

  while IFS= read -r -d '' desktop_file; do
    desktop_file_name="$(basename "${desktop_file}")"
    desktop_file_dir="$(dirname "${desktop_file}")"

    if [[ "${desktop_file_name}" == *.servicemenu.desktop ]]; then
      destination_dir="${servicemenus_dir}"
      destination_file_name="namless.${desktop_file_name/.servicemenu.desktop/.desktop}"
    elif [[ "${desktop_file_name}" == *.application.desktop ]]; then
      destination_dir="${applications_dir}"
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
  done < <(find "${HERE}" -mindepth 2 -type f '(' -name '*.servicemenu.desktop' -o -name '*.application.desktop' ')' -print0)
}

dolphinrc
dolphinviewproperties
service_menus_and_applications
