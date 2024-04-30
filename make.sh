#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

function trace() {
  echo "!" "$@" >&2; "$@"
}

function usage() {
cat << EOF
Usage:
./make.sh build
./make.sh switch
./make.sh update
./make.sh upgrade <version>
./make.sh info
./make.sh cleanup
./make.sh help
EOF
}

function invalid_syntax() {
  echo "Invalid syntax." 2>&1
  usage 2>&1
  return 1
}

cd "$( dirname "${BASH_SOURCE[0]}" )"

[[ $# -lt 1 ]] && invalid_syntax

mode="$1"
shift

case "$mode" in
  # TODO add options for home-manager. maybe interactive asking

  "build")
    cd nixpkgs/
    export NIXOS_CONFIG=${HOME}/.config/nixpkgs/maschines/laptop/configuration.nix
    trace nix-shell --keep NIXOS_CONFIG --run 'nixos-rebuild -I nixpkgs=$NIXPKGS --show-trace build'
    drv="$(readlink ./result)"

    trace nix-shell --run "home-manager --show-trace build"
    homedrv="$(readlink ./result)"

    echo "System Drv: $drv"
    echo
    echo "========================="
    echo "Home Drv: $homedrv"
    #trace nix store diff-closures /var/run/current-system/ "$homedrv" || true
    ;;
  "switch")
    cd nixpkgs/
    export NIXOS_CONFIG=${HOME}/.config/nixpkgs/maschines/laptop/configuration.nix
    trace sudo rm -f /etc/nixos || exit 1
    trace sudo ln -s $(dirname $NIXOS_CONFIG) /etc/nixos
    trace nix-shell --keep NIXOS_CONFIG --run 'sudo nixos-rebuild -I nixpkgs=$NIXPKGS switch'
    trace nix-shell --run "home-manager --show-trace switch"
    ;;
  "update")
    cd nixpkgs/ && nix-shell --run "niv update"
    cd .. && "$0" build
    ;;
  "upgrade")
    version="$1"
    shift
    echo "updating to version ${version}"

    cd nixpkgs/
    nix-shell --run "niv update nixpkgs-stable -b ${version}"
    nix-shell --run "niv update home-manager -b ${version}"
    cd .. && "$0" update
    ;;
  "info")
    drv="$(realpath /var/run/current-system)"

    echo "> Derivation:"
    echo "$drv"
    echo

    echo "> Biggest dependencies:"
    du -shc $(nix-store -qR "$drv") | sort -hr | head -n 11 || true
    echo

    echo "> Auto GC roots:"
    roots=""
    for i in /nix/var/nix/gcroots/auto/*; do
      p="$(readlink "$i")"
      if [[ -e "$p" ]]; then
        s="$(du -sch $(nix-store -qR "$p") | tail -n 1 | grep -Po "^[^\t]*")"
        roots="$roots$s $p\n"
      fi
    done
    if [[ -n "$roots" ]];
    then echo -e "$roots" | sort -hr
    else echo "None."
    fi

    echo "> Installed with nix-env:"
    env="$(nix-env -q)"
    if [[ -n "$env" ]];
    then nix-env -q
    else echo "None."
    fi
    ;;
  "cleanup")
    trace sudo nix-collect-garbage --delete-older-than 10d
    trace sudo nix-store --optimise
    ;;
  "help")
    [[ $# -gt 0 ]] && invalid_syntax
    usage
    ;;
  *)
    invalid_syntax
esac
