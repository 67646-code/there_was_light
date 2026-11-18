# 0002 — Logique en images, déterministe, pilotée par les données

Date : 18 novembre 2026. Statut : accepté.

## Décision

- La logique de combat vit dans `src/core/`, sans dépendance aux nœuds, et avance d'**une image physique à la fois** (60 i/s).
- Elle est **déterministe** : mêmes entrées, même résultat.
- Les valeurs de réglage sont dans des ressources `.tres` (`data/`), décrites par des classes `Resource` typées.

## Raisons

- Le combat repose sur des timings précis (fenêtres de parade en images) : les exprimer en images les rend exacts, testables et identiques sur toutes les machines.
- Le déterminisme permet d'enregistrer les entrées d'une partie et de la rejouer sans fenêtre. C'est le moyen principal pour qu'un agent reproduise un bug qu'il ne peut pas voir.
- Les données séparées du code permettent au développeur de régler le jeu dans l'éditeur sans toucher au code, et évitent que les agents modifient des réglages en passant.
