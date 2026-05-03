# Pool Games

App mobile de jogos clássicos desenvolvido em Flutter, compatível com Android e iOS.

## Jogos disponíveis

| Jogo | Status | Descrição |
|---|---|---|
| Jogo da Velha | ✅ Completo | 1 jogador (IA) ou 2 jogadores |
| Paciência | ✅ Completo | Klondike Solitaire clássico |
| Truco | 🚧 Em breve | Truco paulista 2 a 4 jogadores |
| Tranca | 🚧 Em breve | Jogo de cartas 2 a 4 jogadores |

---

## Pré-requisitos

Antes de rodar o projeto, certifique-se de ter instalado:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) — versão 3.41.0 ou superior
- [Android Studio](https://developer.android.com/studio) — necessário para o Android SDK e emulador
- [Xcode](https://developer.apple.com/xcode/) — apenas para build iOS (requer macOS)
- [Git](https://git-scm.com/)

Verifique se o ambiente está correto:

```bash
flutter doctor
```

Todos os itens necessários para a sua plataforma devem estar marcados com `[✓]`.

---

## Instalação

### 1. Clone o repositório

```bash
git clone git@github.com:feasantos/Pool-Games.git
cd Pool-Games
```

### 2. Instale as dependências

```bash
flutter pub get
```

### 3. Rode os testes

```bash
flutter test
```

---

## Rodando o app

### Em um dispositivo físico Android

1. Ative o **Modo Desenvolvedor** no celular:
   - Vá em **Configurações → Sobre o telefone**
   - Toque 7 vezes em **Número de compilação**
2. Ative a **Depuração USB** em **Configurações → Opções do desenvolvedor**
3. Conecte o cabo USB e autorize a depuração no celular
4. Execute:

```bash
flutter devices        # confirme que o celular aparece na lista
flutter run
```

### Em um emulador Android

1. Abra o Android Studio → **Device Manager → Create Device**
2. Escolha um modelo (ex: Pixel 8) e uma versão do Android
3. Inicie o emulador clicando em ▶
4. Execute:

```bash
flutter run
```

### Em um simulador iOS (somente macOS)

```bash
open -a Simulator
flutter run
```

---

## Gerando o APK para distribuição

### APK de debug (para testes rápidos)

```bash
flutter build apk --debug
```

Arquivo gerado em:
```
build/app/outputs/flutter-apk/app-debug.apk
```

### APK de release (para distribuição direta)

```bash
flutter build apk --release
```

### Android App Bundle (para Google Play)

```bash
flutter build appbundle --release
```

Arquivo gerado em:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## Estrutura do projeto

```
lib/
├── main.dart                        # Ponto de entrada do app
├── shared/
│   ├── theme/app_theme.dart         # Cores e tema global
│   └── widgets/game_card.dart       # Card reutilizável da tela inicial
├── home/
│   └── home_screen.dart             # Tela inicial com menu dos jogos
└── games/
    ├── tic_tac_toe/
    │   ├── tic_tac_toe_game.dart    # Lógica do jogo (minimax)
    │   └── tic_tac_toe_screen.dart  # Interface do jogo
    ├── solitaire/
    │   ├── card_model.dart          # Modelo de carta (naipe, rank)
    │   ├── solitaire_game.dart      # Lógica Klondike completa
    │   ├── card_widget.dart         # Widget visual de carta
    │   └── solitaire_screen.dart    # Interface do jogo
    ├── truco/
    │   └── truco_screen.dart        # Em desenvolvimento
    └── tranca/
        └── tranca_screen.dart       # Em desenvolvimento

test/
├── widget_test.dart                 # Teste da tela inicial
├── tic_tac_toe_test.dart            # Testes da lógica e IA
└── solitaire_test.dart              # Testes das regras da Paciência
```

---

## Tecnologias

- [Flutter](https://flutter.dev/) 3.41.9
- [Dart](https://dart.dev/) 3.11.5
- Algoritmo Minimax para IA do Jogo da Velha
- Regras Klondike completas para a Paciência
