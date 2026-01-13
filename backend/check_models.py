from google import genai
from dotenv import load_dotenv
import os

load_dotenv()
client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

print("--- Alle Modelle ---")
# Wir drucken einfach blind ALLES aus, ohne Attribute zu prüfen
for m in client.models.list():
    print(m.name)