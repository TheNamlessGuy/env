set-title() {
    local title="$@"
    if [[ "${title}" == "." ]]; then
        title="$(basename "$PWD" | awk '{print toupper($0)}')"
    fi
    echo -ne "\033]30;${title}\007"
}