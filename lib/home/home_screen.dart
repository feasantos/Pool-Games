import 'package:flutter/material.dart';
import '../shared/widgets/game_card.dart';
import '../shared/theme/app_theme.dart';
import '../games/tic_tac_toe/tic_tac_toe_screen.dart';
import '../games/solitaire/solitaire_screen.dart';
import '../games/truco/truco_screen.dart';
import '../games/tranca/tranca_screen.dart';
import '../games/ping_pong/ping_pong_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _games = [
    (
      title: 'Jogo da Velha',
      description: 'Clássico X e O\n1 ou 2 jogadores',
      icon: Icons.grid_3x3,
      route: 'tictactoe',
    ),
    (
      title: 'Paciência',
      description: 'Solitaire clássico\n1 jogador',
      icon: Icons.style,
      route: 'solitaire',
    ),
    (
      title: 'Truco',
      description: 'Truco paulista\n2 a 4 jogadores',
      icon: Icons.casino,
      route: 'truco',
    ),
    (
      title: 'Tranca',
      description: 'Jogo de cartas\n2 a 4 jogadores',
      icon: Icons.layers,
      route: 'tranca',
    ),
    (
      title: 'Ping Pong',
      description: 'Pong clássico\n1 ou 2 jogadores',
      icon: Icons.sports_tennis,
      route: 'pingpong',
    ),
  ];

  void _navigate(BuildContext context, String route) {
    final destinations = {
      'tictactoe': const TicTacToeScreen(),
      'solitaire': const SolitaireScreen(),
      'truco': const TrucoScreen(),
      'tranca': const TrancaScreen(),
      'pingpong': const PingPongScreen(),
    };
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => destinations[route]!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Game Pool',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Escolha um jogo',
              style: TextStyle(
                color: AppTheme.textLight.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: _games.length,
                itemBuilder: (context, index) {
                  final game = _games[index];
                  return GameCard(
                    title: game.title,
                    description: game.description,
                    icon: game.icon,
                    onTap: () => _navigate(context, game.route),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
