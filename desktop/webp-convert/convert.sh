#!/usr/bin/env bash

# Smart WebP → GIF/PNG/JPG converter using ImageMagick
# - Animated → GIF
# - Transparent → PNG
# - Otherwise → JPG
#
# Shows a Plasma notification with a progress bar.
# Deletes source .webp files after successful conversion.
# Asks for confirmation if the target file already exists.

set -euo pipefail

trash_file() {
  local f="$1"

  if command -v kioclient5 >/dev/null 2>&1; then
    kioclient5 move "$f" trash:/ >/dev/null 2>&1 && return 0
  fi

  if command -v gio >/dev/null 2>&1; then
    gio trash "$f" >/dev/null 2>&1 && return 0
  fi

  if command -v trash-put >/dev/null 2>&1; then
    trash-put "$f" >/dev/null 2>&1 && return 0
  fi

  return 1
}

if [ "$#" -eq 0 ]; then
  exit 0
fi

# Ensure kdialog is available for popups
if ! command -v kdialog >/dev/null 2>&1; then
  notify-send --app-name="WebP Converter" \
    "WebP conversion" \
    "kdialog not found; cannot ask overwrite confirmation."
  exit 1
fi

total="$#"
current=0

# Initial notification (0%)
notif_id=$(notify-send \
  --app-name="WebP Converter" \
  --hint=int:value:0 \
  --print-id \
  "WebP conversion" \
  "Starting conversion of $total file(s)...")

for input in "$@"; do
  [ -f "$input" ] || continue

  dir="$(dirname "$input")"
  base="$(basename "$input")"
  name="${base%.*}"

  # 1. Check if animated (more than 1 frame)
  frames=$(magick identify "$input" | wc -l || echo 1)
  # 2. Check for alpha channel (transparency)
  channels=$(magick identify -format '%[channels]' "$input" | head -n1 || echo "")

  if [ "$frames" -gt 1 ]; then
    # Animated → GIF
    output="$dir/$name.gif"
    action_desc="animated → GIF"

  elif [[ "$channels" == *a* || "$channels" == *A* ]]; then
    # Has alpha channel → PNG
    output="$dir/$name.png"
    action_desc="transparent → PNG"

  else
    # No animation, no alpha → JPEG
    output="$dir/$name.jpg"
    action_desc="opaque → JPG"
  fi

  # If target exists, ask user whether to overwrite
  if [ -e "$output" ]; then
    kdialog --title "WebP Converter" \
      --yesno "File:\n\n$output\n\nalready exists.\n\nOverwrite it?"
    rc=$?
    if [ "$rc" -ne 0 ]; then
      # User chose "No" → skip this file entirely
      current=$(( current + 1 ))
      percent=$(( current * 100 / total ))
      notify-send \
        --app-name="WebP Converter" \
        --hint=int:value:"$percent" \
        --replace-id="$notif_id" \
        "WebP conversion" \
        "[$current/$total] $base: skipped (target exists)"
      continue
    fi
  fi

  # Perform conversion
  if [ "$frames" -gt 1 ]; then
    magick "$input" -coalesce -strip "$output"
  elif [[ "$channels" == *a* || "$channels" == *A* ]]; then
    magick "$input" -strip "$output"
  else
    magick "$input" -strip -quality 92 "$output"
  fi

  # Conversion succeeded → move source to Trash
  if ! trash_file "$input"; then
    notify-send \
      --app-name="WebP Converter" \
      "WebP conversion" \
      "[$current/$total] $base: Couldn't move to Trash; original file left in place."
  fi

  # Update progress notification
  current=$(( current + 1 ))
  percent=$(( current * 100 / total ))
  notify-send \
    --app-name="WebP Converter" \
    --hint=int:value:"$percent" \
    --replace-id="$notif_id" \
    "WebP conversion" \
    "[$current/$total] $base: $action_desc"

done

# Final notification at 100%
notify-send \
  --app-name="WebP Converter" \
  --hint=int:value:100 \
  --replace-id="$notif_id" \
  "WebP conversion" \
  "Done converting $total file(s)."
