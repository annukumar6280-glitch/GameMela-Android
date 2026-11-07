import 'package:flutter_test/flutter_test.dart';
import 'package:game_mela/main.dart';

void main() {
  testWidgets('GameMela home screen renders and navigation works', (tester) async {
    await tester.pumpWidget(const GameMelaApp());

    expect(find.text('GAMEMELA'), findsOneWidget);
    expect(find.text('Featured games'), findsOneWidget);

    await tester.tap(find.text('Games').last);
    await tester.pumpAndSettle();
    expect(find.text('CHOOSE YOUR GAME'), findsOneWidget);

    await tester.tap(find.text('Garage').last);
    await tester.pumpAndSettle();
    expect(find.text('YOUR GARAGE'), findsOneWidget);
  });
}
