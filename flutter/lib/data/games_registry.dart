import 'package:flutter/material.dart';

import '../models/game.dart';

abstract final class GamesRegistry {
  static const List<Game> all = [
    Game(
      id: 'txek',
      displayName: 'Txek',
      rulesUrl: 'https://www.txek.fr/txek-faq/',
      icon: Icons.style,
    ),
    Game(
      id: 'ligretto',
      displayName: 'Ligretto',
      scoringMode: ScoringMode.ligrettoCards,
      highestWins: true,
      icon: Icons.flash_on,
      rules: [
        RuleSection(
          title: 'Présentation',
          body:
              'Ligretto est un jeu de cartes rapide et amusant qui plaira à tous ceux et '
              'toutes celles qui aiment l\'animation.',
        ),
        RuleSection(
          title: 'Joueurs',
          body:
              'De 2 à 4 joueurs à partir de 8 ans avec une seule boîte. Jusqu\'à 8 joueurs '
              'avec deux boîtes différentes, ou 12 joueurs avec la boîte bleue, verte et rouge.',
        ),
        RuleSection(
          title: 'Matériel',
          body:
              '4 jeux de 40 cartes, dont le dos porte une couleur et un motif différent '
              '(bille, pyramide, dé, cristaux). La face avant comprend des valeurs de 1 à 10 '
              'en 4 couleurs.',
        ),
        RuleSection(
          title: 'But du jeu',
          body:
              'Poser au milieu autant de cartes de la même couleur que possible, en ordre '
              'croissant (de 1 à 10), et être le premier à éliminer tout son Ligretto.',
        ),
        RuleSection(
          title: 'Préparation',
          body:
              'Chaque joueur reçoit un jeu de 40 cartes (même motif) qu\'il mélange, motif '
              'vers le haut. Il constitue ensuite :\n\n'
              '• Le Ligretto : il tire 10 cartes, à l\'envers, et les empile devant lui, '
              'chiffres vers le haut.\n'
              '• La série : il tire 3 autres cartes et les pose côte à côte à droite du '
              'Ligretto, chiffres vers le haut (5 cartes à deux joueurs, 4 cartes à trois joueurs).\n'
              '• La main : il garde le reste des cartes dans la main, motif vers le haut.',
        ),
        RuleSection(
          title: 'Déroulement de la partie',
          body:
              'Un joueur donne le signal du départ : « Ligretto ! » Tous les joueurs qui ont '
              'un 1 le posent aussitôt au milieu. Tout le monde joue en même temps et pose, '
              's\'il le peut, des cartes au milieu, en se servant des cartes du Ligretto, de '
              'la série ou de la main.\n\n'
              'Si un joueur n\'a pas de 1 sur son Ligretto ou dans sa série, il tire '
              'rapidement 3 cartes de sa main, à l\'envers, et les empile chiffres vers le '
              'haut, jusqu\'à en trouver un.\n\n'
              'Dès qu\'un 1 est posé, chaque joueur essaie d\'empiler un 2, puis un 3, etc. '
              'de la même couleur sur ce 1 ou un autre 1 déposé par un autre joueur. Une fois '
              'arrivée à 10, la pile est complète.\n\n'
              'Chaque joueur tire régulièrement trois cartes de sa main et les empile devant '
              'lui, chiffres vers le haut, de manière à ne voir que la première carte, qu\'il '
              'pose au milieu dès qu\'il le peut. Quand la main est épuisée, on reprend la '
              'pile retournée et on recommence à tirer les cartes 3 par 3.',
        ),
        RuleSection(
          title: 'Fin de partie et gagnant',
          body:
              'Le premier joueur qui a vidé son Ligretto annonce « Ligretto stop ». La '
              'partie est terminée : plus aucune carte ne peut être posée.',
        ),
        RuleSection(
          title: 'Comptage des points',
          body:
              'Les joueurs trient les cartes du milieu par motif. Chaque joueur compte les '
              'cartes présentant son motif :\n\n'
              '• Chaque carte posée au milieu compte 1 point positif (quel que soit son '
              'chiffre).\n'
              '• Chaque carte restant dans le Ligretto compte 2 points négatifs.\n'
              '• Les cartes restant dans la série ou dans la main ne sont pas comptées.\n\n'
              'Le premier joueur qui atteint 99 points positifs a gagné. Si plus personne ne '
              'peut jouer parce que toutes les cartes utiles sont déjà sur les piles de '
              'Ligretto, le joueur qui mène à ce moment-là gagne la partie.',
        ),
        RuleSection(
          title: 'Règles avancées',
          body:
              'Chaque joueur peut aussi tirer des cartes du Ligretto et de la main pour les '
              'déposer dans la série, mais seulement en ordre décroissant (par exemple un 8 '
              'sur un 9) et avec des couleurs différentes de la carte du dessous. Attention à '
              'ne pas trop garnir la série, au risque de dépouiller son Ligretto.',
        ),
      ],
    ),
  ];

  static Game? game(String id) {
    for (final game in all) {
      if (game.id == id) return game;
    }
    return null;
  }
}
