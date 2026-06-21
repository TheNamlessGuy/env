#!/usr/bin/env bash

# Smart AVIF → GIF/PNG/JPG converter using ffprobe + ffmpeg
# - Animated → GIF
# - Transparent → PNG
# - Otherwise → JPG
#
# Shows a Plasma notification with a progress bar.
# Deletes source .avif files after successful conversion.
# Asks for confirmation if the target file already exists.

set -euo pipefail

if [ "$#" -eq 0 ]; then
  exit 0
fi

# Ensure kdialog is available for popups
if ! command -v kdialog >/dev/null 2>&1; then
  notify-send --app-name="AVIF Converter" \
    "AVIF conversion" \
    "kdialog not found; cannot ask overwrite confirmation."
  exit 1
fi

# Ensure ffmpeg/ffprobe are available
if ! command -v ffmpeg >/dev/null 2>&1 || ! command -v ffprobe >/dev/null 2>&1; then
  notify-send --app-name="AVIF Converter" \
    "AVIF conversion" \
    "ffmpeg/ffprobe not found; cannot decode AVIF."
  exit 1
fi

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

total="$#"
current=0

# Initial notification (0%)
notif_id=$(notify-send \
  --app-name="AVIF Converter" \
  --hint=int:value:0 \
  --print-id \
  "AVIF conversion" \
  "Starting conversion of $total file(s)...")

for input in "$@"; do
  [ -f "$input" ] || continue

  dir="$(dirname "$input")"
  base="$(basename "$input")"
  name="${base%.*}"

  # 1. Check if animated (more than 1 frame) using ffprobe
  frames=$(ffprobe -v error \
    -select_streams v:0 \
    -show_entries stream=nb_frames \
    -of default=nokey=1:noprint_wrappers=1 \
    "$input" 2>/dev/null || echo "1")

  # Some containers report "N/A" or empty; treat as 1 frame
  if ! [[ "$frames" =~ ^[0-9]+$ ]]; then
    frames=1
  fi

  # 2. Check for alpha channel via pixel format
  pix_fmt=$(ffprobe -v error \
    -select_streams v:0 \
    -show_entries stream=pix_fmt \
    -of default=nokey=1:noprint_wrappers=1 \
    "$input" 2>/dev/null || echo "")

  # Heuristic: formats with alpha usually have 'a' in the name (e.g. yuva420p10le)
  if [[ "$pix_fmt" == *a* || "$pix_fmt" == *A* ]]; then
    has_alpha=1
  else
    has_alpha=0
  fi

  # Decide output format
  if [ "$frames" -gt 1 ]; then
    # Animated → GIF
    output="$dir/$name.gif"
    action_desc="animated → GIF"
  elif [ "$has_alpha" -eq 1 ]; then
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
    kdialog --title "AVIF Converter" \
      --yesno "File:\n\n$output\n\nalready exists.\n\nOverwrite it?"
    rc=$?
    if [ "$rc" -ne 0 ]; then
      # User chose "No" → skip this file entirely
      current=$(( current + 1 ))
      percent=$(( current * 100 / total ))
      notify-send \
        --app-name="AVIF Converter" \
        --hint=int:value:"$percent" \
        --replace-id="$notif_id" \
        "AVIF conversion" \
        "[$current/$total] $base: skipped (target exists)"
      continue
    fi
  fi

  # Perform conversion with ffmpeg
  if [ "$frames" -gt 1 ]; then
    # Animated AVIF → animated GIF
    # Simple version (no custom palette); good enough for most use
    ffmpeg -y -loglevel error -i "$input" "$output"
  elif [ "$has_alpha" -eq 1 ]; then
    # Preserve alpha → PNG
    ffmpeg -y -loglevel error -i "$input" -frames:v 1 "$output"
  else
    # Opaque → JPEG with decent quality
    ffmpeg -y -loglevel error -i "$input" -frames:v 1 -qscale:v 2 "$output"
  fi

  # If ffmpeg failed, don't trash the original
  if [ ! -f "$output" ]; then
    notify-send \
      --app-name="AVIF Converter" \
      "AVIF conversion" \
      "[$current/$total] $base: conversion failed"
    continue
  fi

  # Conversion succeeded → move source to Trash
  if ! trash_file "$input"; then
    notify-send \
      --app-name="AVIF Converter" \
      "AVIF conversion" \
      "[$current/$total] $base: Couldn't move to Trash; original file left in place."
  fi

  # Update progress notification
  current=$(( current + 1 ))
  percent=$(( current * 100 / total ))
  notify-send \
    --app-name="AVIF Converter" \
    --hint=int:value:"$percent" \
    --replace-id="$notif_id" \
    "AVIF conversion" \
    "[$current/$total] $base: $action_desc"

done

# Final notification at 100%
notify-send \
  --app-name="AVIF Converter" \
  --hint=int:value:100 \
  --replace-id="$notif_id" \
  "AVIF conversion" \
  "Done converting $total file(s)."
