gcleantags() {
  echo "+------------------+"
  echo "| Clearing tags... |"
  echo "+------------------+"
  git tag -l | xargs git tag -d

  echo "+------------------+"
  echo "| Fetching tags... |"
  echo "+------------------+"
  git fetch -t
}
