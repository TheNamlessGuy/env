gu() {
  echo "+--------------+"
  echo "| git fetch -p |"
  echo "+--------------+"
  git fetch -p || return $?

  echo "+-------------+"
  echo "| git pull -r |"
  echo "+-------------+"
  git pull -r

  return $?
}