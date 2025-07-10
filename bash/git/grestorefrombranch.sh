grestorefrombranch() {
  local branch=""
  local diff_branch=""
  local paths=()

  while (($# > 0)); do
    if [[ "$1" == "--branch" || "$1" == "-b" ]]; then
      shift
      branch="$1"
    elif [[ "$1" == "--diff-branch" || "$1" == "-d" ]]; then
      shift
      diff_branch="$1"
    else
      paths+=("$1")
    fi

    shift
  done

  if [[ -z "${branch}" ]]; then
    echo >&2 "--branch needs to be specified"
    return 1
  fi

  if [[ -z "${diff_branch}" ]]; then
    diff_branch="$(git symbolic-ref refs/remotes/origin/HEAD --short)"
    echo "Assuming diff branch to be '${diff_branch}'"
  fi

  local files="$(git diff --name-only "${diff_branch}"..."${branch}")"
  if (( "${#paths[@]}" > 0 )); then
    local regexes=()
    local i=""
    for i in "${!paths[@]}"; do
      regexes+=("-e" "^${paths[$i]}")
    done

    files="$(echo "${files}" | grep --color=never ${regexes[@]})"
  fi

  files="$(echo "${files}" | tr '\n' ' ')"
  git restore --source "${branch}" -- $files
}
