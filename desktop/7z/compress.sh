#!/usr/bin/env bash
set -euo pipefail

# No selection – nothing to do
if [ "$#" -eq 0 ]; then
  exit 0
fi

# Use the paths as Dolphin passes them (they are already absolute)
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

# If an archive with that name already exists, ask before overwriting
if [ -e "$outfile" ]; then
  kdialog --warningyesno "Archive exists:\n$outfile\n\nOverwrite?" || exit 1
  rm -f -- "$outfile"
fi

PROGRESS_LINE="$(kdialog --progressbar "Creating archive:\n$outfile" 0)"
PROGRESS_SERVICE="${PROGRESS_LINE%% *}"
PROGRESS_OBJECT="${PROGRESS_LINE#* }"

# 7z settings:
# -t7z : 7z format
# -mx=9 : highest compression level
7z a -t7z -mx=9 -- "$outfile" "${abs_paths[@]}"

# Make sure everything is written before Dolphin/Ark sees it
sync
sleep 1

if [[ -n "${PROGRESS_SERVICE}" && -n "${PROGRESS_OBJECT}" ]]; then
  qdbus "$PROGRESS_SERVICE" "$PROGRESS_OBJECT" close 2>/dev/null || true
  kdialog --passivepopup "Archive created:\n$outfile" 3 & disown || true
fi
