#!/usr/bin/env bash

# Ensure `sort` sorts in ASCII order.
LANG="C.UTF-8"
LC_ALL="C.UTF-8"

# Global variables for parsed arguments.
HIDDEN=
SYMLINK=
REGEX=
RECURSIVE=
PATH_A=
PATH_B=

# Print debug messages to STDERR.
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

# Print usage message and exit.
# Arguments:
#   None
# Outputs:
#   Usage message.
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

# Parse and verify arguments.
# Globals:
#   HIDDEN
#   SYMLINK
#   REGEX
#   RECURSIVE
#   PATH_A
#   PATH_B
# Arguments:
#   All arguments that the script is run with.
parse_args() {
  while getopts ":ahln:r" opt; do
    case "${opt}" in
      a)
        HIDDEN="true"
        shopt -s dotglob
        ;;
      l) SYMLINK="true" ;;
      n) REGEX="${OPTARG}" ;;
      r) RECURSIVE="true";;
      h | *) usage ;;
    esac
  done
  readonly HIDDEN SYMLINK REGEX RECURSIVE
  shift $(( OPTIND - 1 ))
  PATH_A="$1"
  PATH_B="$2"
  readonly PATH_A PATH_B
  verify_args "$@"
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
  elif ! [[ -e "$1" ]]; then
    return 1
  fi
  return 0
}

# Verify parsed arguments.
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
    if [[ -L "$1" ]] || ! [[ -d "$1" ]] \
       || [[ -L "$2" ]] || ! [[ -d "$2" ]]; then
      usage
    fi
  else
    if { ! [[ -L "$1" ]] && [[ -d "$1" ]]; } || \
       { ! [[ -L "$2" ]] && [[ -d "$2" ]]; }; then
      usage
    fi
  fi
}

# Return the greater of two integers.
# Arguments:
#   Two integers.
# Outputs:
#   The greater of the two integers.
max() {
  if (( "$1" > "$2" )); then
    echo "$1"
  else
    echo "$2"
  fi
}

# Compare two regular files.
# Arguments:
#   Paths of two files to compare.
# Outputs:
#   Nothing if files are identical, "changed X%" if files differ, where X is
#   calculated according to the problem specification.
# Returns:
#   0 if files are identical, 1 if files differ.
compare_files() {
  local diff_output
  # `-U 0` is necessary for line calculations below to work.
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
  delete_count="$(echo -E "${diff_output_tail}" | grep -c ^-)"
  local -i insert_count
  insert_count="$(echo -E "${diff_output_tail}" | grep -c ^+)"
  # Can't use `wc -l` because it doesn't account for the last line if there is
  # no newline at end of file.
  local -i keep_count=$(( "$(awk 'END {print NR}' "$1")" - delete_count ))

  local -i mx
  mx="$(max "${delete_count}" "${insert_count}")"
  echo "changed $(( 100 * mx / $(( mx + keep_count )) ))%"
  return 1
}

# Compare paths pointed by two symbolic links.
# Arguments:
#   Paths of two symbolic links to compare.
# Outputs:
#   Nothing if symbolic links point to the same path, "changed 100%" if they
#   point to different paths.
# Returns:
#   0 if symbolic links point to the same path, 1 otherwise.
compare_symlinks() {
  if ! diff <(echo -E "$(readlink "$1")") <(echo -E "$(readlink "$2")") \
      > /dev/null; then
    echo "changed 100%"
    return 1
  fi
  return 0
}

# Compare two files or symbolic links. Dispatch comparison to `compare_files()`
# or `compare_symlinks()` based on type.
# Arguments:
#   Paths of two files to compare.
# Outputs:
#   If one regular file and one symlink, output "changed 100%".
#   If two files are the same type, see `compare_files()` and
#   `compare_symlinks()`.
# Returns:
#   0 and 1, same as `compare_files()` and `compare_symlinks()`.
#   2 if arguments contain one or more symbolic links but `-l` is off.
compare_files_or_symlinks() {
  if [[ -L "$1" ]] || [[ -L "$2" ]]; then
    if [[ -z "${SYMLINK}" ]]; then
      return 2
    fi
    if [[ -L "$1" ]] && [[ -L "$2" ]]; then
      compare_symlinks "$1" "$2"
      return $?
    else
      echo "changed 100%"
      return 1
    fi
  fi
  # Two regular files.
  compare_files "$1" "$2"
}

# Recursively compare two directories. Performs regex filtering if `-n <EXP>`
# is given.
# Arguments:
#   Paths of two directories to compare.
# Globals:
#   REGEX
#   PATH_A
#   PATH_B
# Outputs:
#   If both files exist, output individual file paths followed by output of
#   `compare_files()`.
#   If file exists under PATH_A but not PATH_B, output "create FILE".
#   If file exists under PATH_B but not PATH_A, output "delete FILE".
compare_directories() {
  local -a temp
  for f in "$1"/*; do
    temp+=("${f#"$1"/}")
  done
  for f in "$2"/*; do
    temp+=("${f#"$2"/}")
  done
  readarray -t files < \
      <(for f in "${temp[@]}"; do echo "${f}"; done | sort | uniq)
  # err "${files[@]}"

  for f in "${files[@]}"; do
    if ! [[ -L "$1/${f}" ]] && [[ -d "$1/${f}" ]] && ! [[ -L "$2/${f}" ]] \
       && [[ -d "$2/${f}" ]]; then
      compare_directories "$1/${f}" "$2/${f}"
      continue
    fi

    if [[ -n "${REGEX}" ]] && ! [[ "${f}" =~ ${REGEX} ]]; then
      continue
    fi

    local output_path="$1/${f}"
    output_path="${output_path#"${PATH_A}/"}"
    output_path="${output_path#"${PATH_B}/"}"

    if ! check_exist "$1/${f}" \
       && check_exist "$2/${f}"; then
      echo "create ${output_path}"
      continue
    fi
    if check_exist "$1/${f}" \
       && ! check_exist "$2/${f}"; then
      echo "delete ${output_path}"
      continue
    fi

    local compare_output
    compare_output="$(compare_files_or_symlinks "$1/${f}" "$2/${f}")"
    if (( $? == 1 )); then
      echo "${output_path}: ${compare_output}"
    fi
  done
}

main() {
  # err "args:" "$@"
  parse_args "$@"
  # err "HIDDEN=${HIDDEN},SYMLINK=${SYMLINK},REGEX=${REGEX},RECURSIVE=${RECURSIVE}"
  # err "PATH_A=${PATH_A},PATH_B=${PATH_B}"

  if [[ -n "${RECURSIVE}" ]]; then
    compare_directories "${PATH_A}" "${PATH_B}"
  else
    compare_files_or_symlinks "${PATH_A}" "${PATH_B}"
  fi
}

main "$@"
