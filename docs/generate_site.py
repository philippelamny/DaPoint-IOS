#!/usr/bin/env python3
from pathlib import Path
import re
from datetime import datetime

ROOT = Path(__file__).resolve().parent
REPO_ROOT = ROOT.parent
SWIFT_REGISTRY = REPO_ROOT / 'ios' / 'DaPoint' / 'GamesRegistry.swift'
DART_REGISTRY = REPO_ROOT / 'flutter' / 'lib' / 'data' / 'games_registry.dart'
PUBSPEC = REPO_ROOT / 'flutter' / 'pubspec.yaml'
OUTPUT = ROOT / 'index.html'
GITHUB_URL = 'https://github.com/philippelamny/DaPoint-IOS'
README_URL = GITHUB_URL + '/blob/main/README.md'

IOS_GAME_PATTERN = re.compile(
    r"Game\(id:\s*\"(?P<id>[^\"]+)\",\s*displayName:\s*\"(?P<displayName>[^\"]+)\",\s*rulesURL:\s*(?:URL\(string:\s*\"(?P<rules>[^\"]*)\"\)|nil)\)"
)
DART_ID_PATTERN = re.compile(r"id:\s*['\"](?P<id>[^'\"]+)['\"]")
DART_NAME_PATTERN = re.compile(r"displayName:\s*['\"](?P<displayName>[^'\"]+)['\"]")
DART_RULES_PATTERN = re.compile(r"rulesUrl:\s*['\"](?P<rules>[^'\"]+)['\"]")
VERSION_PATTERN = re.compile(r'^version:\s*([0-9]+(?:\.[0-9]+)*(?:\+[0-9]+)?)', re.MULTILINE)


def parse_ios_games():
    if not SWIFT_REGISTRY.exists():
        return []
    text = SWIFT_REGISTRY.read_text(encoding='utf-8')
    games = []
    for match in IOS_GAME_PATTERN.finditer(text):
        games.append({
            'id': match.group('id'),
            'name': match.group('displayName'),
            'rules': match.group('rules') or None,
        })
    return games


def parse_flutter_games():
    if not DART_REGISTRY.exists():
        return []
    text = DART_REGISTRY.read_text(encoding='utf-8')
    games = []
    lines = text.splitlines()
    index = 0
    while index < len(lines):
        line = lines[index]
        if 'Game(' in line:
            block = [line]
            depth = line.count('(') - line.count(')')
            index += 1
            while depth > 0 and index < len(lines):
                line = lines[index]
                block.append(line)
                depth += line.count('(') - line.count(')')
                index += 1
            block_text = '\n'.join(block)
            game_id = None
            display_name = None
            rules_url = None
            id_match = DART_ID_PATTERN.search(block_text)
            if id_match:
                game_id = id_match.group('id')
            name_match = DART_NAME_PATTERN.search(block_text)
            if name_match:
                display_name = name_match.group('displayName')
            rules_match = DART_RULES_PATTERN.search(block_text)
            if rules_match:
                rules_url = rules_match.group('rules')
            if game_id and display_name:
                games.append({
                    'id': game_id,
                    'name': display_name,
                    'rules': rules_url,
                })
        else:
            index += 1
    return games


def parse_games():
    games = {}
    for game in parse_ios_games() + parse_flutter_games():
        if game['id'] not in games:
            games[game['id']] = game
    return sorted(games.values(), key=lambda item: item['name'])


def parse_version():
    if not PUBSPEC.exists():
        return '0.0.0+0'
    text = PUBSPEC.read_text(encoding='utf-8')
    match = VERSION_PATTERN.search(text)
    return match.group(1) if match else '0.0.0+0'


def parse_build_timestamp(file_name):
    match = re.search(r'([0-9]{8}-[0-9]{4})', file_name)
    if not match:
        return None
    dt = datetime.strptime(match.group(1), '%Y%m%d-%H%M')
    return dt.strftime('%Y-%m-%d %H:%M')


def list_releases():
    release_dir = ROOT / 'releases'
    if not release_dir.exists():
        return []
    files = [p for p in release_dir.iterdir() if p.is_file()]
    files.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    return files


def list_screenshots():
    screenshot_dir = ROOT / 'screenshots'
    if not screenshot_dir.exists():
        return []
    files = [p for p in screenshot_dir.iterdir() if p.is_file() and p.suffix.lower() in {'.png', '.jpg', '.jpeg', '.webp'}]
    files.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    # Prioritize the new Serre de Nancy score-entry screenshot first, then other score-entry screenshots.
    files.sort(key=lambda p: 0 if 'serre_de_nancy' in p.name else (1 if 'score_entry' in p.name else 2))
    return files


