import 'package:flutter_test/flutter_test.dart';
import 'package:game_mela/main.dart';

void main() {
  testWidgets('All seven GameMela modes open and navigation works', (tester) async {
    await tester.pumpWidget(const GameMelaApp());

    expect(find.text('GAMEMELA'), findsOneWidget);
    expect(find.text('Featured games'), findsOneWidget);

    await tester.tap(find.text('Games').last);
    await tester.pumpAndSettle();
    expect(find.text('CHOOSE YOUR GAME'), findsOneWidget);

    const titles = [
      'Bubble Pop',
      'Quiz Challenge',
      'Memory Match',
      'Number Puzzle',
      'Word Puzzle',
      'Bike Racing',
      'Car Racing',
    ];

    for (final title in titles) {
      await tester.tap(find.text(title).last);
      await tester.pumpAndSettle();
      expect(find.text(title).last, findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Garage').last);
    await tester.pumpAndSettle();
    expect(find.text('YOUR GARAGE'), findsOneWidget);
    expect(find.text('SAVE YOUR GAME PROGRESS'), findsOneWidget);
  });
}
