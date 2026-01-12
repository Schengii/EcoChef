import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';

void main() => runApp(const MaterialApp(home: RecipeScreen()));

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});
  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final _controller = TextEditingController();
  String _result = "";
  bool _loading = false;

  Future<void> _getRecipe() async {
    setState(() => _loading = true);
    try {
      // Hinweis: 10.0.2.2 für Android Emulator, localhost für Web/iOS
      final url = Uri.parse('http://10.0.2.2:5000/generate-recipe');
      final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"ingredients": _controller.text})
      );
      final data = jsonDecode(response.body);
      setState(() => _result = data['recipe'] ?? "Fehler");
    } catch (e) {
      setState(() => _result = "Fehler: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("EcoChef")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _controller, decoration: const InputDecoration(labelText: "Zutaten")),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _loading ? null : _getRecipe,
                child: Text(_loading ? "Lade..." : "Rezept holen")
            ),
            const SizedBox(height: 20),
            Expanded(child: Markdown(data: _result)),
          ],
        ),
      ),
    );
  }
}