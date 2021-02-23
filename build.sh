#!/bin/bash

set -euo pipefail
shopt -s nullglob

PREPARE=
[[ ! ${1:-} =~ ^(--)?prepare$ ]] || PREPARE=1

cd "$(dirname "${BASH_SOURCE[0]}")"
set -- */PKGBUILD
if [ $# -eq 0 ]; then
    echo "Nothing to build" >&2
    exit 1
fi

if [ -n "$PREPARE" ]; then
    for PKGBUILD in "$@"; do
        # Update pkgver before generating SRCINFO files
        (cd "$(dirname "$PKGBUILD")" &&
            makepkg --syncdeps --noconfirm --nobuild &&
            makepkg --printsrcinfo >.SRCINFO)
    done
elif type -P aur >/dev/null; then
    QUEUE=$(mktemp)
    aur graph "${@/PKGBUILD/.SRCINFO}" | tsort | tac >"$QUEUE"
    aur build --database lk --noconfirm --force \
        --chroot --makepkg-conf=/etc/makepkg.conf \
        --arg-file "$QUEUE"
    rm -f "$QUEUE"
else
    printf '%s\n' "" \
        "aur: command not found" \
        "Please install aurutils and try again" >&2
fi
