import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';

void main() {
  runApp(const EcoChefApp());
}

class EcoChefApp extends StatelessWidget {
  const EcoChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoChef',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const RecipeScreen(),
    );
  }
}

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final TextEditingController _controller = TextEditingController();
  String _recipeText = "";
  bool _isLoading = false;


  Future<void> _generateRecipe() async {
    setState(() {
      _isLoading = true;
      _recipeText = "";
    });

    final ingredients = _controller.text;

    String baseUrl;
    // Prüfen, auf welcher Plattform wir laufen
    if (Theme.of(context).platform == TargetPlatform.android) {
      // Android Emulator braucht die Spezial-Adresse
      baseUrl = 'http://10.0.2.2:5000/generate-recipe';
    } else {
      // Windows, Web und iOS Simulator nutzen localhost
      baseUrl = 'http://127.0.0.1:5000/generate-recipe';
    }

    final url = Uri.parse(baseUrl);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"ingredients": ingredients}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _recipeText = data['recipe'] ?? "Kein Rezept gefunden.";
        });
      } else {
        setState(() {
          _recipeText = "Fehler: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _recipeText = "Verbindungsfehler. Läuft das Python-Backend?\nFehler: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EcoChef 👨‍🍳"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 3,
              minLines: 1,
              decoration: const InputDecoration(
                labelText: "Was ist im Kühlschrank?",
                hintText: 'z.B. Tomaten, Eier, alter Käse...',
                prefixIcon: Icon(Icons.kitchen),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateRecipe,
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_awesome),
                label: Text(_isLoading ? "KI denkt nach..." : "Rezept generieren"),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                // HIER LAG DER FEHLER: Es muss "Markdown" (groß) heißen
                child: _recipeText.isEmpty
                    ? const Center(child: Text("Dein Rezept erscheint hier."))
                    : Markdown(data: _recipeText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}