def build_html(games, version, releases):
    updated = datetime.now().strftime('%Y-%m-%d %H:%M')
    if releases:
        latest_date = parse_build_timestamp(releases[0].name)
        if latest_date:
            updated = latest_date
    release_items = []
    if releases:
        for path in releases:
            rel = path.name
            size = path.stat().st_size
            mb = size / 1024 / 1024
            release_items.append(f'<li><a href="releases/{rel}">{rel}</a> — {mb:.2f} MB</li>')
    else:
        release_items.append('<li>Aucun build disponible pour le moment. Déposez les fichiers dans <code>docs/releases</code> puis relancez <code>generate_site.py</code>.</li>')

    screenshot_items = []
    screenshot_files = list_screenshots()
    if screenshot_files:
        for screenshot in screenshot_files:
            screenshot_items.append(f'<div class="screen-card"><img src="screenshots/{screenshot.name}" alt="Capture d\'écran DaPoint" /></div>')
    else:
        screenshot_items.append('<div class="screen-card"><p>Aucune capture d\'écran disponible. Lancez l\'application sur l\'émulateur et capturez un screenshot dans <code>docs/screenshots</code>.</p></div>')

    game_items = []
    if games:
        for game in games:
            if game['rules']:
                game_items.append(f'<li><strong>{game["name"]}</strong> — <a href="{game["rules"]}" target="_blank" rel="noopener">Règles officielles</a></li>')
            else:
                game_items.append(f'<li><strong>{game["name"]}</strong></li>')
    else:
        game_items.append('<li>Aucun jeu enregistré pour le moment.</li>')

    return f'''<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta name="theme-color" content="#2E42D3" />
  <meta name="description" content="DaPoint — suivi de score pour Txek et Ligretto. iOS bientôt disponible, Android bientôt sur Google Play." />
  <title>DaPoint — Présentation</title>
  <link rel="icon" href="favicon.svg" type="image/svg+xml" />
  <link rel="stylesheet" href="styles.css" />
</head>
<body>
  <main>
    <section class="hero">
      <div class="hero-brand">
        <img src="logo.svg" alt="Logo DaPoint" class="hero-logo" />
        <div>
          <p class="eyebrow">Application DaPoint</p>
          <h1>Gestion simple des scores pour Txek et Ligretto</h1>
          <p class="subtitle">Compatible avec les deux jeux déjà disponibles, et prête à accueillir de nouveaux favoris.</p>
        </div>
      </div>
      <div class="hero-badges">
        <span>Version {version}</span>
        <span>Dernière génération: {updated}</span>
      </div>
    </section>

    <section>
      <h2>Ce qu’il faut savoir</h2>
      <p>DaPoint est un suivi de score dédié aux parties entre amis. L’application est déjà prête pour Txek et Ligretto, avec un design orienté facilité d’utilisation et mise à jour automatique.</p>
      <ul>
        <li>Deux jeux déjà pris en charge : <strong>Txek</strong> et <strong>Ligretto</strong>.</li>
        <li>iOS n’est pas encore disponible sur l’App Store.</li>
        <li>Google Play est prévu très bientôt.</li>
      </ul>
    </section>

    <section class="screens">
      <h2>Aperçu</h2>
      <div class="screens-grid">
        <div class="screen-card">
          <img src="screen-live-game.svg" alt="Partie en cours DaPoint" />
        </div>
        {''.join(screenshot_items)}
      </div>
    </section>

    <section>
      <div class="section-grid">
        <div>
          <h2>Jeux disponibles</h2>
          <p>Les titres listés ci-dessous sont déjà intégrés dans l’application :</p>
          <ul class="link-list">
            {''.join(game_items)}
          </ul>
        </div>

        <div>
          <h2>Builds & téléchargements</h2>
          <ul class="link-list">
            {''.join(release_items)}
          </ul>
        </div>
      </div>
    </section>

    <section>
      <h2>Installer l’APK</h2>
      <p>Si l’application n’est pas encore disponible sur Google Play, vous pouvez installer le fichier APK manuellement.</p>
      <ul>
        <li>Téléchargez l’APK depuis la section <strong>Builds & téléchargements</strong>.</li>
        <li>Ouvrez le fichier sur votre appareil Android.</li>
        <li>Autorisez l’installation depuis des sources externes si nécessaire : Paramètres > Sécurité > Installer des applications inconnues.</li>
        <li>Acceptez l’installation et lancez l’application.</li>
      </ul>
      <p>Cela fonctionne tant que le système accepte l’APK et que les permissions sont activées sur l’appareil.</p>
    </section>

    <section class="callout">
      <h2>Sources et documentations</h2>
      <p>Le code source est disponible sur <a href="{GITHUB_URL}" target="_blank" rel="noopener">GitHub</a> et le <a href="{README_URL}" target="_blank" rel="noopener">README principal</a> décrit le projet et les étapes de build.</p>
      <p>Pour mettre à jour la page : placez un build dans <code>docs/releases</code>, puis lancez la tâche VS Code suivante :</p>
      <pre>Flutter: build APK (release, versioned)</pre>
    </section>

    <section class="contact-block">
      <h2>Contact</h2>
      <p>Pour toute demande d’évolution, écris-moi à :</p>
      <p class="contact-link"><a href="mailto:philippe.lam.ny@gmail.com?subject=Demande%20d%27%C3%A9volution">philippe.lam.ny@gmail.com</a></p>
    </section>
  </main>
</body>
</html>
'''


def main():
    games = parse_games()
    version = parse_version()
    releases = list_releases()
    html = build_html(games, version, releases)
    OUTPUT.write_text(html, encoding='utf-8')
    print(f'Généré {OUTPUT.relative_to(ROOT)} — {len(games)} jeu(x), {len(releases)} build(s)')


if __name__ == '__main__':
    main()
