from google import genai
from dotenv import load_dotenv
import os

load_dotenv()
client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

print("--- DEINE VERFÜGBAREN MODELLE ---")
try:
    for m in client.models.list():
        # Wir drucken einfach nur den Namen, sonst nichts
        print(f"Gefunden: {m.name}")
except Exception as e:
    print(f"Fehler beim Listen: {e}")