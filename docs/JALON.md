# Jalon actif — P2 : vertical slice du chien errant

> Un seul jalon actif à la fois. Ce fichier reste court : objectif, tâches, critère de sortie, notes. Jalons clos : `docs/jalons/`.

## Objectif

Rendre le combat contre le chien **jouable de bout en bout au rendu final** : personnages animés, lanterne éclairée en temps réel, décor, retours visuels et sons. Le combat de P1 est validé ; le risque principal est maintenant de savoir si des spritesheets générées par IA tiennent la cohérence et les timings dont le combat a besoin.

Références : `docs/design/art.md` (bible artistique), `docs/design/combat.md`, `docs/jalons/P1.md`.

## Tâches

- [ ] P2.0 — Compléter la bible artistique avec le développeur : échelle à l'écran (zoom de caméra ou personnages agrandis), palette, design du chien. Les points à trancher sont marqués dans `art.md`.
- [ ] P2.1 — Test de faisabilité des spritesheets (**génération faite par le développeur**, l'agent prépare les consignes et évalue) : la garde devant de l'enfant et la morsure du chien. Critères : même personnage d'une pose à l'autre, pieds sur la même ligne, poses demandées respectées, pas de lumière intégrée. Limite de temps : deux soirées par outil avant de passer au suivant (GPT Image → Nano Banana → modèle entraîné). Décision notée ci-dessous.
- [ ] P2.2 — Outil de préparation des spritesheets (`tools/sprites/`) : découpe de la grille, détourage du fond uni, recalage sur la ligne des pieds, taille normalisée, export vers `assets/`. Testé sur les images de P2.1.
- [ ] P2.3 — Animations pilotées par la logique de combat : chaque état de `src/core/` choisit une animation, et la durée de chaque pose est lue dans `data/` (la pose de tension maximale du chien tombe sur le flash de P1.9). Les rectangles restent disponibles en mode debug.
- [ ] P2.4 — Lanterne séparée et éclairage dynamique : nuit assombrie, lumière 2D de la lanterne qui suit sa direction, réagit à l'huile (vacille quand elle baisse) et flashe à la parade parfaite et à la relâche.
- [ ] P2.5 — Décor de l'arène en couches avec parallaxe (couches décrites dans `art.md`).
- [ ] P2.6 — Retours visuels manquants : changement de phase lisible, et apaisement qui révèle le vrai chien (vieux chien perdu).
- [ ] P2.7 — Sons : parade parfaite, garde, relâche (1, 2, 3 charges), coups du chien, brèche, apaisement, ambiance de forêt la nuit.

## Critère de sortie

Le combat contre le chien se joue du début à l'apaisement avec les graphismes, l'éclairage et les sons finaux, sans que le ressenti réglé en P1 se dégrade. Le développeur juge que le résultat donne envie de voir le boss suivant. Décision notée ci-dessous.

## Notes

_(Notes courtes et datées au fil du jalon.)_

- 2026-11-18 — Jalon ouvert. Direction artistique de départ : fiche de référence de l'enfant et scène d'affrontement produites par le développeur (`docs/design/references/`).

## Plus tard (hors périmètre de P2)

- Serveur MCP Godot pour donner aux agents un accès à l'éditeur.
- Généraliser le code des boss (`DogBoss`, `Duel`) au moment du deuxième boss.
- Durée des combats : à revoir pour les boss suivants (5,5 s en jeu parfait sur le chien).
- « Avancer lanterne tendue » peu utilisé en P1 : à réexaminer si un boss le rend utile.
