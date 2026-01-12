// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart'; // Importiert deine App

void main() {
  testWidgets('App start smoke test', (WidgetTester tester) async {
    // Hier nutzen wir jetzt den richtigen Namen: EcoChefApp
    await tester.pumpWidget(const EcoChefApp());

    // Prüft, ob die App startet (findet z.B. den Titel im AppBar)
    expect(find.text('EcoChef 👨‍🍳'), findsOneWidget);
  });
}