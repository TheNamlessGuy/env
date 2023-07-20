gcm() {
  local arr=("$@")
  local i=""
  for ((i = 0; i < "${#arr[@]}"; ++i)); do
    if [[ "${arr[$i]}" == "--a" ]]; then
      unset "arr[$i]"
      arr+=("--amend")
    elif [[ "${arr[$i]}" == "--n" ]]; then
      unset "arr[$i]"
      arr+=("--no-edit")
    elif [[ "${arr[$i]}" == "--an" ]]; then
      unset "arr[$i]"
      arr+=("--amend" "--no-edit")
    elif [[ "${arr[$i]}" == "--na" ]]; then
      unset "arr[$i]"
      arr+=("--no-edit" "--amend")
    fi
  done

  git commit "${arr[@]}"
}