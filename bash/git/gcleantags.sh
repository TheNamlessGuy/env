gcleantags() {
  echo "Clearing tags..."
  git tag -l | xargs git tag -d &> /dev/null
  echo "Fetching tags..."
  git fetch -t &> /dev/null
}