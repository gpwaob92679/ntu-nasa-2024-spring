#!/usr/bin/env bash

HIDDEN=
SYMLINK=
REGEX=
RECURSIVE=

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

# Prints usage mssage and exit.
# Arguments:
#   None
usage() {
  cat <<END
usage: ./compare.sh [OPTION] <PATH A> <PATH B>
options:
-a: compare hidden files instead of ignoring them
-h: output information about compare.sh
-l: treat symlinks as files instead of ignoring them
-n <EXP>: compare only files whose paths follow the REGEX <EXP>
-r: compare directories recursively
END
  exit
}

# Parse optional arguments.
# Globals:
#   HIDDEN
#   SYMLINK
#   REGEX
#   RECURSIVE
# Arguments:
#   All arguments that the script is run with.
# Returns:
#   Index of the first position argument.
parse_optional_args() {
  while getopts ":ahln:r" opt; do
    case "${opt}" in
      a) HIDDEN="true" ;;
      l) SYMLINK="true" ;;
      n)
        if [[ "${OPTARG:0:1}" = "-" ]]; then
          usage
        fi
        REGEX="${OPTARG}"
        ;;
      r) RECURSIVE="true";;
      h | *) usage ;;
    esac
  done
  readonly HIDDEN SYMLINK REGEX RECURSIVE
  return $(( OPTIND - 1 ))
}

# Verify arguments.
# Globals:
#   HIDDEN
#   SYMLINK
#   REGEX
#   RECURSIVE
# Arguments:
#   Positional arguments after parsing.
verify_args() {
  if { [[ -z "${HIDDEN}" ]] || [[ -z "${REGEX}" ]]; } \
    && [[ -n "${RECURSIVE}" ]]; then
    usage
  fi
  if (( $# != 2 )); then
    usage
  fi
  if ! [[ -e "$1" ]] || ! [[ -e "$2" ]]; then
    usage
  fi

  if [[ -n "${RECURSIVE}" ]]; then
    if ! [[ -d "$1" ]] || ! [[ -d "$2" ]]; then
      usage
    fi
  else
    if [[ -d "$1" ]] || [[ -d "$2" ]]; then
      usage
    fi
  fi
}

main() {
  err "args:" "$@"
  parse_optional_args "$@"
  shift $?
  err "HIDDEN=${HIDDEN}, SYMLINK=${SYMLINK}, REGEX=${REGEX}, RECURSIVE=${RECURSIVE}"
  err "positional args:" "$@"
  verify_args "$@"
}

main "$@"
