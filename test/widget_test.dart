import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nearnest_app/main.dart';

void main() {
  testWidgets('shows local vendor marketplace home', (tester) async {
    await tester.pumpWidget(const NearnestApp());

    expect(find.text('Book trusted local vendors fast.'), findsOneWidget);
    expect(find.text('Aarav Moments'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
  });

  testWidgets('filters vendors by category', (tester) async {
    await tester.pumpWidget(const NearnestApp());

    await tester.tap(find.text('Decoration'));
    await tester.pumpAndSettle();

    expect(find.text('Bloom & Drape'), findsOneWidget);
    expect(find.text('Aarav Moments'), findsNothing);
  });
}
