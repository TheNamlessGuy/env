#!/bin/bash

if [[ -z "${BS_LOCATION}" ]]; then
  echo >&2 "BS_LOCATION not set"
  exit 1
fi

export EDITOR="/bin/nano"
export VISUAL="${EDITOR}"
export LANG="en_US.utf8"
export LESS="-R" # Fuck you git, don't -FX per default you cunt

PS2="\e[0m[[[INCOMPLETE COMMAND]]] >> "
PS3="\e[0m[[SELECT]] > "
PS4="+"

PROMPT_COMMAND="set_PS1"

trap '[[ -t 1 ]] && tput sgr0' DEBUG
PROMPT_DIRTRIM=3

# If we have some local init stuff, source that before everything else
if [[ -f "${BS_LOCATION}/local/_init.sh" ]]; then
  source "${BS_LOCATION}/local/_init.sh"
fi

# Source all <name>.sh
while IFS= read -r f; do
  if [[ ! "$(basename "${f}")" == _* ]]; then
    source "${f}"
  fi
done < <(find "${BS_LOCATION}" -type f '(' -name '*.sh' -o -name '.*.sh' ')')

set_PS1
cclear
dirs -c
