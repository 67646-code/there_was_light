#!/usr/bin/env bash
# Vérification complète du projet. Définition de « terminé » : cette commande passe.
#
# Usage :
#   tools/check.sh          # tout vérifier
#   tools/check.sh --fix    # reformater le code (gdformat) puis tout vérifier
#
# Godot utilisé, dans l'ordre : $GODOT, puis `godot` dans le PATH, puis .tools/godot/godot
# (installé par tools/setup-godot.sh).

set -uo pipefail
cd "$(dirname "$0")/.."

EXPECTED_VERSION="$(tr -d '[:space:]' < tools/godot-version)"
LOG_DIR=".test-results"
mkdir -p "$LOG_DIR"
GD_PATHS=(src tests tools)
FAILED=0

step() {
    printf '\n== %s\n' "$1"
    STEP_FAILED=0
}
ok() { printf '   OK\n'; }
fail() {
    printf '   ÉCHEC : %s\n' "$1"
    FAILED=1
    STEP_FAILED=1
}
# Affiche les lignes d'erreur Godot d'un journal (hors addons tiers).
godot_errors() {
    grep -E "SCRIPT ERROR|Parse Error|^ERROR:" "$1" | grep -v "res://addons/" || true
}

# --- 0. Trouver Godot et vérifier sa version -------------------------------
if [[ -n "${GODOT:-}" ]]; then
    GODOT_BIN="$GODOT"
elif command -v godot > /dev/null 2>&1; then
    GODOT_BIN="godot"
elif [[ -x .tools/godot/godot ]]; then
    GODOT_BIN=".tools/godot/godot"
else
    echo "Godot introuvable. Définir GODOT=/chemin/vers/godot ou lancer tools/setup-godot.sh."
    exit 2
fi
ACTUAL_VERSION="$("$GODOT_BIN" --version 2>/dev/null | head -n1)"
if [[ "$ACTUAL_VERSION" != "$EXPECTED_VERSION".stable* ]]; then
    echo "Version de Godot incorrecte : attendu $EXPECTED_VERSION, trouvé « $ACTUAL_VERSION » ($GODOT_BIN)."
    echo "Installer la bonne version avec tools/setup-godot.sh ou définir GODOT."
    exit 2
fi
echo "Godot $ACTUAL_VERSION ($GODOT_BIN)"

run_godot() { timeout 600 "$GODOT_BIN" --headless --path . "$@" < /dev/null; }

# --- 1. Import du projet -----------------------------------------------------
step "Import du projet"
run_godot --import > "$LOG_DIR/import.log" 2>&1
ERRS="$(godot_errors "$LOG_DIR/import.log")"
if [[ -n "$ERRS" ]]; then fail "erreurs pendant l'import"; echo "$ERRS"; else ok; fi

# --- 2. Chargement de tous les scripts, scènes et ressources ----------------
step "Chargement des scripts, scènes et ressources"
if run_godot --script res://tools/check_scripts.gd > "$LOG_DIR/scripts.log" 2>&1; then
    ok
else
    fail "fichiers invalides"
    godot_errors "$LOG_DIR/scripts.log"
    grep -E "ÉCHEC" "$LOG_DIR/scripts.log"
fi

# --- 3. Format et lint -------------------------------------------------------
step "Format (gdformat) et lint (gdlint)"
if ! command -v gdformat > /dev/null 2>&1; then
    fail "gdtoolkit absent : pip install 'gdtoolkit==4.5.0' (ou tools/setup-godot.sh)"
else
    if [[ "${1:-}" == "--fix" ]]; then gdformat "${GD_PATHS[@]}" > /dev/null; fi
    FORMAT_OUT="$(gdformat --check "${GD_PATHS[@]}" 2>&1)" || {
        fail "code mal formaté (corriger avec tools/check.sh --fix)"
        echo "$FORMAT_OUT" | grep -i "would reformat"
    }
    LINT_OUT="$(gdlint "${GD_PATHS[@]}" 2>&1)" || { fail "problèmes de lint"; echo "$LINT_OUT"; }
    [[ $STEP_FAILED -eq 0 ]] && ok
fi

# --- 4. Tests automatisés (GUT) ---------------------------------------------
step "Tests (GUT)"
if run_godot -s addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json > "$LOG_DIR/tests.log" 2>&1; then
    grep -E "^Tests|Passing Tests" "$LOG_DIR/tests.log" | sed 's/^/   /'
    ok
else
    fail "tests en échec (journal complet : $LOG_DIR/tests.log)"
    grep -E -A6 "^\s*\[Failed\]|FAILED|Failing Tests|SCRIPT ERROR" "$LOG_DIR/tests.log" | head -60
fi

# --- 5. Lancement court du jeu ----------------------------------------------
step "Lancement du jeu (120 images)"
run_godot --quit-after 120 > "$LOG_DIR/boot.log" 2>&1
ERRS="$(godot_errors "$LOG_DIR/boot.log")"
if [[ -n "$ERRS" ]]; then fail "erreurs au lancement"; echo "$ERRS"; else ok; fi

# --- Résultat ----------------------------------------------------------------
echo
if [[ $FAILED -eq 0 ]]; then
    echo "TOUT EST VERT."
else
    echo "DES VÉRIFICATIONS ONT ÉCHOUÉ. Journaux dans $LOG_DIR/."
fi
exit $FAILED
