gpush() {
  local arr=("$@")
  local branch=""
  local i=""
  for ((i = 0; i < "${#arr[@]}"; ++i)); do
    if [[ "${arr[$i]}" == "--n" ]]; then
      arr[$i]="--no-verify"
    elif [[ "${arr[$i]}" != "-"* ]]; then
      branch="${arr[$i]}"
      unset "arr[$i]"
    fi
  done

  local prefix_flags=""
  local local_branch="$(git rev-parse --abbrev-ref HEAD)"
  local remote="origin"

  if [[ -z "${branch}" ]]; then
    local branch="$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2> /dev/null)"
    if [[ -z "${branch}" ]]; then
      local response=""
      read -r -p "No upstream branch found, try to create remote branch with name '${local_branch}'? [y/N] " response
      if [[ -z "${response}" || "${response}" == *"n"* || "${response}" == *"N"* ]]; then
        return 0
      fi

      prefix_flags="${prefix_flags} --set-upstream"
      branch="${local_branch}"
    else
      remote="$(echo "${branch}" | sed 's#/.*$##')"
      branch="$(echo "${branch}" | sed 's#^.*/##')"
      local response=""
      read -r -p "Push local branch '${local_branch}' to remote branch '${remote}/${branch}'? [Y/n] " response
      if [[ "${response}" == *"n"* || "${response}" == *"N"* ]]; then
        return 0
      fi
    fi

    echo
  fi

  git push ${prefix_flags} "${remote}" "${local_branch}:${branch}" "${arr[@]}"
}

_comp_gpush() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local branches="$(git branch -r | awk '{print $1}' | sed 's#origin/##g')"
  COMPREPLY=($(compgen -W "${branches}" -- "${cur}"))
}
complete -F _comp_gpush gpush
