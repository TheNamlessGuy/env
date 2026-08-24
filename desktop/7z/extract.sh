#!/usr/bin/env bash
set -euo pipefail

mode="$1"
shift # remaining args are archives

if [ -z "$mode" ] || [ "$#" -eq 0 ]; then
  exit 0
fi

PROGRESS_LINE="$(kdialog --progressbar "Extracting archive(s)" 0)"
PROGRESS_SERVICE="${PROGRESS_LINE%% *}"
PROGRESS_OBJECT="${PROGRESS_LINE#* }"

# For each selected archive…
for arch in "$@"; do
  # Where the archive *is*, not where it might point
  arch_path="${arch}"
  arch_dir="$(dirname "${arch_path}")"
  arch_name="$(basename "${arch_path}")"
  arch_base="${arch_name%.*}" # strip extension

  ext="${arch_name##*.}"
  is_rar="-"
  if [[ "$ext" == "rar" ]]; then
    is_rar=""
  fi

  case "$mode" in
    here)
      if [[ -z "${is_rar}" ]]; then
        ( cd "${arch_dir}" && unrar x -o+ -- "${arch_path}" )
      else
        ( cd "${arch_dir}" && 7z x -- "${arch_path}" )
      fi
      ;;

    here_delete)
      if [[ -z "${is_rar}" ]]; then
        ( cd "${arch_dir}" && unrar x -o+ -- "${arch_path}" )
      else
        ( cd "${arch_dir}" && 7z x -- "${arch_path}" )
      fi

      rm -f -- "${arch_path}"
      ;;

    own)
      target_dir="${arch_dir}/${arch_base}"
      mkdir -p -- "${target_dir}"

      if [[ -z "${is_rar}" ]]; then
        ( cd "${arch_dir}" && unrar x -o+ -- "${arch_path}" "${target_dir}/" )
      else
        7z x -o"${target_dir}" -- "${arch_path}"
      fi
      ;;

    own_delete)
      target_dir="${arch_dir}/${arch_base}"
      mkdir -p -- "${target_dir}"

      if [[ -z "${is_rar}" ]]; then
        ( cd "${arch_dir}" && unrar x -o+ -- "${arch_path}" "${target_dir}/" )
      else
        7z x -o"${target_dir}" -- "${arch_path}"
      fi

      rm -f -- "${arch_path}"
      ;;

    *)
      exit 1
      ;;
  esac
done

if [[ -n "${PROGRESS_SERVICE}" && -n "${PROGRESS_OBJECT}" ]]; then
  qdbus "$PROGRESS_SERVICE" "$PROGRESS_OBJECT" close 2>/dev/null || true
  kdialog --passivepopup "Archive(s) extracted" 3 & disown || true
fi

