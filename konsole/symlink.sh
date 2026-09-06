perform_symlink() {
  local here="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"

  local profile="${HOME}/.local/share/konsole"
  if [ ! -d "${profile}" ]; then
    mkdir -p "${profile}"
  fi

  local config="${HOME}/.config"
  if [ ! -d "${config}" ]; then
    mkdir -p "${config}"
  fi

  ln -s "${here}/profile/Profile 1.profile" "${profile}/Profile 1.profile"
  ln -s "${here}/profile/WhiteOnBlack.colorscheme" "${profile}/WhiteOnBlack.colorscheme"

  ln -s "${here}/config/konsolerc" "${config}/konsolerc"
}

perform_symlink
