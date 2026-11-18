# Combat — fiche v0

> Valeurs de départ proposées le 18 novembre 2026, **non testées**. Elles sont faites pour être réglées manette en main. Dans le jeu, elles vivent dans `data/*.tres` ; ce document décrit les intentions et doit rester cohérent avec ces fichiers.

Convention : durées en **images à 60 i/s** (entre parenthèses, en millisecondes).

## 1. Les deux ressources de la lanterne

| Ressource | Rôle | Valeurs v0 |
|---|---|---|
| **Huile** | Endurance : tenir la garde, avancer, rater des parades | 100 max ; regagne 8/s quand la lanterne n'est pas tendue |
| **Lumière** | Munition : se gagne en parant, se dépense en relâchant | 3 charges max |

L'huile se perd quand on joue mal ; la lumière se gagne quand on joue bien.

## 2. Actions de l'enfant

| Action | Fonctionnement | Valeurs v0 |
|---|---|---|
| **Parade parfaite** | Appui sur « lanterne » juste avant l'impact | Fenêtre : 8 images (133 ms) après l'appui. Huile : 0. **+1 charge.** Posture infligée : 8 |
| **Garde** | Lanterne maintenue, impact hors fenêtre parfaite | Aucun dégât de santé. Huile : −15. Pas de lumière |
| **Parade dans le vide** | Appui sans attaque à parer | 20 images (333 ms) de récupération vulnérable. Huile : −5 |
| **Direction** | Lanterne devant (neutre), en haut ou vers le bas | Mauvaise direction = garde |
| **Relâche** | Libère **toutes** les charges | Posture : 1 charge = 15, 2 = 35, 3 = 60. Anticipation de 10 images (167 ms), exposé |
| **Avancer lanterne tendue** | Garde + déplacement vers le monstre | Vitesse 50 %. Huile : −15/s. Repousse le monstre et **bloque la régénération de sa posture** |
| **Esquive** | Petit bond rapide | 12 images d'invulnérabilité (200 ms), réutilisable après 30 images (500 ms), gratuite |
| **Saut** | Saut simple | Pas d'action en l'air au prototype |

- **Huile à zéro** : garde brisée, l'enfant est sonné 60 images (1 s) et ne peut plus parer avant de remonter à 20.
- **Santé** : 5 points. Un coup non paré enlève 1 point, puis 45 images (750 ms) d'invulnérabilité.

**Le choix recherché** : relâcher tout de suite pour soulager la pression, ou tenir pour une grosse relâche (gain plus que proportionnel) au risque d'être touché.

## 3. Posture des monstres

- Jauge de 0 à 100 qui **monte** avec la posture infligée.
- Régénération : −10/s après 2 s sans pression (bloquée tant que la lanterne avance sur lui).
- À 100 : **brèche**. Monstre sonné 120 images (2 s) ; l'enfant lève la lanterne pour l'**apaiser** (fin de phase ou du combat).

## 4. Premier boss : le chien errant

Deux phases, chacune terminée par une brèche.

| Attaque | Anticipation | Impact | Récupération |
|---|---|---|---|
| Morsure | 24 images (400 ms) | 6 | 30 |
| Rafale de 3 morsures | 20, puis 14 images (233 ms) entre chaque | 6 chacune | 40 |
| Bond (à distance) | 30 images (500 ms) | 8 | 36 |
| Morsure retardée (phase 2, feinte) | 36 images (600 ms) avec hésitation | 6 | 30 |

Phase 2 : anticipations réduites de 20 %. Durée visée : 2 à 4 minutes.

## 5. Questions pour le prototype

1. Variante A (parade seule, posture 20 par parade parfaite, pas de relâche) contre variante B (cette fiche) : laquelle est la plus amusante ?
2. 24 images d'anticipation sont-elles lisibles avec de simples rectangles ?
3. Le choix « relâcher maintenant ou tenir » existe-t-il en jeu ?
4. Avancer lanterne tendue est-il utile ?
5. L'huile ajoute-t-elle de la tension ou seulement de la frustration ?
