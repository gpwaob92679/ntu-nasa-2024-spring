#!/usr/bin/env bash
#
# Usage: ./debugger.sh <Generator> <Code 1> <Code 2> <time>

readonly SEP="--------------------"

gcc "$1" -o gen
gcc "$2" -o a
gcc "$3" -o b

for (( i = 1; i <= "$4"; ++i )); do
  ./gen "${i}" > in.txt
  output_a="$(./a < in.txt)"
  output_b="$(./b < in.txt)"

  if ! diff <(echo "${output_a}") <(echo "${output_b}") > /dev/null; then
    echo "Test ${i}:"
    echo "Input:"
    echo "${SEP}"
    cat in.txt
    echo "${SEP}"
    echo "Output of $2:"
    echo "${SEP}"
    echo "${output_a}"
    echo "${SEP}"
    echo "Output of $3:"
    echo "${SEP}"
    echo "${output_b}"
    echo "${SEP}"
    exit
  fi
done
