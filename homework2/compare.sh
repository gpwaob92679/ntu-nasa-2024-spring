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

# Check if file exists. If file is a symbolic link and `-l` is not on, the
# file is regarded non-existent.
# Globals:
#   SYMLINK
# Arugments:
#   A file path to be checked.
# Returns:
#  0 if file exists, 1 otherwise.
check_exist() {
  if [[ -L "$1" ]]; then
    if [[ -z "${SYMLINK}" ]]; then
      usage
    fi
  elif ! [[ -e  "$1" ]]; then
    usage
  fi
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
  if ! check_exist "$1" || ! check_exist "$2"; then
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

# Return the greater of two integers.
# Arguments:
#  Two integers.
# Outputs:
#  The greater of the two integers.
max() {
  if (( "$1" > "$2" )); then
    echo "$1"
  else
    echo "$2"
  fi
}

main() {
  err "args:" "$@"
  parse_optional_args "$@"
  shift $?
  err "HIDDEN=${HIDDEN}, SYMLINK=${SYMLINK}, REGEX=${REGEX}, RECURSIVE=${RECURSIVE}"
  err "positional args:" "$@"
  verify_args "$@"

  local diff_output
  # -U 0 is necessary for line calculations below to work.
  if diff_output="$(diff -d -U 0 "$1" "$2")"; then
    # No differences.
    exit
  fi

  if grep binary <(echo -E "${diff_output}"); then
    echo "changed 100%"
  fi

  diff_output_tail="$(tail -n +3 <(echo -E "${diff_output}"))"  # Remove header
  local -i delete_count
  delete_count="$(echo -E "${diff_output_tail}" |  grep -c ^-)"
  local -i insert_count
  insert_count="$(echo -E "${diff_output_tail}" |  grep -c ^+)"
  # Can't use `wc -l` because it doesn't account for the last line if there is
  # no newline at end of file.
  local -i keep_count=$(( "$(awk 'END {print NR}' "$1")" - delete_count ))
  err "${delete_count} ${insert_count} ${keep_count}"

  local -i mx
  mx="$(max "${delete_count}" "${insert_count}")"
  echo "changed $(( 100 * mx / $(( mx + keep_count )) ))%"
}

main "$@"
