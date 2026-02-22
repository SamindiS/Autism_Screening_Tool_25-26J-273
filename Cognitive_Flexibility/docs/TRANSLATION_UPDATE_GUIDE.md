# Translation Update Guide

## Overview
All screens in SenseAI now support multilingual content (English, Sinhala, Tamil).

## Translation Files Location
- `assets/translations/en.json` - English
- `assets/translations/si.json` - Sinhala  
- `assets/translations/ta.json` - Tamil

## How to Add Translations

### Step 1: Add Key to English JSON
```json
{
  "new_key": "English translation"
}
```

### Step 2: Add to Sinhala JSON
```json
{
  "new_key": "සිංහල පරිවර්තනය"
}
```

### Step 3: Add to Tamil JSON
```json
{
  "new_key": "தமிழ் மொழிபெயர்ப்பு"
}
```

### Step 4: Use in Code
```dart
import '../../core/localization/app_localizations.dart';

final l10n = AppLocalizations.of(context);
Text(l10n?.translate('new_key') ?? 'Fallback')
```

## Current Translation Keys Structure

### AI Bot Questions
- `ai_question_1` through `ai_question_10` - Question text (use {childName} placeholder)
- `ai_category_1` through `ai_category_10` - Category names
- `ai_question_1_option_1` through `ai_question_10_option_5` - Option texts

### Clinical Reflection (Ages 3.5-6)
- `reflection_question_attention` - Attention question
- `reflection_label_attention` - Attention label
- Similar for: engagement, frustration, instructions, overall

### Manual Tasks (Ages 2-3.5)
- `manual_task_1_title` through `manual_task_5_title` - Task titles
- `manual_task_1_description` through `manual_task_5_description` - Descriptions
- `manual_task_1_task` through `manual_task_5_task` - Task instructions
- `manual_task_1_label` through `manual_task_5_label` - Labels
- `manual_task_1_category` through `manual_task_5_category` - Categories

### Behavioral Observations
- `behavioral_question_rule_switching` - Question text
- `behavioral_label_rule_switching` - Label text
- Similar for: attention, frustration, perseveration, overall

## Important Notes

1. **Placeholders**: Use `{childName}` in question text, it will be replaced automatically
2. **Consistency**: Keep terminology consistent across all translations
3. **Length**: Sinhala and Tamil text may be longer - test UI layout
4. **Fonts**: Sinhala uses IskoolaPota, Tamil uses Bamini fonts automatically

## Testing Translations

1. Change language using LanguageSelector widget
2. Navigate through all screens
3. Check text doesn't overflow
4. Verify all placeholders are replaced correctly
5. Test with different child names


