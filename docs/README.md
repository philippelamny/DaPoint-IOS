# Présentation DaPoint

Ce dossier contient la page de présentation statique et les builds de release.

## Structure

- `index.html` : page principale générée automatiquement.
- `styles.css` : styles visuels inspirés du logo DaPoint.
- `favicon.svg` : favicon du site.
- `logo.svg` : logo visible dans la page.
- `releases/` : emplacement des builds à télécharger.
- `generate_site.py` : script de génération de la page.

## Utilisation

1. Ajoutez ou mettez à jour un jeu dans `ios/DaPoint/GamesRegistry.swift`.
2. Ajoutez les fichiers de build dans `docs/releases/`.
3. Exécutez :

```bash
cd docs
python3 generate_site.py
```

Si vous utilisez la tâche VS Code, la commande `Flutter: build APK (release, versioned)` copiera automatiquement l’APK généré dans `docs/releases/` puis mettra à jour `docs/index.html`.

4. Publiez la page avec GitHub Pages en utilisant `docs/` comme dossier source.

## Points importants

- La page affiche automatiquement les jeux détectés dans le registre Swift.
- Les liens de téléchargement sont générés depuis le dossier `docs/releases`.
- La favicon et le logo sont fournis dans ce dossier.
