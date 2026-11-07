import 'package:flutter_test/flutter_test.dart';
import 'package:game_mela/main.dart';

void main() {
  testWidgets('GameMela home, game launch and navigation work', (tester) async {
    await tester.pumpWidget(const GameMelaApp());

    expect(find.text('GAMEMELA'), findsOneWidget);
    expect(find.text('Featured games'), findsOneWidget);

    await tester.tap(find.text('Games').last);
    await tester.pumpAndSettle();
    expect(find.text('CHOOSE YOUR GAME'), findsOneWidget);

    await tester.tap(find.text('Bubble Pop').last);
    await tester.pumpAndSettle();
    expect(find.text('Score: 0'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Garage').last);
    await tester.pumpAndSettle();
    expect(find.text('YOUR GARAGE'), findsOneWidget);
  });
}
