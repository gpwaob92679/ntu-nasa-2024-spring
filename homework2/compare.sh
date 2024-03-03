#!/usr/bin/env bash

HIDDEN=
SYMLINK=
REGEX=
RECURSIVE=
PATH_A=
PATH_B=

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
  shift $(( OPTIND - 1 ))
  PATH_A="$1"
  PATH_B="$2"
  readonly PATH_A PATH_B
  return $(( OPTIND - 1 ))
}

# Check if file exists. If file is a symbolic link and `-l` is not on, the
# file is regarded non-existent.
# Globals:
#   SYMLINK
# Arugments:
#   A path of the file to be checked.
# Returns:
#   0 if file exists, 1 otherwise.
check_exist() {
  if [[ -L "$1" ]]; then
    if [[ -z "${SYMLINK}" ]]; then
      return 1
    fi
  elif ! [[ -e  "$1" ]]; then
    return 1
  fi
  return 0
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
  if { [[ -n "${HIDDEN}" ]] || [[ -n "${REGEX}" ]]; } \
    && [[ -z "${RECURSIVE}" ]]; then
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

# Compare two files.
# Arguments:
#   Paths of two files to compare.
# Outputs:
#   Nothing if files are identical, "changed X%" if files differ, where X is
#   calculated according to the problem spec.
# Returns:
#   0 if files are identical, 1 if files differ.
compare_files() {
  local diff_output
  # -U 0 is necessary for line calculations below to work.
  if diff_output="$(diff -d -U 0 "$1" "$2")"; then
    # No differences.
    return 0
  fi

  if grep Binary <(echo -E "${diff_output}") > /dev/null; then
    echo "changed 100%"
    return 1
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
  return 1
}

# Compare paths pointed by two symbolic links.
# Arguments:
#   Paths of two symbolic links to compare.
# Outputs:
#   Nothing if symbolic links are identical, "changed 100%" otherwise.
# Returns:
#   0 if symbolic links point to the same path, 1 otherwise.
compare_symlinks() {
  if ! diff "$(readlink "$1")" "$(readlink   "$2")"; then
    echo "changed 100%"
  fi
  return 0
}

# Recursively compare two directories.
# Arguments:
#   Paths of two directories to compare.
# Outputs:
#   If both files exist, output individual file paths followed by output of
#   `compare_files()`.
compare_directories() {
  # Unique elements in array.
  # Reference: https://stackoverflow.com/a/13649357
  local -a temp
  for f in "$1"/*; do
    temp+=("${f#"$1"/}")
  done
  for f in "$2"/*; do
    temp+=("${f#"$2"/}")
  done
  for f in "${temp[@]}"; do echo "${f}"; done | uniq > test.txt
  readarray -t files < \
      <(for f in "${temp[@]}"; do echo "${f}"; done | sort | uniq)
  err "${files[@]}"

  for f in "${files[@]}"; do
    if [[ -d "$1/${f}" ]] && [[ -d "$2/${f}" ]]; then
      compare_directories "$1/${f}" "$2/${f}"
    else
      output_path="$1/${f}"
      output_path="${output_path#"${PATH_A}/"}"
      output_path="${output_path#"${PATH_B}/"}"
      err "output_path=${output_path}"
      if [[ -L "$1/${f}" ]] && [[ -z "${SYMLINK}" ]]; then
        continue
      elif ! check_exist "$1/${f}" \
           && check_exist "$2/${f}"; then
        echo "create ${output_path}"
        continue
      elif check_exist "$1/${f}" \
           && ! check_exist "$2/${f}"; then
        echo "delete ${output_path}"
        continue
      fi

      local compare_output
      compare_output="$(compare_files "$1/${f}" "$2/${f}")"
      if (( $? == 1 )); then
        echo "${output_path}: ${compare_output}"
      fi
    fi
  done
}

main() {
  err "args:" "$@"
  parse_optional_args "$@"
  shift $?
  err "HIDDEN=${HIDDEN}, SYMLINK=${SYMLINK}, REGEX=${REGEX}, RECURSIVE=${RECURSIVE}"
  err "positional args:" "$@"
  verify_args "$@"

  if [[ -n "${RECURSIVE}" ]]; then
    compare_directories "$1" "$2"
  else
    compare_files "$1" "$2"
  fi
}

main "$@"
