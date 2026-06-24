import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nearnest_app/main.dart';

void main() {
  testWidgets('shows local vendor marketplace home', (tester) async {
    await tester.pumpWidget(const NearnestApp());

    expect(find.text('Book trusted local vendors fast.'), findsOneWidget);
    expect(find.text('Aarav Moments'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.text('Nearby'), findsOneWidget);
  });

  testWidgets('filters vendors by category', (tester) async {
    await tester.pumpWidget(const NearnestApp());

    await tester.tap(find.text('Decoration'));
    await tester.pumpAndSettle();

    expect(find.text('Bloom & Drape'), findsOneWidget);
    expect(find.text('Aarav Moments'), findsNothing);
  });
  testWidgets('renders on narrow and tablet surfaces', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const NearnestApp());

    expect(find.text('Book trusted local vendors fast.'), findsOneWidget);
    expect(find.text('Aarav Moments'), findsOneWidget);

    await tester.binding.setSurfaceSize(const Size(1024, 900));
    await tester.pumpWidget(const NearnestApp());
    await tester.pumpAndSettle();

    expect(find.text('Book trusted local vendors fast.'), findsOneWidget);
    expect(find.text('Aarav Moments'), findsOneWidget);
  });
}
