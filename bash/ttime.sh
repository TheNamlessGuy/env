ttime() {
  local t="$(time ($@ 2>&1) 3>&1 1>&2 2>&3)"

  local real="$(echo "$t" | sed -n 2p | awk '{print $2}')"
  local user="$(echo "$t" | sed -n 3p | awk '{print $2}')"
  local sys="$(echo "$t" | sed -n 4p | awk '{print $2}')"

  local tmp1="$(echo "${user}" | cut -d'm' -f1)"
  local tmp2="$(echo "${sys}" | cut -d'm' -f1)"
  local awake="$((tmp1 + tmp2))m"
  tmp1="$(echo "${user}" | cut -d'm' -f2 | cut -d's' -f1)"
  tmp2="$(echo "${sys}" | cut -d'm' -f2 | cut -d's' -f1)"
  awake="${awake}$(echo "${tmp1} + ${tmp2}" | bc | sed 's/^\./0./')s"

  tmp1="$(echo "${real}" | cut -d'm' -f1)"
  tmp2="$(echo "${awake}" | cut -d'm' -f1)"
  local sleep="$((tmp1 + tmp2))m"
  tmp1="$(echo "${real}" | cut -d'm' -f2 | cut -d's' -f1)"
  tmp2="$(echo "${awake}" | cut -d'm' -f2 | cut -d's' -f1)"
  sleep="${sleep}$(echo "${tmp1} - ${tmp2}" | bc | sed 's/^\./0./')"

  echo
  echo "Full time elapsed:         ${real}"
  echo "Time spent in user mode:   ${user}"
  echo "Time spent in kernel mode: ${sys}"
  echo "Time spent awake:          ${awake}"
  echo "Time spent sleeping:       ${sleep}"
}