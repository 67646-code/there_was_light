# Jalon actif — P1 : prototype en boîtes grises

> Un seul jalon actif à la fois. Ce fichier reste court : objectif, tâches, critère de sortie, notes.

## Objectif

Savoir si le combat « tenir, charger, relâcher » est amusant **sans aucun graphisme** : un rectangle enfant contre un rectangle chien, dans une arène plate. Le code de ce jalon peut être jeté ; ce qui compte, c'est ce qu'on apprend.

Référence : `docs/design/combat.md`.

## Tâches

- [ ] P1.0 — Proposer les entrées (clavier et manette) à ajouter à `project.godot` ; les ajouter après accord.
- [ ] P1.1 — Classes de données (`src/core/`) et premières ressources (`data/`) : réglages de l'enfant, attaque, boss. Valeurs de `combat.md`.
- [ ] P1.2 — Logique pure de l'enfant, image par image : huile, lumière, parade parfaite, garde, parade dans le vide, relâche, santé. Tests par scénarios.
- [ ] P1.3 — Logique pure du chien : enchaînement des attaques (anticipation, impact, récupération), posture, brèche, deux phases. Tests.
- [ ] P1.4 — Arène jouable : rectangles, déplacement, saut, esquive, direction de la lanterne. Le rectangle du chien change de couleur pendant l'anticipation.
- [ ] P1.5 — Retour d'impact : hitstop, recul, tremblement d'écran, sons provisoires.
- [ ] P1.6 — Affichage de debug (activable) : huile, lumière, posture, état courant, fenêtre de parade.
- [ ] P1.7 — Interrupteur variante A / variante B pour le test comparatif.
- [ ] P1.8 — Enregistrement et relecture des entrées d'une partie (pour reproduire un bug ou un ressenti).

## Critère de sortie

Le développeur a joué les deux variantes et répondu aux cinq questions de `combat.md`. Décision notée ci-dessous : continuer, ajuster ou repenser le combat.

## Notes

_(Notes courtes et datées au fil du jalon.)_

## Plus tard (hors périmètre de P1)

- Serveur MCP Godot pour donner aux agents un accès à l'éditeur.
- Pipeline des spritesheets générées (découpe, recalage, import).
