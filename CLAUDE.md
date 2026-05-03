# Pool Games — Contexto do Projeto

## Stack
Flutter / Dart. App mobile (Android/iOS) com suporte a Web/Desktop via builds extras.

## Estrutura de pastas
```
lib/
  main.dart                        # MaterialApp + AppTheme.dark + HomeScreen
  home/
    home_screen.dart               # Grid de jogos; adicionar jogo aqui
  games/
    tic_tac_toe/
      tic_tac_toe_game.dart        # Lógica + Minimax AI
      tic_tac_toe_screen.dart      # UI
    solitaire/
      solitaire_game.dart          # Klondike
      solitaire_screen.dart
      card_model.dart
      card_widget.dart
    ping_pong/
      ping_pong_game.dart          # Física + AI da CPU
      ping_pong_screen.dart        # CustomPaint + Ticker (60fps)
    truco/truco_screen.dart        # placeholder
    tranca/tranca_screen.dart      # placeholder
  shared/
    theme/app_theme.dart           # Cores globais (ver abaixo)
    widgets/game_card.dart         # Card reutilizável do grid home
```

## Tema (app_theme.dart)
| Constante        | Hex         | Uso                  |
|------------------|-------------|----------------------|
| `primary`        | `#1B5E20`   | Verde escuro         |
| `accent`         | `#FDD835`   | Amarelo destaque     |
| `background`     | `#121212`   | Fundo geral          |
| `surface`        | `#1E1E1E`   | Cards / AppBar       |
| `textLight`      | `#F5F5F5`   | Texto principal      |

## Padrão de cada jogo
- `*_game.dart` — lógica pura (sem Flutter), fácil de testar
- `*_screen.dart` — `StatefulWidget` + `setState`; sem gerenciamento externo de estado

## Como adicionar um novo jogo
1. Criar `lib/games/<nome>/<nome>_game.dart` e `<nome>_screen.dart`
2. Em `home_screen.dart`:
   - Importar a screen
   - Adicionar tupla em `_games` (title, description, icon, route)
   - Adicionar entrada no `Map` dentro de `_navigate()`

## Jogos ativos e status
| Jogo        | Status     | Modo(s)          |
|-------------|------------|------------------|
| Jogo da Velha | completo | 1P (Minimax AI) / 2P |
| Paciência   | completo   | 1P (Klondike)    |
| Ping Pong   | completo   | 1P (AI) / 2P     |
| Truco       | placeholder | —               |
| Tranca      | placeholder | —               |

## Jogos com loop de animação (Ticker)
Ping Pong usa `SingleTickerProviderStateMixin` + `Ticker` + `CustomPaint`.
Importar `package:flutter/scheduler.dart` para usar o tipo `Ticker` explicitamente.
