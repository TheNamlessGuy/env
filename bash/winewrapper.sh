winewrapper() {
  if ! command -v wine > /dev/null 2>&1; then
    echo >&2 "'wine' isn't runnable"
    return 1
  fi

  if [[ $# -lt 1 ]]; then
    echo >&2 "Usage:"
    echo >&2 "  winewrapper path/to/program.exe [args...]"
    echo >&2 "  winewrapper path/to/program.exe --tricks <winetricks-args...>"
    return 1
  fi

  local MODE="run"
  local EXE_PATH=""
  local ARGS=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --tricks)
        if ! command -v winetricks > /dev/null 2>&1; then
          echo >&2 "'winetricks' isn't runnable, but is required for --tricks"
          return 1
        fi

        MODE="tricks"
        shift
      ;;
      --symlink-root)
        MODE="symlink-root"
        shift
      ;;
      --symlink-local)
        MODE="symlink-local"
        shift
      ;;
      --initialize)
        MODE="initialize"
        shift
      ;;
      --*)
        echo >&2 "Unknown option: $1"
        return 1
      ;;
      *)
        if [[ -z "${EXE_PATH}" ]]; then # No EXE set yet
          EXE_PATH="$(realpath --no-symlinks "$1")"
        else
          ARGS+=("$1")
        fi

        shift
      ;;
    esac
  done

  if [[ -z "${EXE_PATH}" ]]; then
    echo >&2 "Missing path/to/program.exe"
    return 1
  fi

  local EXE_DIR="$(dirname "${EXE_PATH}")"
  local EXE_NAME="$(basename "${EXE_PATH}")"

  local PREFIX_DIR="${PREFIX_DIR:-${EXE_DIR}}"
  local WINE_PREFIX_DIR="${PREFIX_DIR}/.${EXE_NAME}.wine-prefix"
  local WINEDEBUG="${WINEDEBUG:-"--all,+err"}"

  if [[ -d "${WINE_PREFIX_DIR}" ]]; then
    echo "Using existing prefix dir '${WINE_PREFIX_DIR}'"
  else
    echo "Initializing prefix dir '${WINE_PREFIX_DIR}'"
    if ! command -v wineboot > /dev/null 2>&1; then
      echo >&2 "'wineboot' isn't runnable, but is required for initializing a prefix dir"
      return 1
    fi

    mkdir -p "${WINE_PREFIX_DIR}"
    if [[ "$?" -ne 0 ]]; then
      echo >&2 "Failed to create '${WINE_PREFIX_DIR}'"
      return 1
    fi

    WINEDEBUG="${WINEDEBUG}" WINEPREFIX="${WINE_PREFIX_DIR}" wineboot --init
    if [[ "$?" -ne 0 ]]; then
      echo >&2 "wineboot didn't manage to run properly"
      return 1
    fi
  fi

  case "${MODE}" in
    initialize)
      # Noop
    ;;

    run)
      WINEDEBUG="${WINEDEBUG}" WINEPREFIX="${WINE_PREFIX_DIR}" wine "${EXE_PATH}" "${ARGS[@]}"
    ;;

    tricks)
      if [[ ${#ARGS[@]} -eq 0 ]]; then
        echo "Running winetricks with no args"
        WINEPREFIX="${WINE_PREFIX_DIR}" winetricks "${ARGS[@]}"
      else
        echo "Running winetricks with args: ${ARGS[*]}"
        WINEPREFIX="${WINE_PREFIX_DIR}" winetricks "${ARGS[@]}"
      fi
    ;;

    symlink-root)
      mkdir -p "${WINE_PREFIX_DIR}/dosdevices"
      if [[ "$?" -ne 0 ]]; then
        echo >&2 "Failed to create '${WINE_PREFIX_DIR}/dosdevices'"
        return 1
      fi

      if [[ ! -e "${WINE_PREFIX_DIR}/dosdevices/z:" ]]; then
        ln -snf / "${WINE_PREFIX_DIR}/dosdevices/z:"
        if [[ "$?" != 0 ]]; then
          echo >&2 "Symlinking '/' to the 'z:' drive didn't work"
          return 1
        fi
      fi

      echo "Symlinked '/' to the 'z:' drive"
    ;;

    symlink-local)
      mkdir -p "${WINE_PREFIX_DIR}/dosdevices"
      if [[ "$?" -ne 0 ]]; then
        echo >&2 "Failed to create '${WINE_PREFIX_DIR}/dosdevices'"
        return 1
      fi

      if [[ ! -e "${WINE_PREFIX_DIR}/dosdevices/d:" ]]; then
        ln -snf "${EXE_DIR}" "${WINE_PREFIX_DIR}/dosdevices/d:"
        if [[ "$?" != 0 ]]; then
          echo >&2 "Symlinking '${EXE_DIR}' to the 'd:' drive didn't work"
          return 1
        fi
      fi

      echo "Symlinked '${EXE_DIR}' to the 'd:' drive"
    ;;

    *)
      echo >&2 "Internal error: unknown MODE '${MODE}'"
      return 1
    ;;
  esac
}
