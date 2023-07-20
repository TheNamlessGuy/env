set_PS1() {
  local overall="\[$(random-color)\]"
  PS1="${overall}"
  local contents=("\h" "\u" "\t" "\w")

  local content=""
  for content in "${contents[@]}"; do
    local color="\[$(random-color)\]"
    while [[ "${overall}" == "${color}" ]]; do
      color="\[$(random-color)\]";
    done
    PS1+="[${color}${content}${overall}]"
  done

    local color="\[$(random-color)\]"
    while [[ "${overall}" == "${color}" ]]; do
      color="\[$(random-color)\]";
    done
    PS1+="\$${color} "
}