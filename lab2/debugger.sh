#!/usr/bin/env bash
#
# Usage: ./debugger.sh <Generator> <Code 1> <Code 2> <time>

readonly SEP="--------------------"

gcc -o gen "$1"
gcc -o a "$2"
gcc -o b "$3"

for (( i = 1; i <= "$4"; ++i )); do
  ./gen "${i}" > in.txt
  ./a < in.txt > out_a.txt
  ./b < in.txt > out_b.txt

  if ! diff out_a.txt out_b.txt > /dev/null; then
    echo "Test ${i}:"
    echo "Input:"
    echo "${SEP}"
    cat in.txt
    echo "${SEP}"
    echo "Output of $2:"
    echo "${SEP}"
    cat out_a.txt
    echo "${SEP}"
    echo "Output of $3:"
    echo "${SEP}"
    cat out_b.txt
    echo "${SEP}"
    exit
  fi
done
