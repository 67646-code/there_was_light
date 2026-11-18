# There Was Light

Jeu 2D de combat : un enfant, une lanterne, une forêt la nuit, et des peurs qu'on apaise au lieu de les tuer.

- Concept : [docs/design/concept.md](docs/design/concept.md)
- Combat : [docs/design/combat.md](docs/design/combat.md)
- Jalon en cours : [docs/JALON.md](docs/JALON.md)
- Règles des agents : [AGENTS.md](AGENTS.md)

## Installation

Il faut **Godot 4.7.2** (version standard, pas .NET) et **gdtoolkit 4.5.0** (`gdformat`, `gdlint`).

Si Godot 4.7.2 est déjà installé, indiquer son chemin une fois pour toutes (par exemple dans `~/.bashrc`) :

```bash
export GODOT=/chemin/vers/Godot_v4.7.2-stable_linux.x86_64
pip install --user "gdtoolkit==4.5.0"
```

Sinon, `tools/setup-godot.sh` télécharge Godot dans `.tools/` et installe gdtoolkit.

Avec Godot installé en Flatpak, créer un petit script `godot` qui lance `flatpak run org.godotengine.Godot "$@"` et le placer dans le PATH (ou pointer `GODOT` dessus).

## Vérifier le projet

```bash
tools/check.sh        # tout doit finir par « TOUT EST VERT »
tools/check.sh --fix  # reformate le code puis vérifie
```

La même vérification tourne sur GitHub à chaque push sur `main` et à chaque PR.

## Ouvrir dans l'éditeur

Ouvrir `project.godot` avec Godot 4.7.2. Le plugin de tests GUT est déjà activé (panneau en bas de l'éditeur).
