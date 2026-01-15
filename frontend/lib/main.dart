import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';

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
  // Hier speichern wir die Bild-Adresse
  String? _imageUrl;
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
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ingredients': ingredients}),
      );

      if (response.statusCode == 200) {
        // Wir holen uns die Daten aus dem JSON
        final data = jsonDecode(response.body);

        String imagePrompt = data['image_prompt'];

        // 1. Alles entfernen, was kein Buchstabe oder Zahl ist
        String cleanPrompt = imagePrompt.replaceAll(RegExp(r"[^a-zA-Z0-9\s,]"), "");

        // 2. WICHTIG: Den Text kürzen! Zu lange URLs führen oft zu Fehlern.
        // Wir nehmen maximal die ersten 100 Zeichen.
        if (cleanPrompt.length > 100) {
          cleanPrompt = cleanPrompt.substring(0, 100);
        }

        // 3. Kodieren für die URL
        String safePrompt = Uri.encodeComponent(cleanPrompt);

        // Debugging: Damit wir sehen, was schiefgeht, drucken wir die URL in die Konsole
        String finalUrl = "https://image.pollinations.ai/prompt/$safePrompt?width=800&height=600&seed=42&model=flux";

        print("Versuche Bild zu laden von: $finalUrl");

        setState(() {
          _recipeText = data['recipe'];
          _imageUrl = finalUrl;
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

  void _shareRecipe() {
    // Wenn kein Rezept da ist, brechen wir ab
    if (_recipeText.isEmpty) return;

    // Wir basteln eine schöne Nachricht zusammen
    String message = "Guck mal, was ich mit EcoChef koche! 👨‍🍳\n\n";
    message += "$_recipeText\n\n";

    if (_imageUrl != null) {
      message += "📸 Hier ein Foto dazu: $_imageUrl";
    }

    // Das öffnet das Teilen-Menü vom Handy (WhatsApp, Mail, etc.)
    Share.share(message);
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

                child: _recipeText.isEmpty
                    ? const Center(child: Text("Dein Rezept erscheint hier."))
                    : SingleChildScrollView( // Wichtig: Scrollbar machen, da Bild + Text viel Platz brauchen
                  child: Column(
                    children: [
                      // ... im Column children ...
                      if (_imageUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: Image.network(
                              _imageUrl!,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,

                              // Lade-Animation
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 250,
                                  color: Colors.grey[200],
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              },

                              // DER RETTER: Falls das Bild kaputt ist, zeige keinen Fehler an!
                              errorBuilder: (context, error, stackTrace) {
                                print("Bild konnte nicht geladen werden: $error");
                                return Container(
                                  height: 250,
                                  color: Colors.grey[300],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                      Text("Bild konnte nicht geladen werden", style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),



                      // 2. Das REZEPT (MarkdownBody nutzen wir in einer Column statt Markdown)
                      MarkdownBody(data: _recipeText),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // NEU: Der schwebende Teilen-Knopf
      floatingActionButton: _recipeText.isEmpty
          ? null // Kein Rezept? Kein Knopf!
          : FloatingActionButton.extended(
        onPressed: _shareRecipe,
        label: const Text("Teilen"),
        icon: const Icon(Icons.share),
        backgroundColor: Colors.green, // Passend zum Eco-Look
      ),
    );
  }
}