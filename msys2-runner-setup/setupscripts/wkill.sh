#!/bin/bash

if [ -z "$1" -o -n "${1//[0-9]}" -o ! -d "/proc/$1" ]; then
  echo "Usage: $0 pid" >&2
  exit 1
fi

MSYS2_ARG_CONV_EXCL='*' \
  taskkill /F /PID "$(</proc/$1/winpid)"
