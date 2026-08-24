#!/usr/bin/env bash
set -euo pipefail

# No selection – nothing to do
if [ "$#" -eq 0 ]; then
  exit 0
fi

# Dolphin sends absolute paths per default
abs_paths=()
for arg in "$@"; do
  abs_paths+=("$arg")
done

if [ "$#" -eq 1 ]; then
  # Single file or folder: archive name = its own name
  target="${abs_paths[0]}"
  base="$(basename "$target")"
  base="${base%/}"
  dir="$(dirname "$target")"
  outfile="$dir/$base.7z"
else
  # Multiple items: archive in the parent folder of the first selected item
  first="${abs_paths[0]}"
  parent_dir="$(dirname "$first")"
  base="$(basename "$parent_dir")"
  base="${base%/}"
  outfile="$parent_dir/$base.7z"
fi

if [ -e "$outfile" ]; then
  kdialog --warningyesno "Archive exists:\n${outfile}\n\nOverwrite?" || exit 1
  rm -f -- "$outfile"
fi

PROGRESS_LINE="$(kdialog --progressbar "Creating archive:\n${outfile}" 100)"
PROGRESS_SERVICE="${PROGRESS_LINE%% *}"
PROGRESS_OBJECT="${PROGRESS_LINE#* }"

qdbus "${PROGRESS_SERVICE}" "${PROGRESS_OBJECT}" setAllowCancel   false 2> /dev/null || true
qdbus "${PROGRESS_SERVICE}" "${PROGRESS_OBJECT}" showCancelButton false 2> /dev/null || true
qdbus "${PROGRESS_SERVICE}" "${PROGRESS_OBJECT}" setAutoClose     false 2> /dev/null || true

set +e
# 7z settings:
# -t7z : 7z format
# -mx=9 : highest compression level
stdbuf -o0 -e0 7z a -t7z -mx=9 -bsp1 -- "${outfile}" "${abs_paths[@]}" 2>&1 | tr '\b\r' '\n\n' | \
while IFS= read -r line; do
  if [[ "${line}" =~ ([0-9]{1,3})% ]]; then
    percentage="${BASH_REMATCH[1]}"
    (( percentage > 100 )) && percentage=100

    qdbus "${PROGRESS_SERVICE}" "${PROGRESS_OBJECT}" Set "" value "${percentage}" 2> /dev/null || true
  fi
done

zipping_status="${PIPESTATUS[0]:-1}" # This needs to be directly after the loop being piped to
set -e

if [[ "${zipping_status}" -ne 0 ]]; then
  qdbus "${PROGRESS_SERVICE}" "${PROGRESS_OBJECT}" close 2> /dev/null || true
  rm -f -- "${outfile}"
  kdialog --error "Archive creation failed:\n${outfile}"
  exit "${zipping_status}"
fi

qdbus "${PROGRESS_SERVICE}" "${PROGRESS_OBJECT}" Set "" value "100" 2> /dev/null || true

# Make sure everything is written before Dolphin/Ark sees it
sync
sleep 1

qdbus "${PROGRESS_SERVICE}" "${PROGRESS_OBJECT}" close 2>/dev/null || true
kdialog --passivepopup "Archive created:\n${outfile}" 3 & disown || true
