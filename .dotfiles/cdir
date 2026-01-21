#!/bin/sh
# cdir - create directory with optional permissions

if [ -z "$1" ]; then
    echo "Usage: cdir <directory> [permissions]" >&2
    exit 1
fi

mkdir -p "$1" || exit 1

if [ -n "$2" ]; then
    chmod "$2" "$1"
fi
