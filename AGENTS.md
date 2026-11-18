# AGENTS.md — There Was Light

Règles pour tout agent qui travaille sur ce dépôt (Claude Code, Codex…). Ce fichier fait foi ; `CLAUDE.md` ne fait qu'y renvoyer.

## Le projet en bref

Jeu 2D d'action centré sur le combat, dans l'esprit de Nine Sols. Un enfant traverse une forêt la nuit avec une lanterne ; les monstres sont ses peurs. **L'enfant n'attaque jamais** : il pare avec la lanterne, accumule de la lumière et la relâche pour faire céder la posture des monstres, qu'il apaise au lieu de les tuer.

- Concept et piliers : `docs/design/concept.md`
- Combat (actions, valeurs, boss) : `docs/design/combat.md`
- **Jalon actif : `docs/JALON.md` — à lire avant toute tâche.**
- Décisions d'architecture : `docs/decisions/`

## Commandes

| Commande | Rôle |
|---|---|
| `tools/check.sh` | Vérification complète : import, chargement de tous les scripts, format, lint, tests, lancement du jeu. **Doit passer avant tout commit.** |
| `tools/check.sh --fix` | Reformate le code avec gdformat, puis vérifie. |
| `tools/setup-godot.sh` | Installe Godot (version de `tools/godot-version`) et gdtoolkit dans `.tools/` si la machine ne les a pas. |

Godot utilisé : `$GODOT`, sinon `godot` dans le PATH, sinon `.tools/godot/godot`. La version est épinglée (**4.7.2**) ; `check.sh` refuse toute autre version.

Les journaux détaillés sont dans `.test-results/` (`import.log`, `scripts.log`, `tests.log`, `boot.log`).

## Définition de « terminé »

Une tâche est terminée quand :
1. `tools/check.sh` affiche « TOUT EST VERT » ;
2. la logique nouvelle ou modifiée est couverte par des tests ;
3. `docs/JALON.md` est à jour (case cochée, notes courtes) ;
4. le compte rendu final indique : ce qui a changé, le résultat de `check.sh`, et **ce que l'humain doit tester manette en main**.

Ne jamais déclarer une tâche terminée sur la seule base de « ça compile ».

## Architecture

```
src/core/    Logique pure (classes RefCounted / Resource) : combat, posture, ressources.
             Aucune dépendance aux nœuds, à l'affichage ou aux entrées. Entièrement testable.
src/game/    Nœuds qui lisent les entrées, font avancer la logique et l'affichent.
src/scenes/  Scènes .tscn.
data/        Valeurs de jeu en ressources .tres (attaques, boss, réglages du joueur).
tests/       Tests GUT (tests/unit pour src/core).
tools/       Scripts de vérification et d'installation.
docs/        Conception, jalon actif, décisions.
```

Principes :
- **La logique de combat compte en images, pas en secondes.** Elle avance d'un pas par image physique (60 i/s) via une méthode du type `tick()`. Pas de `delta`, pas de `Time.get_ticks_*` dans `src/core/`.
- **Déterminisme.** Mêmes entrées, même résultat. Tout aléatoire passe par un `RandomNumberGenerator` à graine explicite. C'est ce qui permettra d'enregistrer et de rejouer des parties.
- **Données hors du code.** Durées, fenêtres, coûts et dégâts vivent dans `data/*.tres`, décrits par des classes `Resource` typées de `src/core/`. Aucune valeur de réglage en dur dans le code.
- **Sens des dépendances :** `src/game` dépend de `src/core`, jamais l'inverse. Un nœud appelle ses enfants ; un enfant prévient son parent par signal.
- Références entre nœuds par `@export` ou `%NomUnique`, jamais par chemin long (`get_node("../../X")`).

## Conventions de code

- **GDScript typé partout.** Les variables non typées sont des erreurs de compilation (réglage du projet). `:=` est permis quand le type est évident.
- Identifiants en anglais ; commentaires, docs et messages de commit en français.
- `class_name` pour les classes réutilisées. Un fichier = une responsabilité ; au-delà de ~300 lignes, découper.
- Format et lint : gdformat et gdlint (configuration dans `gdlintrc`). Ne pas les contourner avec des commentaires de désactivation sans le justifier.
- Tests : un fichier `tests/unit/test_<sujet>.gd` par classe de `src/core/`. Les tests de combat décrivent des scénarios en images (« le chien mord à l'image 24, parade à l'image 20 → parade parfaite »).

## Spécificités Godot

- Ne jamais modifier `.godot/` (cache local, ignoré par Git).
- Godot crée un fichier `.uid` à côté de chaque script et un `.import` à côté de chaque asset : **les commiter avec leur fichier**, et les déplacer ou renommer avec lui.
- Les scènes `.tscn` sont du texte : les modifications simples à la main sont permises, mais garder les scènes petites et composées. Si une scène devient complexe à éditer à la main, le signaler plutôt que de la réécrire en entier.
- `addons/gut/` est une dépendance tierce figée : ne pas la modifier.

## Ce qu'il faut demander avant de faire

- Modifier `project.godot` (réglages, entrées, autoloads), la version de Godot ou les outils.
- Ajouter un addon ou une dépendance.
- Changer l'architecture ou un principe ci-dessus : rédiger d'abord une note dans `docs/decisions/`.
- **Changer une valeur de réglage dans `data/`** : ces valeurs sont réglées par l'humain en jouant. Un agent peut proposer, pas modifier en silence.
- Supprimer ou réécrire largement un système existant.

## Façon de travailler

- Lire `docs/JALON.md` avant de commencer. Ne travailler que sur le jalon actif ; noter les idées hors périmètre dans la section « Plus tard » du jalon, sans les implémenter.
- **Une tâche = une branche = une PR.** Pas de commit direct sur `main`. Branches : `p1/parade-parfaite`, `fix/…`, `docs/…`.
- **CI verte avant toute fusion.** `main` n'est pas protégée côté GitHub : c'est l'agent qui garde la porte. Après avoir poussé la branche et ouvert la PR (`gh pr create`), attendre la fin de la CI avec `gh pr checks <n> --watch`. Si elle échoue, lire les journaux (`gh run view --log-failed`), corriger, repousser. Quand `check.sh` est vert en local **et** la CI verte, l'agent peut, sans demander : pousser sa branche et ses tags, fusionner la PR (`gh pr merge <n> --merge --delete-branch`), puis mettre `main` à jour en local (`git switch main && git pull --ff-only`). Ne jamais fusionner une PR dont la CI est rouge ou en cours, ni pousser directement sur `main`.
- **Un tag par tâche terminée.** Après la fusion dans `main`, poser un tag annoté sur le commit de fusion, nommé d'après l'identifiant de la tâche du jalon : `git tag -a p1.2 -m "P1.2 — Logique pure de l'enfant"` puis `git push origin p1.2`. Correctif hors tâche : `p1.2-fix1`. Ne jamais déplacer ni supprimer un tag publié.
- Petits pas : chaque commit laisse `check.sh` au vert.
- Ne pas multiplier les documents. Mettre à jour l'existant ; un seul jalon actif ; pas de rapports d'audit commités sauf demande.
- En cas de doute sur une intention de design, demander plutôt que deviner.
