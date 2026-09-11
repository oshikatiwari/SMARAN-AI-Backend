import os
import json
import sys

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

class MultilingualTranslator:
    """
    SIH26003 Multilingual Localization Engine for Python Backend & REST API Microservices.
    Supports: English, Hindi, Assamese, Mizo, Khasi.
    """
    def __init__(self, dict_path=None):
        if dict_path is None:
            base_dir = os.path.dirname(os.path.abspath(__file__))
            dict_path = os.path.join(base_dir, "multilingual_dictionary.json")
        
        with open(dict_path, "r", encoding="utf-8") as f:
            self.dictionary = json.load(f)
            
    def get_prompt(self, difficulty: str, language: str = "english") -> str:
        lang_key = language.lower()
        diff_key = difficulty.lower()
        diff_prompts = self.dictionary.get("encouragement_prompts", {}).get(diff_key, {})
        return diff_prompts.get(lang_key) or diff_prompts.get("english", "Great effort!")

    def get_game_info(self, game_key: str, language: str = "english") -> dict:
        lang_key = language.lower()
        game_data = self.dictionary.get("games", {}).get(game_key, {})
        title = game_data.get("title", {}).get(lang_key) or game_data.get("title", {}).get("english", "")
        instruction = game_data.get("instruction", {}).get(lang_key) or game_data.get("instruction", {}).get("english", "")
        return {"title": title, "instruction": instruction}

    def get_voice_confirmation(self, language: str = "english") -> str:
        lang_key = language.lower()
        confirms = self.dictionary.get("voice_guidance_confirmations", {})
        return confirms.get(lang_key) or confirms.get("english", "Voice guidance active.")

if __name__ == "__main__":
    translator = MultilingualTranslator()
    print("Testing Multilingual Support across all 5 languages:")
    for lang in ["english", "hindi", "assamese", "mizo", "khasi"]:
        prompt = translator.get_prompt("medium", lang)
        print(f"  * [{lang.upper()}]: {prompt}")
