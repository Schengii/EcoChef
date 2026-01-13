#%%
from flask import Flask, request, jsonify
from flask_cors import CORS
from google import genai
from dotenv import load_dotenv
import os

# 1. Umgebungsvariablen laden (.env)
load_dotenv()

app = Flask(__name__)
CORS(app)

# 2. Client mit der neuen Bibliothek erstellen
client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))


@app.route('/generate-recipe', methods=['POST'])
def generate_recipe():
    data = request.get_json()

    # 1. WICHTIG: Erst hier holen wir die Zutaten aus der App!
    ingredients = data.get('ingredients', '')

    # 2. JETZT erst darfst du {ingredients} benutzen
    prompt = f"""
    Du bist 'EcoChef', ein kreativer und nachhaltiger Profi-Koch. 
    Deine Aufgabe ist es, aus den folgenden Zutaten ein leckeres Rezept zu zaubern: {ingredients}.
    
    Du darfst Grundnahrungsmittel (Öl, Salz, Pfeffer, Wasser, Mehl) voraussetzen und ergänzen.
    
    Bitte formatiere deine Antwort exakt so (nutze Markdown):
    
    # 🍽️ [Hier einen lustigen Namen für das Gericht erfinden]
    
    **⏱️ Dauer:** [Minuten] | **👨‍🍳 Schwierigkeit:** [Leicht/Mittel/Schwer]
    
    ---
    
    ### 🛒 Zutaten
    * [Zutat 1]
    * [Zutat 2]
    * ...
    
    ### 🔪 Zubereitung
    1. [Erster Schritt]
    2. [Zweiter Schritt]
    3. ...
    
    ---
    **💡 EcoChef-Tipp:** [Ein kurzer Tipp zur Resteverwertung oder Verfeinerung]
    """

    try:
        # 3. Anfrage an Google (mit dem Modell, das bei dir funktioniert hat)
        response = client.models.generate_content(
            model='gemini-flash-latest',
            contents=prompt
        )
        return jsonify({"recipe": response.text})

    except Exception as e:
        print(f"Fehler: {e}")
        return jsonify({"error": str(e)}), 500


    except Exception as e:
        print(f"Fehler: {e}")
        return jsonify({"error": "Die KI konnte gerade nicht antworten."}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
#%%

#%% md
#