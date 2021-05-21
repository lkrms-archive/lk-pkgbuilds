#!/bin/bash

set -euo pipefail
shopt -s nullglob

PREPARE=
FORCE=
ALL=
while [ $# -gt 0 ]; do
    case "$1" in
    --prepare)
        PREPARE=1
        ;;
    --force)
        FORCE=1
        ;;
    --all)
        ALL=1
        ;;
    *)
        break
        ;;
    esac
    shift
done

[[ "${ALL:-0}$#" =~ ^(0[1-9][0-9]*|10)$ ]] || {
    echo "Usage: ${0##*/} [--prepare] [--force] --all | PACKAGE..." >&2
    exit 1
}

cd "$(dirname "${BASH_SOURCE[0]}")"

if [ $# -eq 0 ]; then
    set -- */PKGBUILD
else
    PKGBUILDS=()
    for PACKAGE in "$@"; do
        [[ $PACKAGE =~ ^([^/]+)(/|/PKGBUILD)?$ ]] &&
            PKGBUILD=${BASH_REMATCH[1]}/PKGBUILD &&
            [ -f "$PKGBUILD" ] || {
            echo "Invalid package: $PACKAGE" >&2
            exit 1
        }
        PKGBUILDS[${#PKGBUILDS[@]}]=$PKGBUILD
    done
    set -- "${PKGBUILDS[@]}"
fi

if [ $# -eq 0 ]; then
    echo "Nothing to build" >&2
    exit 1
fi

{
    echo "Building:"
    printf -- '- %s\n' "${@%\/PKGBUILD}"
} >&2

if [ -n "$PREPARE" ]; then
    for PKGBUILD in "$@"; do
        # Update pkgver before generating SRCINFO files
        (cd "$(dirname "$PKGBUILD")" &&
            makepkg --nodeps --noconfirm --nobuild &&
            makepkg --printsrcinfo >.SRCINFO)
    done
elif type -P aur >/dev/null; then
    QUEUE=$(mktemp)
    aur graph "${@/PKGBUILD/.SRCINFO}" | tsort | tac >"$QUEUE"
    aur build --database lk --noconfirm ${FORCE:+--force} --remove \
        --chroot --makepkg-conf=/etc/makepkg.conf \
        ${GPGKEY+--sign} \
        --arg-file "$QUEUE"
    rm -f "$QUEUE"
else
    printf '%s\n' "" \
        "aur: command not found" \
        "Please install aurutils and try again" >&2
fi
