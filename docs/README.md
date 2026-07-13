# Présentation DaPoint

Ce dossier contient la page de présentation statique, l'appli web jouable dans le navigateur, et les builds de release.

## Structure

- `index.html` : page principale générée automatiquement.
- `styles.css` : styles visuels inspirés du logo DaPoint.
- `favicon.svg` : favicon du site de présentation.
- `logo.svg` : logo visible dans la page.
- `appli/` : build web Flutter (jouable directement dans le navigateur), généré par `build_release.sh`.
- `releases/` : APK versionnés à télécharger.
- `build_release.sh` : script qui build l'APK + le web, versionne l'APK, et régénère la page.
- `generate_site.py` : script de génération de la page (appelé automatiquement par `build_release.sh`).

## Utilisation

1. Ajoutez ou mettez à jour un jeu dans `ios/DaPoint/GamesRegistry.swift` ou `flutter/lib/data/games_registry.dart`.
2. Depuis la racine du projet, lancez :

```bash
docs/build_release.sh
```

Ce script :
- compile l'APK release Flutter et le copie versionné (nom + horodatage) dans `docs/releases/` ;
- compile la version web Flutter et la copie dans `docs/appli/` (avec le bon `--base-href` pour GitHub Pages) ;
- régénère `docs/index.html`.

Si vous utilisez la tâche VS Code, lancez `Flutter: build release (APK + web, versioned)`.

3. Publiez la page avec GitHub Pages en utilisant `docs/` comme dossier source.

## Points importants

- La page affiche automatiquement les jeux détectés dans les registres iOS et Flutter.
- Les liens de téléchargement APK sont générés depuis le dossier `docs/releases`.
- Le lien "Essayer dans le navigateur" pointe vers `docs/appli/` et n'apparaît que si ce dossier existe (build web déjà généré).
- Le favicon de l'appli web (`flutter/web/favicon.png` et `flutter/web/icons/`) est généré depuis `flutter/assets/icon/icon.png` via `flutter_launcher_icons` (voir la section `web:` dans `flutter/pubspec.yaml`) — relancez `dart run flutter_launcher_icons` dans `flutter/` si le logo change.
- La favicon et le logo de la page de présentation (`favicon.svg`, `logo.svg`) sont fournis dans ce dossier.
