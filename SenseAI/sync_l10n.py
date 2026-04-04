import json
import os
import re

l10n_dir = r'''d:\GitHub\Autism Screening Research Project\Autism_Screening_Tool_25-26J-273\SenseAI\lib\l10n'''
assets_trans_dir = r'''d:\GitHub\Autism Screening Research Project\Autism_Screening_Tool_25-26J-273\SenseAI\assets\translations'''
core_l10n_file = r'''d:\GitHub\Autism Screening Research Project\Autism_Screening_Tool_25-26J-273\SenseAI\lib\core\localization\app_localizations.dart'''

if not os.path.exists(assets_trans_dir):
    os.makedirs(assets_trans_dir)

# 1. Convert ARB to JSON
langs = ['en', 'si', 'ta']
for lang in langs:
    arb_path = os.path.join(l10n_dir, f'app_{lang}.arb')
    json_path = os.path.join(assets_trans_dir, f'{lang}.json')
    if os.path.exists(arb_path):
        with open(arb_path, 'r', encoding='utf-8') as f:
            arb_data = json.load(f)
        
        json_data = {}
        for k, v in arb_data.items():
            if not k.startswith('@'):
                json_data[k] = v
                # Add snake_case alias if needed for existing keys
                # This is a bit heuristic but helps
                snake_k = re.sub(r'(?<!^)(?=[A-Z])', '_', k).lower()
                if snake_k != k:
                    json_data[snake_k] = v
        
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(json_data, f, ensure_ascii=False, indent=2)
        print(f"Created {json_path}")

# 2. Update core/localization/app_localizations.dart
new_keys = [
    'visualCheckingTitle', 'enhanceFocus', 'childInfoTitle', 'letsStartAdventure', 
    'whatsYourName', 'howOldAreYou', 'letsGo', 'funGamesAhead', 'playExcitingGames', 
    'parentGuardianInfo', 'tellUsAboutParent', 'parentGuardianName', 'emailAddress', 
    'phoneNumber', 'includeCountryCode', 'relationship', 'backText', 'continueText', 
    'safeAndSecure', 'infoHelpsReport', 'calibrationTitle', 'lookAtTheDot', 'nextButton', 
    'startGames', 'bubblePopGame', 'howToPlayGame', 'seeTheBubbles', 'bubblesFloat', 
    'tapToPop', 'touchBubblesPop', 'haveFun', 'popAsMany', 'thirtySeconds', 'gameLasts30', 
    'startGameBtn', 'butterflyGame', 'watchButterfly', 'butterflyFlyAround', 'followEyes', 
    'tryLookWhere', 'visitFlowers', 'butterflyLovesFlowers', 'fifteenSeconds', 'gameLasts15', 
    'allDone', 'youDidGreat', 'amazingJob', 'yourScore', 'specialReport', 
    'generatingReportReason', 'getYourReport', 'playAgain'
]

if os.path.exists(core_l10n_file):
    with open(core_l10n_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find the end of the class (before the last closing brace)
    # The class ends after the _AppLocalizationsDelegate
    # But we want to insert inside the AppLocalizations class
    
    # Let's find the last getter in AppLocalizations class
    # The class AppLocalizations ends at line 149 approximately
    match = re.search(r'(class AppLocalizations \{.*?)(  String get dontTapSleepyTurtle => translate\(\'dontTapSleepyTurtle\'\);)?(\n\})', content, re.DOTALL)
    if match:
        insertion = "\n  // Visual Attention & Preferences Getters\n"
        for key in new_keys:
            if f"get {key}" not in content:
                insertion += f"  String get {key} => translate('{key}');\n"
        
        new_content = content[:match.end(1)] + insertion + content[match.start(3):]
        
        with open(core_l10n_file, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print("Updated app_localizations.dart with new getters")
