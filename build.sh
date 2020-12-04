#!/bin/bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

for PKGBUILD in */PKGBUILD; do
    # update pkgver before generating SRCINFO files
    pushd "$(dirname "$PKGBUILD")" >/dev/null &&
        makepkg --nobuild --syncdeps --noconfirm &&
        makepkg --printsrcinfo >.SRCINFO || exit
    popd >/dev/null
done

QUEUE_FILE=$(mktemp)
cat -- */.SRCINFO | aur graph | tsort | tac >"$QUEUE_FILE"
aur build -d "${1:-lk-aur}" -a "$QUEUE_FILE" --noconfirm --force --clean
