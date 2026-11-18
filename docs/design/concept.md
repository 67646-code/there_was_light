# Concept

> État au 18 novembre 2026. Les points marqués **(décidé)** ont été choisis par le développeur ; les autres sont des propositions à valider.

## Pitch

Un enfant s'aventure dans une forêt la nuit, armé d'une seule lanterne. Les monstres qu'il affronte sont ses peurs d'enfant. Trop petit pour encaisser, il tend sa lanterne comme un rempart et **dévie** leurs attaques au bon moment. Chaque parade laisse entrevoir ce que le monstre est vraiment. Quand sa posture cède, l'enfant ne le tue pas : la peur se dissipe et il ne reste que la chose ordinaire qu'elle cachait.

## Décisions

- Jeu 2D centré sur le combat, dans l'esprit de Nine Sols **(décidé)**.
- On joue un enfant qui affronte des monstres dans une forêt **(décidé)**.
- Les monstres sont des **peurs d'enfant universelles** (chien errant, sorcière dans sa hutte, gros crapaud qui croasse la nuit…) **(décidé)**.
- **Apaiser plutôt que tuer** **(décidé)**.
- **L'enfant n'attaque pas** : la lanterne est un rempart, et c'est la lumière qui agit (boucle « tenir, charger, relâcher ») **(décidé)**.
- Sprites générés avec GPT Image (spritesheets) ; style graphique **à définir** **(décidé : abandon du pixel art fait main)**.

## Piliers (proposés)

1. **Petit contre grand** : on ne gagne pas en encaissant, mais en déviant au bon moment.
2. **La lumière comme ressource** : la lanterne sert à parer, à révéler et à explorer, et elle peut s'épuiser.
3. **Apaiser, pas tuer** : chaque boss est une peur qu'on finit par comprendre.

Toute fonctionnalité doit servir au moins un pilier.

## Périmètre (proposé)

- **Boss rush avec un petit hub** (chambre de l'enfant ou cabane en lisière) : 4 à 6 boss, quelques ennemis normaux, **2 à 4 h de jeu**.
- Hors périmètre pour l'instant : grand monde interconnecté, narration scénarisée.

## Boss envisagés

| Peur | Ce qu'elle est vraiment | Ce que le combat apprend |
|---|---|---|
| Le chien errant | Un vieux chien perdu qui a faim | Parade de base (boss tutoriel) |
| Le gros crapaud | Un simple crapaud, vu de près dans le noir | Gestion de la lanterne, attaques vers le sol |
| La sorcière dans sa hutte | Une vieille dame seule qui ramasse des herbes | Lecture des feintes |
| Le hibou aux yeux qui brillent | Un hibou dont les yeux reflètent la lanterne | Attaques venues d'en haut |
| L'arbre qui bouge la nuit | Un vieil arbre, du vent, des ombres | Gestion de l'espace |
| Le loup (final) | À définir | Tout, combiné |

## Questions ouvertes

Titre définitif (« There Was Light » est le nom du dépôt), style graphique, nature du loup final, hub (chambre ou cabane).
