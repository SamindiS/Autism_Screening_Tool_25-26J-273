import json
import os

def convert_arb_to_json(arb_path, json_path):
    with open(arb_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Filter out ARB metadata (@@ and @ keys)
    clean_data = {k: v for k, v in data.items() if not (k.startswith('@') or k.startswith('@@'))}
    
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(clean_data, f, ensure_ascii=False, indent=2)

base_dir = r"d:\GitHub\temp\Autism_Screening_Tool_25-26J-273\SenseAI"
l10n_dir = os.path.join(base_dir, "lib", "l10n")
trans_dir = os.path.join(base_dir, "assets", "translations")

for lang in ['en', 'si', 'ta']:
    arb_file = os.path.join(l10n_dir, f"app_{lang}.arb")
    json_file = os.path.join(trans_dir, f"{lang}.json")
    if os.path.exists(arb_file):
        print(f"Converting {arb_file} to {json_file}")
        convert_arb_to_json(arb_file, json_file)
    else:
        print(f"Warning: {arb_file} not found")
