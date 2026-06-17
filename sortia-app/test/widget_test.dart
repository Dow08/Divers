// ================================================================
// SORTIA — Test Widget de base
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders without crashing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Sortia')),
        ),
      ),
    );

    expect(find.text('Sortia'), findsOneWidget);
  });
}
