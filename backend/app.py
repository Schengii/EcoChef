#%%
from flask import Flask, request, jsonify
from google import genai
from dotenv import load_dotenv
import os

# 1. Umgebungsvariablen laden (.env)
load_dotenv()

app = Flask(__name__)

# 2. Client mit der neuen Bibliothek erstellen
# die neue Bibliothek holt sich den Key oft automatisch, aber so ist es sicher:
client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

@app.route('/generate-recipe', methods=['POST'])
def generate_recipe():
    data = request.json
    zutaten = data.get('ingredients')

    if not zutaten:
        return jsonify({"error": "Keine Zutaten angegeben"}), 400

    print(f"Anfrage erhalten für: {zutaten}")

    try:
        # Der Prompt an die KI
        prompt = (
            f"Du bist ein Koch. Erstelle ein Rezept aus diesen Zutaten: {zutaten}. "
            f"Nutze Markdown (Fettgedruckt für Titel, Listen für Schritte)."
        )

        # 3. Neuer Aufruf für die Generierung
        response = client.models.generate_content(
            model='gemini-2.0-flash', # Wir nehmen direkt das neuste, schnellste Modell
            contents=prompt
        )

        # Zugriff auf den Text ist bei der neuen Library gleich
        return jsonify({"recipe": response.text})

    except Exception as e:
        print(f"Fehler: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
#%%

#%% md
#