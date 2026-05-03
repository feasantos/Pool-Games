import 'package:flutter_test/flutter_test.dart';
import 'package:game_pool/main.dart';

void main() {
  testWidgets('App inicia e exibe tela Home', (WidgetTester tester) async {
    await tester.pumpWidget(const GamePoolApp());
    expect(find.text('Game Pool'), findsOneWidget);
    expect(find.text('Jogo da Velha'), findsOneWidget);
    expect(find.text('Paciência'), findsOneWidget);
    expect(find.text('Truco'), findsOneWidget);
    expect(find.text('Tranca'), findsOneWidget);
  });
}
