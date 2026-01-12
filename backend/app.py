{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "initial_id",
   "metadata": {
    "collapsed": true
   },
   "outputs": [],
   "source": [
    "from flask import Flask, request, jsonify\n",
    "import google.generativeai as genai\n",
    "from dotenv import load_dotenv\n",
    "import os\n",
    "\n",
    "load_dotenv()\n",
    "app = Flask(__name__)\n",
    "\n",
    "api_key = os.getenv(\"GEMINI_API_KEY\")\n",
    "if api_key:\n",
    "    genai.configure(api_key=api_key)\n",
    "    model = genai.GenerativeModel('gemini-1.5-flash')\n",
    "\n",
    "@app.route('/generate-recipe', methods=['POST'])\n",
    "def generate_recipe():\n",
    "    data = request.json\n",
    "    zutaten = data.get('ingredients')\n",
    "    if not zutaten: return jsonify({\"error\": \"Keine Zutaten\"}), 400\n",
    "\n",
    "    try:\n",
    "        prompt = f\"Erstelle ein Kochrezept für diese Zutaten: {zutaten}. Nutze Markdown.\"\n",
    "        response = model.generate_content(prompt)\n",
    "        return jsonify({\"recipe\": response.text})\n",
    "    except Exception as e:\n",
    "        return jsonify({\"error\": str(e)}), 500\n",
    "\n",
    "if __name__ == '__main__':\n",
    "    app.run(debug=True, host='0.0.0.0', port=5000)"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 2
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython2",
   "version": "2.7.6"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
