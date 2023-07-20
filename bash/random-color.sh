random-color() {
  local a="$(($RANDOM % 2))"
  local b="$(((($RANDOM % 5)) + 1))"
  
  echo "\e[${a};3${b}m"
}