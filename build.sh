#!/bin/bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

PKGBUILDS=("$@")

[ $# -gt 0 ] ||
    PKGBUILDS=(*/PKGBUILD)

[ ${#PKGBUILDS[@]} -gt 0 ] || exit

for PKGBUILD in "${PKGBUILDS[@]}"; do
    # update pkgver before generating SRCINFO files
    pushd "$(dirname "$PKGBUILD")" >/dev/null &&
        makepkg --cleanbuild --nobuild --syncdeps --noconfirm &&
        makepkg --printsrcinfo >.SRCINFO || exit
    popd >/dev/null
done

QUEUE_FILE=$(mktemp)
cat -- "${PKGBUILDS[@]//PKGBUILD/.SRCINFO}" | aur graph | tsort | tac >"$QUEUE_FILE"
aur build -d lk-aur -a "$QUEUE_FILE" --noconfirm --force --clean
