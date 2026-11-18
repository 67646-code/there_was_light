# 0001 — Moteur et outils

Date : 18 novembre 2026. Statut : accepté.

## Décision

- **Godot 4.7.2**, version épinglée dans `tools/godot-version`, identique pour l'humain, les agents et la CI.
- **GDScript typé** ; les variables non typées sont des erreurs de compilation.
- Vérification unique `tools/check.sh` (import, chargement, gdformat, gdlint, tests GUT, lancement), exécutée aussi en CI.
- Tests avec **GUT 9.7.1** (version compatible Godot 4.7), copié dans `addons/gut/`.
- Agents : **Claude Code** en principal, **Codex** en renfort, mêmes règles (`AGENTS.md`).

## Raisons

- Godot est solide en 2D, ses scènes et scripts sont en texte : les agents peuvent tout lire et modifier, et Git montre chaque changement.
- GDScript plutôt que C# : plus léger pour un prototype 2D, sans dépendance .NET à l'export (problème rencontré sur Corridor).
- Un agent qui peut vérifier seul son travail produit moins de dette. Les erreurs de typage et les tests rendent visibles des erreurs qui seraient sinon silencieuses.
