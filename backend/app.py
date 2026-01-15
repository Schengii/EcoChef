from flask import Flask, request, jsonify
from google import genai
from dotenv import load_dotenv
import os
from flask_cors import CORS
import json

# Umgebungsvariablen laden
load_dotenv()

app = Flask(__name__)
CORS(app)

# Client initialisieren (nimm den Namen, der bei dir funktioniert hat!)
client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

@app.route('/generate-recipe', methods=['POST'])
def generate_recipe():
    data = request.get_json()
    ingredients = data.get('ingredients', '')

    # Der Prompt zwingt Gemini zu JSON und verbietet Namen/Sonderzeichen im Bild-Prompt
    prompt = f"""
    Du bist 'EcoChef'. Erstelle aus diesen Zutaten ein Rezept: {ingredients}.
    
    Antworte WICHTIG: Antworte AUSSCHLIESSLICH im JSON-Format.
    Benutze exakt diese Struktur:
    {{
        "recipe": "# 🍽️ [Name des Gerichts]... (Hier das ganze Rezept in Markdown)",
        "image_prompt": "professional food photography of [Name des Gerichts auf Englisch], delicious, cinematic lighting, 4k"
    }}
    
    REGELN FÜR DEN IMAGE_PROMPT:
    1. Beschreibe NUR das Essen visuell.
    2. Benutze KEINE Namen wie 'EcoChef'.
    3. Benutze KEINE Sonderzeichen (wie ' oder " oder -). Nur Buchstaben und Kommas.
    4. Halte es kurz und prägnant.
    """

    try:
        # Hier nutzen wir den Alias, der bei dir funktioniert hat:
        response = client.models.generate_content(
            model='gemini-flash-latest',
            contents=prompt
        )

        # JSON bereinigen (falls Gemini ```json davor schreibt)
        clean_json = response.text.replace('```json', '').replace('```', '').strip()

        # Text in echtes Daten-Objekt umwandeln
        recipe_data = json.loads(clean_json)

        return jsonify(recipe_data)

    except Exception as e:
        print(f"Fehler: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)