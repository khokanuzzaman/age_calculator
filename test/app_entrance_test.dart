import 'package:age_calculator/shared/widgets/app_entrance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses subtle built-in entrance animations by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppEntrance(child: Text('Ready'))),
      ),
    );

    expect(find.text('Ready'), findsOneWidget);
    expect(find.byType(AnimatedOpacity), findsOneWidget);
    expect(find.byType(AnimatedSlide), findsOneWidget);
    expect(find.byType(AnimatedScale), findsOneWidget);
  });

  testWidgets('renders immediately without animation for reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(body: AppEntrance(child: Text('Ready'))),
        ),
      ),
    );

    expect(find.text('Ready'), findsOneWidget);
    expect(find.byType(AnimatedOpacity), findsNothing);
    expect(find.byType(AnimatedSlide), findsNothing);
    expect(find.byType(AnimatedScale), findsNothing);
  });
}
