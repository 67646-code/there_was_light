# Jalon actif — P1 : prototype en boîtes grises

> Un seul jalon actif à la fois. Ce fichier reste court : objectif, tâches, critère de sortie, notes.

## Objectif

Savoir si le combat « tenir, charger, relâcher » est amusant **sans aucun graphisme** : un rectangle enfant contre un rectangle chien, dans une arène plate. Le code de ce jalon peut être jeté ; ce qui compte, c'est ce qu'on apprend.

Référence : `docs/design/combat.md`.

## Tâches

- [x] P1.0 — Proposer les entrées (clavier et manette) à ajouter à `project.godot` ; les ajouter après accord.
- [x] P1.1 — Classes de données (`src/core/`) et premières ressources (`data/`) : réglages de l'enfant, attaque, boss. Valeurs de `combat.md`.
- [x] P1.2 — Logique pure de l'enfant, image par image : huile, lumière, parade parfaite, garde, parade dans le vide, relâche, santé. Tests par scénarios.
- [x] P1.3 — Logique pure du chien : enchaînement des attaques (anticipation, impact, récupération), posture, brèche, deux phases. Tests.
- [x] P1.4 — Arène jouable : rectangles, déplacement, saut, esquive, direction de la lanterne. Le rectangle du chien change de couleur pendant l'anticipation.
- [ ] P1.5 — Retour d'impact : hitstop, recul, tremblement d'écran, sons provisoires.
- [ ] P1.6 — Affichage de debug (activable) : huile, lumière, posture, état courant, fenêtre de parade.
- [ ] P1.7 — Interrupteur variante A / variante B pour le test comparatif.
- [ ] P1.8 — Enregistrement et relecture des entrées d'une partie (pour reproduire un bug ou un ressenti).

## Critère de sortie

Le développeur a joué les deux variantes et répondu aux cinq questions de `combat.md`. Décision notée ci-dessous : continuer, ajuster ou repenser le combat.

## Notes

_(Notes courtes et datées au fil du jalon.)_

- 2026-11-18 — P1.0 : entrées validées. Clavier en touches physiques (AZERTY : Z/Q/S/D direction et déplacement, Espace saut, Maj esquive, J lanterne, K relâche, F1 debug, F2 variante) ; manette : stick/croix, A saut, B esquive, RB lanterne, RT relâche, Select debug.
- 2026-11-18 — Règles précisées : la parade dans le vide ne pénalise que si le bouton est relâché quand la fenêtre expire (tenu → garde sans pénalité). Directions : morsure, rafale, feinte « devant » ; bond « haut ».

- 2026-11-18 — P1.1 : `ChildSettings`, `AttackData`, `BossData`, `CombatTypes`. Variante A/B = choix entre `data/child_variant_a.tres` et `child_variant_b.tres` (aucun drapeau dans le code). Phase 2 : anticipations à 80 %, arrondies à l'image la plus proche (24 → 19). Chaque coup non paré retire `health_damage` = 1.
- 2026-11-18 — P1.2 : `ChildCombat` + `ChildInput` (boutons tenus, appuis détectés par la logique → relecture simple). Huile stockée × 60 pour des débits entiers. Choix à valider en jeu : un coup pendant l'anticipation de la relâche l'annule mais **conserve les charges** ; l'esquive et la relâche sont possibles depuis la garde ; après une parade parfaite ou une relâche, bouton tenu → garde directe.
- 2026-11-18 — P1.3 : `PostureGauge`, `DogBoss`, `Duel` (relie enfant et chien ; la couche jeu fournit « à portée » et « loin »). Choix à valider : lever la lanterne sur le chien en brèche l'apaise sans compter comme parade dans le vide ; brèche non apaisée en 2 s → le chien se relève, posture à 0, même phase ; la relâche ne touche que si l'enfant est à portée.
- 2026-11-18 — **Observation d'équilibrage** (pas de changement de données) : un joueur parfait scripté apaise le chien en **331 images (5,5 s)** dans les deux variantes — 5 parades parfaites par phase suffisent. Loin des 2 à 4 min visées : à garder en tête en jouant (posture max, posture par parade, régénération).
- 2026-11-18 — P1.4 : arène jouable (`src/scenes/arena.tscn`, chargée par `main.tscn`). Déplacements dans `src/core/arena_motion.gd` (pur, testé) ; `ArenaFight` réunit duel et déplacements, `ChildInput` porte aussi déplacement et saut (unité à enregistrer en P1.8). Valeurs proposées dans `data/arena.tres`, à régler. Choix : l'enfant fait toujours face au chien ; un saut au-dessus de `jump_clear_height` évite les attaques « devant » ; le bond du chien atterrit à mi-impact ; l'esquive part dans le sens du déplacement, sinon en arrière.

## Plus tard (hors périmètre de P1)

- Serveur MCP Godot pour donner aux agents un accès à l'éditeur.
- Pipeline des spritesheets générées (découpe, recalage, import).
