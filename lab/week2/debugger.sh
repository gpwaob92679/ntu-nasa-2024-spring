#!/usr/bin/env bash
#
# Usage: ./debugger.sh <Generator> <Code 1> <Code 2> <time>

readonly SEP="--------------------"

gcc -o gen "$1"
gcc -o a "$2"
gcc -o b "$3"

for (( i = 1; i <= "$4"; ++i )); do
  ./gen "${i}" > in.txt
  output_a="$(./a < in.txt)"
  output_b="$(./b < in.txt)"

  if ! diff <(echo -E "${output_a}") <(echo -E "${output_b}") > /dev/null; then
    echo "Test ${i}:"
    echo "Input:"
    echo "${SEP}"
    cat in.txt
    echo "${SEP}"
    echo "Output of $2:"
    echo "${SEP}"
    echo -E "${output_a}"
    echo "${SEP}"
    echo "Output of $3:"
    echo "${SEP}"
    echo -E "${output_b}"
    echo "${SEP}"
    exit
  fi
done
