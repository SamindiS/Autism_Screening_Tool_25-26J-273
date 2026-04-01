#!/usr/bin/env python3
"""
Convert JSON translation files to ARB format for Flutter localization
"""
import json
import os
import sys

def convert_json_to_arb(json_file, locale_code, output_file):
    """Convert a JSON translation file to ARB format"""
    with open(json_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    arb_data = {
        "@@locale": locale_code
    }
    
    # Convert all keys to ARB format
    for key, value in data.items():
        # Convert snake_case to camelCase for ARB
        arb_key = to_camel_case(key)
        arb_data[arb_key] = value
    
    # Write ARB file
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(arb_data, f, ensure_ascii=False, indent=2)
    
    print(f"Converted {json_file} -> {output_file}")

def to_camel_case(snake_str):
    """Convert snake_case to camelCase"""
    components = snake_str.split('_')
    # First component stays lowercase, rest are capitalized
    return components[0] + ''.join(x.capitalize() for x in components[1:])

if __name__ == "__main__":
    base_dir = "assets/translations"
    output_dir = "lib/l10n"
    
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    # Convert each language
    conversions = [
        ("en.json", "en", "app_en.arb"),
        ("si.json", "si", "app_si.arb"),
        ("ta.json", "ta", "app_ta.arb"),
    ]
    
    for json_file, locale, arb_file in conversions:
        json_path = os.path.join(base_dir, json_file)
        arb_path = os.path.join(output_dir, arb_file)
        
        if os.path.exists(json_path):
            convert_json_to_arb(json_path, locale, arb_path)
        else:
            print(f"Warning: {json_path} not found")






