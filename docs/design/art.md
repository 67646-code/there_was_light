# Bible artistique — v0

> 18 novembre 2026. Les points marqués **(décidé)** ont été choisis par le développeur ; les autres sont des propositions à confirmer en P2.0. Les spritesheets sont générées par IA (GPT Image ; replis : Nano Banana, puis un modèle entraîné sur le style).

## Références

| Fichier | Rôle |
|---|---|
| `references/enfant-fiche-reference.jpg` | Fiche de référence de l'enfant : silhouette, costume, lanterne, expressions. **Source d'identité** à fournir à chaque génération. |
| `references/affrontement-chien.jpg` | Ambiance générale et **pose de référence du jeu** (bras tendu, lanterne en rempart face au monstre). |

Ces deux images ont été produites par le développeur lors d'une exploration visuelle **(décidé : direction retenue)**.

## Style

- Illustration 2D encrée : contours sombres marqués, aplats avec un ombrage simple, textures légères.
- Proportions enfantines (grosse tête, petit corps), lisibles même en petit.
- **Contraste chaud et froid** : nuit bleu-vert sombre, lumière ambre de la lanterne. La lumière chaude est la seule source « vivante » de l'écran.
- **L'écharpe rouge** est l'accent de couleur de l'enfant et porte le mouvement : elle flotte à l'esquive et à la relâche, retombe quand il est sonné.
- Le cadre papier et les titres des illustrations ne vont **pas** dans le jeu.

### Palette de départ (à affiner)

| Rôle | Teinte |
|---|---|
| Nuit, fonds lointains | bleu-vert très sombre |
| Végétation, sol | bruns et verts désaturés |
| Lumière de lanterne | ambre / orangé chaud |
| Écharpe | rouge |
| Éléments magiques de la forêt (champignons) | bleu clair luminescent, avec parcimonie |
| Yeux et menaces des monstres | jaune-orangé |

## Règles de génération des sprites

1. **Aucune lumière intégrée.** Pas de lueur de lanterne peinte sur le personnage ni sur le sol : l'éclairage est fait par Godot (lumières 2D dans une nuit assombrie). Éclairage neutre et uniforme sur les sprites.
2. **La lanterne est un sprite séparé.** L'enfant est généré la main fermée (vide), la lanterne s'accroche à un point de la main. Les variantes de bras (devant, en haut, vers le bas) restent dans l'animation de l'enfant.
3. **Fond uni** d'une couleur qui n'apparaît pas dans le personnage (pour le détourage), ou transparent si l'outil le permet.
4. **Orientation unique** : personnage tourné vers la droite (le jeu retourne l'image).
5. **Grille régulière**, une pose par case, **pieds sur la même ligne** dans chaque case, même échelle sur toutes les feuilles.
6. **Peu de poses, tenues longtemps** (animation limitée) : 2 à 6 poses par animation. Le jeu tient chaque pose le nombre d'images défini dans `data/`, pour que les timings du combat restent pilotés par les données.
7. Chaque génération reçoit la fiche de référence et la liste exacte des poses (une phrase par case).

## Échelle à l'écran (à trancher en P2.0)

Au prototype, l'enfant mesure **90 px** de haut et le chien 140 × 80 px dans une vue de 1920 × 1080. C'est petit pour ce style détaillé. Options : rapprocher la caméra (zoom) ou agrandir l'arène et les personnages. Dans tous les cas, générer les sprites **au double de leur taille finale** pour garder de la marge.

## Animations nécessaires pour la vertical slice

### L'enfant

| Animation | Poses | Notes |
|---|---|---|
| Repos | 2–4 (boucle) | Respiration, écharpe qui bouge |
| Marche | 6 (boucle) | |
| Saut | 3 | Impulsion, en l'air, réception |
| Esquive | 3 | Écharpe très marquée |
| Garde devant | 2 | Lever la lanterne, tenir bras tendu (pose de `affrontement-chien.jpg`) |
| Garde en haut | 2 | Bras levé au-dessus de la tête |
| Garde vers le bas | 2 | Bras tendu vers le sol |
| Relâche | 3 | Tension, éclair, retour |
| Touché | 2 | Recul |
| Garde brisée / sonné | 3 (boucle) | Fatigué, lanterne qui pend |
| Apaisement | 2 | Lever la lanterne haut, tenir |

La parade parfaite et la parade dans le vide réutilisent les poses de garde ; leur différence passe par la lumière, le gel et les sons.

### Le chien errant

| Animation | Poses | Notes |
|---|---|---|
| Repos / grognement | 3–4 (boucle) | |
| Marche | 4–6 (boucle) | |
| Morsure | 4 | Se ramasse, tension maximale (moment du flash), mord, revient. Réutilisée par la rafale |
| Morsure retardée (feinte) | 5 | Comme la morsure, avec une pose d'hésitation |
| Bond | 4 | S'aplatit, saute, retombe (impact), se relève |
| Touché par la relâche | 2 | |
| Brèche (sonné) | 2–3 (boucle) | |
| Changement de phase | 2–3 | |
| Apaisement | 3–4 | La peur se dissipe et révèle le vrai chien : un **vieux chien perdu**, assis ou couché, calme |

### Proposition de design du chien

Le chien de l'exploration ressemble à un loup, et le loup est réservé au boss final. Proposition : un **collier abîmé avec une médaille**, des oreilles et une queue de chien, une silhouette plus trapue que celle du loup. Le collier raconte l'histoire du boss : ce n'est pas une bête sauvage, c'est un chien qui a été perdu. À l'apaisement, la lumière fait briller la médaille.

## Décor de l'arène

Plusieurs couches séparées, générées une par une à la même taille, pour la parallaxe :

1. Ciel et lune (lointain).
2. Silhouettes d'arbres et ruines (lointain).
3. Arbres et végétation (plan moyen).
4. Sol de l'arène, plat et lisible.
5. Herbes et feuilles au premier plan (devant les personnages, légèrement floues ou sombres).

Pas de lumière chaude peinte dans le décor : c'est la lanterne qui l'éclaire en jeu.
