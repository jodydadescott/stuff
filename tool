#!/bin/bash -e

RECIPIENT="jody@thescottsweb.com"

function main() {
  case "$1" in
    encrypt) encrypt || { err "Failed"; return $?; } ;;
    decrypt) decrypt || { err "Failed"; return $?; } ;;
    *) err "Usage:$0 (encrypt | decrypt)" ;;
  esac
}

function encrypt() {
  cd "$(dirname "$0")"
  [ -d data ] || { err "Directory data not found"; return 2; }
  trap cleanup EXIT
  tmp=$(mktemp -d)
  tar cz data > "${tmp}/data.tgz"
  gpg --output "${tmp}/data.tgz.gpg" -e -r "$RECIPIENT" "${tmp}/data.tgz"
  mv "${tmp}/data.tgz.gpg" data.tgz.gpg
}

function decrypt() {
  cd "$(dirname "$0")"
  [ -d data ] && { err "Directory data exist, aborting!"; return 2; }
  gpg --output data.tgz --decrypt data.tgz.gpg
  tar xf data.tgz
  rm data.tgz
}

function cleanup() {
  [[ "$tmp" ]] || return 0
  [ -f "$tmp" ] || return 0
  rm -rf "$tmp"
}

function err() { echo "$@" 1>&2; }

main "$@"
