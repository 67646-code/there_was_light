#!/usr/bin/env bash
# Installe la version épinglée de Godot (Linux x86_64) dans .tools/godot/,
# ainsi que gdtoolkit (gdformat, gdlint). Pour les environnements cloud, la CI,
# ou une machine sans Godot. Idempotent.
#
# En changeant tools/godot-version, mettre à jour GODOT_SHA256 ci-dessous
# (somme SHA-256 du zip officiel).

set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="$(tr -d '[:space:]' < tools/godot-version)"
GODOT_SHA256="cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4" # 4.7.2
GDTOOLKIT_VERSION="4.5.0"
NAME="Godot_v${VERSION}-stable_linux.x86_64"
URL="https://github.com/godotengine/godot-builds/releases/download/${VERSION}-stable/${NAME}.zip"
DEST=".tools/godot"

if [[ -x "$DEST/godot" ]] && "$DEST/godot" --version 2>/dev/null | grep -q "^${VERSION}.stable"; then
    echo "Godot ${VERSION} déjà installé dans ${DEST}."
else
    mkdir -p "$DEST"
    TMP="$(mktemp -d)"
    trap 'rm -rf "$TMP"' EXIT
    echo "Téléchargement de Godot ${VERSION}…"
    curl -fsSL -o "$TMP/godot.zip" "$URL"
    echo "${GODOT_SHA256}  $TMP/godot.zip" | sha256sum -c --quiet -
    unzip -q -o "$TMP/godot.zip" -d "$TMP"
    mv "$TMP/$NAME" "$DEST/godot"
    chmod +x "$DEST/godot"
    echo "Godot installé : $("$DEST/godot" --version)"
fi

if command -v gdformat > /dev/null 2>&1 && gdformat --version | grep -q "$GDTOOLKIT_VERSION"; then
    echo "gdtoolkit ${GDTOOLKIT_VERSION} déjà installé."
else
    echo "Installation de gdtoolkit ${GDTOOLKIT_VERSION}…"
    if command -v pipx > /dev/null 2>&1; then
        pipx install --force "gdtoolkit==${GDTOOLKIT_VERSION}"
    else
        python3 -m pip install --user "gdtoolkit==${GDTOOLKIT_VERSION}" 2> /dev/null \
            || python3 -m pip install --user --break-system-packages "gdtoolkit==${GDTOOLKIT_VERSION}"
    fi
fi

echo "Prêt. Vérifier avec : tools/check.sh"
