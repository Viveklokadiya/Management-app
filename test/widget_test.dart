import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shree_giriraj_management/app.dart';

void main() {
  testWidgets('ShreeGirirajApp renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ShreeGirirajApp(),
      ),
    );
    // App should render — placeholder home visible
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
